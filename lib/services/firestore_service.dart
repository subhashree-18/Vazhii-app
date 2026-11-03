import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/destination_model.dart';
import '../models/vehicle_model.dart';
import '../models/booking_model.dart';
import 'firebase_service.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  // Local fallback storage for offline/demo testing
  final List<BookingModel> _localBookings = [];
  final Map<String, UserModel> _localUsers = {};

  // Broadcast controller to emit updates to local bookings when offline/local fallback
  final StreamController<List<BookingModel>> _localBookingsStreamController =
      StreamController<List<BookingModel>>.broadcast();

  void _notifyLocalBookingsChanged() {
    _localBookingsStreamController.add(List.unmodifiable(_localBookings));
  }

  // -------------------------------------------------------------
  // USERS COLLECTION
  // -------------------------------------------------------------
  Future<void> saveUser(UserModel user) async {
    _localUsers[user.userId] = user;

    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.userId)
            .set(user.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[FirestoreService] Error saving user to Firestore: $e');
      }
    }
  }

  Future<UserModel?> getUser(String userId) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
      } catch (e) {
        debugPrint('[FirestoreService] Error fetching user from Firestore: $e');
      }
    }
    return _localUsers[userId];
  }

  // -------------------------------------------------------------
  // BOOKINGS COLLECTION
  // -------------------------------------------------------------
  Future<void> saveBooking(BookingModel booking) async {
    // Save to local cache first
    _localBookings.removeWhere((b) => b.bookingId == booking.bookingId);
    _localBookings.insert(0, booking);
    _notifyLocalBookingsChanged();

    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(booking.bookingId)
            .set(booking.toMap());
        debugPrint(
          '[FirestoreService] Booking ${booking.bookingId} saved to Cloud Firestore.',
        );
      } catch (e) {
        debugPrint(
          '[FirestoreService] Error saving booking to Cloud Firestore: $e',
        );
      }
    }
  }

  /// Real-time stream of user bookings using Firestore snapshots
  Stream<List<BookingModel>> streamUserBookings(String userId) {
    if (FirebaseService.instance.isInitialized) {
      return FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).handleError((error) {
        debugPrint('[FirestoreService] Stream error: $error');
        return _getLocalBookingsForUser(userId);
      });
    }

    // Local fallback stream
    return _localBookingsStreamController.stream
        .map((_) => _getLocalBookingsForUser(userId))
        .asBroadcastStream(
          onListen: (subscription) {
            _notifyLocalBookingsChanged();
          },
        );
  }

  List<BookingModel> _getLocalBookingsForUser(String userId) {
    final filtered = _localBookings.where((b) {
      return b.userId == userId ||
          userId == 'guest_user' ||
          b.userId.startsWith('local_') ||
          b.userId.startsWith('guest_');
    }).toList();
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered;
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final list = snapshot.docs
              .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        }
      } catch (e) {
        debugPrint('[FirestoreService] Error fetching bookings: $e');
      }
    }

    return _getLocalBookingsForUser(userId);
  }

  /// Cancellation policy handling:
  /// - 'pending': Can be cancelled immediately by customer.
  /// - 'confirmed': Submits cancellation_requested with reason & timestamp for coordinator review.
  /// - 'completed' / 'rejected' / 'cancelled': Cannot be cancelled.
  Future<void> requestCancellation({
    required String bookingId,
    required String currentStatus,
    String reason = 'Requested by customer',
  }) async {
    final statusLower = currentStatus.toLowerCase();
    if (statusLower == 'completed' ||
        statusLower == 'rejected' ||
        statusLower == 'cancelled') {
      throw Exception('This booking cannot be cancelled in its current state.');
    }

    final isConfirmed = statusLower == 'confirmed';
    final newStatus = isConfirmed ? 'cancellation_requested' : 'cancelled';
    final coordinatorNotes = isConfirmed
        ? 'Customer requested cancellation: $reason'
        : 'Cancelled by customer';
    final requestTime = DateTime.now();

    final index = _localBookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final old = _localBookings[index];
      _localBookings[index] = old.copyWith(
        bookingStatus: newStatus,
        coordinatorNotes: coordinatorNotes,
        cancellationReason: reason,
        cancellationRequestedAt: requestTime,
      );
      _notifyLocalBookingsChanged();
    }

    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .update({
          'bookingStatus': newStatus,
          'coordinatorNotes': coordinatorNotes,
          'cancellationReason': reason,
          'cancellationRequestedAt': requestTime.toIso8601String(),
        });
      } catch (e) {
        debugPrint('[FirestoreService] Error updating booking cancellation: $e');
        rethrow;
      }
    }
  }

  // -------------------------------------------------------------
  // DESTINATIONS COLLECTION
  // -------------------------------------------------------------
  Future<List<DestinationModel>> getDestinations() async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('destinations')
            .where('isActive', isEqualTo: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => DestinationModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('[FirestoreService] Error fetching destinations: $e');
      }
    }
    return sampleDestinations;
  }

  // -------------------------------------------------------------
  // VEHICLES COLLECTION
  // -------------------------------------------------------------
  Future<List<VehicleModel>> getVehicles() async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('vehicles')
            .where('isActive', isEqualTo: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('[FirestoreService] Error fetching vehicles: $e');
      }
    }
    return sampleVehicles;
  }
}
