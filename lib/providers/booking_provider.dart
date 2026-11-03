import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/destination_model.dart';
import '../models/vehicle_model.dart';
import '../models/booking_model.dart';
import '../core/constants/app_constants.dart';
import '../services/firestore_service.dart';
import '../services/pricing_service.dart';

/// Manages the full state of the taxi booking request throughout the flow:
/// HomeScreen -> DestinationSelection -> VehicleSelection -> PackageDetails -> BookingConfirmation
/// Integrates with Cloud Firestore for real-time booking tracking and pricing calculations.
class BookingProvider extends ChangeNotifier {
  String _pickupLocation = AppConstants.defaultPickup;
  DestinationModel? _selectedDestination;
  VehicleModel? _selectedVehicle;
  DateTime _travelDate = DateTime.now().add(const Duration(days: 1));
  int _durationDays = AppConstants.defaultDurationDays;

  // Customer details
  int _passengerCount = 2;
  String _customerName = '';
  String _customerPhone = '';
  String _specialRequests = '';

  // Completed booking request & history
  BookingModel? _submittedBooking;
  List<BookingModel> _userBookings = [];
  bool _isLoadingHistory = false;
  StreamSubscription<List<BookingModel>>? _bookingsSubscription;

  // Getters
  String get pickupLocation => _pickupLocation;
  DestinationModel? get selectedDestination => _selectedDestination;
  VehicleModel? get selectedVehicle => _selectedVehicle;
  DateTime get travelDate => _travelDate;
  int get durationDays => _durationDays;
  int get passengerCount => _passengerCount;
  String get customerName => _customerName;
  String get customerPhone => _customerPhone;
  String get specialRequests => _specialRequests;
  BookingModel? get submittedBooking => _submittedBooking;
  List<BookingModel> get userBookings => _userBookings;
  bool get isLoadingHistory => _isLoadingHistory;

  bool get hasSelectedDestination => _selectedDestination != null;
  bool get hasSelectedVehicle => _selectedVehicle != null;

  String get formattedTravelDate {
    return DateFormat('dd/MM/yyyy').format(_travelDate);
  }

  String get friendlyTravelDate {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (_travelDate.year == tomorrow.year &&
        _travelDate.month == tomorrow.month &&
        _travelDate.day == tomorrow.day) {
      return 'Tomorrow, ${DateFormat('d MMM yyyy').format(_travelDate)}';
    }
    return DateFormat('EEE, d MMM yyyy').format(_travelDate);
  }

  String get formattedDuration {
    return '$_durationDays ${_durationDays == 1 ? "Day" : "Days"}';
  }

  /// Price breakdown calculation delegated directly to PricingService
  PriceBreakdown get priceBreakdown {
    return PricingService.instance.calculateEstimate(
      vehicle: _selectedVehicle,
      destination: _selectedDestination,
      durationDays: _durationDays,
    );
  }

  /// Calculates the illustrative package price using the centralized PricingService
  int get estimatedTotalPrice => priceBreakdown.totalEstimatedPrice;

  // Mutators
  void setPickupLocation(String location) {
    if (location.trim().isNotEmpty) {
      _pickupLocation = location.trim();
      notifyListeners();
    }
  }

  void selectDestination(DestinationModel destination) {
    _selectedDestination = destination;
    notifyListeners();
  }

  void clearDestination() {
    _selectedDestination = null;
    notifyListeners();
  }

  void selectVehicle(VehicleModel vehicle) {
    _selectedVehicle = vehicle;
    if (_passengerCount > vehicle.passengerCapacity) {
      _passengerCount = vehicle.passengerCapacity;
    }
    notifyListeners();
  }

  void setTravelDate(DateTime date) {
    _travelDate = date;
    notifyListeners();
  }

  void setDurationDays(int days) {
    if (days >= AppConstants.minDurationDays &&
        days <= AppConstants.maxDurationDays) {
      _durationDays = days;
      notifyListeners();
    }
  }

  void setPassengerCount(int count) {
    final maxCapacity = _selectedVehicle?.passengerCapacity ?? 7;
    if (count >= 1 && count <= maxCapacity) {
      _passengerCount = count;
      notifyListeners();
    }
  }

  void setCustomerDetails({
    required String name,
    required String phone,
    String? specialRequests,
    int? passengers,
  }) {
    _customerName = name.trim();
    _customerPhone = phone.trim();
    if (specialRequests != null) _specialRequests = specialRequests.trim();
    if (passengers != null) _passengerCount = passengers;
    notifyListeners();
  }

  /// Submits the booking request, stores in Firestore bookings collection with status 'pending'
  Future<BookingModel> submitBookingRequest({
    required String name,
    required String phone,
    String specialRequests = '',
    String userId = 'guest_user',
  }) async {
    _customerName = name.trim();
    _customerPhone = phone.trim();
    _specialRequests = specialRequests.trim();

    // Generate collision-resistant reference number (e.g. VZ-842915)
    final randomDigits = 100000 + Random().nextInt(900000);
    final bookingId = 'VZ-$randomDigits';

    final newBooking = BookingModel(
      bookingId: bookingId,
      userId: userId,
      pickupLocation: _pickupLocation,
      destinationId: _selectedDestination?.destinationId ?? 'general',
      destinationName: _selectedDestination?.name ?? 'Hill Station Trip',
      travelDate: _travelDate,
      durationDays: _durationDays,
      passengerCount: _passengerCount,
      vehicleId: _selectedVehicle?.vehicleId ?? 'sedan-prime-4s',
      vehicleType: _selectedVehicle?.vehicleType ?? '4-Seater Taxi',
      vehicleModelName: _selectedVehicle?.modelName ?? 'Sedan / SUV',
      customerName: _customerName,
      customerPhone: _customerPhone,
      specialRequests: _specialRequests,
      estimatedPrice: estimatedTotalPrice,
      bookingStatus: 'pending', // Must always start with pending
      createdAt: DateTime.now(),
      coordinatorNotes: 'Awaiting coordinator driver assignment',
    );

    // Save to Firestore bookings collection
    await FirestoreService.instance.saveBooking(newBooking);

    _submittedBooking = newBooking;
    _userBookings.removeWhere((b) => b.bookingId == newBooking.bookingId);
    _userBookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  /// Start real-time stream subscription for user bookings
  void subscribeToUserBookings(String userId) {
    _bookingsSubscription?.cancel();
    _isLoadingHistory = true;
    notifyListeners();

    _bookingsSubscription = FirestoreService.instance
        .streamUserBookings(userId)
        .listen((bookings) {
      _userBookings = bookings;
      _isLoadingHistory = false;
      notifyListeners();
    }, onError: (err) {
      debugPrint('[BookingProvider] Subscription error: $err');
      _isLoadingHistory = false;
      notifyListeners();
    });
  }

  /// Fetch booking history for the current user from Firestore
  Future<void> fetchUserBookings(String userId) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _userBookings = await FirestoreService.instance.getUserBookings(userId);
    } catch (e) {
      debugPrint('[BookingProvider] Error fetching bookings: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  /// Request cancellation of a booking adhering to cancellation policies
  Future<void> requestCancellation({
    required String bookingId,
    required String currentStatus,
    String reason = 'Cancelled by customer',
  }) async {
    await FirestoreService.instance.requestCancellation(
      bookingId: bookingId,
      currentStatus: currentStatus,
      reason: reason,
    );
  }

  void resetDraft() {
    _pickupLocation = AppConstants.defaultPickup;
    _selectedDestination = null;
    _selectedVehicle = null;
    _travelDate = DateTime.now().add(const Duration(days: 1));
    _durationDays = AppConstants.defaultDurationDays;
    _passengerCount = 2;
    _customerName = '';
    _customerPhone = '';
    _specialRequests = '';
    _submittedBooking = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    super.dispose();
  }
}
