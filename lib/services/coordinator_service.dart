import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../models/driver_model.dart';
import '../models/vehicle_model.dart';
import 'firebase_service.dart';

class CoordinatorService {
  CoordinatorService._();
  static final CoordinatorService instance = CoordinatorService._();

  // Local fallback storage for offline/demo coordinator operations
  final List<DriverModel> _localDrivers = List.from(sampleDrivers);
  final List<VehicleModel> _localVehicles = List.from(sampleVehicles);

  final StreamController<List<BookingModel>> _allBookingsStreamController =
      StreamController<List<BookingModel>>.broadcast();

  // -------------------------------------------------------------
  // ALL BOOKINGS STREAM & OPERATIONS
  // -------------------------------------------------------------
  Stream<List<BookingModel>> streamAllBookings() {
    if (FirebaseService.instance.isInitialized) {
      return FirebaseFirestore.instance
          .collection('bookings')
          .snapshots()
          .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      }).handleError((err) {
        debugPrint('[CoordinatorService] Stream error: $err');
        return <BookingModel>[];
      });
    }

    return _allBookingsStreamController.stream.asBroadcastStream();
  }

  /// Confirm booking with assigned driver and vehicle registration
  Future<void> confirmBooking({
    required String bookingId,
    required String driverName,
    required String vehicleRegistration,
    String? coordinatorNotes,
  }) async {
    final notes = coordinatorNotes ?? 'Assigned driver $driverName ($vehicleRegistration)';

    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
          'bookingStatus': 'confirmed',
          'driverName': driverName,
          'vehicleRegistration': vehicleRegistration,
          'coordinatorNotes': notes,
        });
      } catch (e) {
        debugPrint('[CoordinatorService] Error confirming booking: $e');
        rethrow;
      }
    }
  }

  /// Decline / reject booking (e.g., no driver available on holiday dates)
  Future<void> declineBooking({
    required String bookingId,
    required String reason,
  }) async {
    final notes = 'Booking declined: $reason';

    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
          'bookingStatus': 'rejected',
          'coordinatorNotes': notes,
        });
      } catch (e) {
        debugPrint('[CoordinatorService] Error declining booking: $e');
        rethrow;
      }
    }
  }

  /// Mark trip as completed
  Future<void> completeBooking(String bookingId) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
          'bookingStatus': 'completed',
          'coordinatorNotes': 'Trip successfully completed.',
        });
      } catch (e) {
        debugPrint('[CoordinatorService] Error completing booking: $e');
        rethrow;
      }
    }
  }

  /// Approve cancellation request
  Future<void> approveCancellation(String bookingId) async {
    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({
          'bookingStatus': 'cancelled',
          'coordinatorNotes': 'Cancellation approved by coordinator.',
        });
      } catch (e) {
        debugPrint('[CoordinatorService] Error approving cancellation: $e');
        rethrow;
      }
    }
  }

  // -------------------------------------------------------------
  // DRIVER FLEET MANAGEMENT
  // -------------------------------------------------------------
  Future<List<DriverModel>> getDrivers() async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance.collection('drivers').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => DriverModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('[CoordinatorService] Error loading drivers: $e');
      }
    }
    return _localDrivers;
  }

  Future<void> saveDriver(DriverModel driver) async {
    _localDrivers.removeWhere((d) => d.driverId == driver.driverId);
    _localDrivers.add(driver);

    if (FirebaseService.instance.isInitialized) {
      try {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(driver.driverId)
            .set(driver.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('[CoordinatorService] Error saving driver: $e');
      }
    }
  }

  // -------------------------------------------------------------
  // VEHICLE FLEET MANAGEMENT
  // -------------------------------------------------------------
  Future<List<VehicleModel>> getVehicles() async {
    if (FirebaseService.instance.isInitialized) {
      try {
        final snapshot = await FirebaseFirestore.instance.collection('vehicles').get();
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => VehicleModel.fromMap(doc.data(), doc.id))
              .toList();
        }
      } catch (e) {
        debugPrint('[CoordinatorService] Error loading vehicles: $e');
      }
    }
    return _localVehicles;
  }
}

