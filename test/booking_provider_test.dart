import 'package:flutter_test/flutter_test.dart';
import 'package:vazhii/models/destination_model.dart';
import 'package:vazhii/models/vehicle_model.dart';
import 'package:vazhii/providers/booking_provider.dart';

void main() {
  group('BookingProvider Tests', () {
    test('Initial values are set properly', () {
      final provider = BookingProvider();
      expect(provider.pickupLocation, contains('Chennai'));
      expect(provider.selectedDestination, isNull);
      expect(provider.selectedVehicle, isNull);
      expect(provider.durationDays, 3);
      expect(provider.hasSelectedDestination, isFalse);
      expect(provider.hasSelectedVehicle, isFalse);
    });

    test('Updating pickup location works', () {
      final provider = BookingProvider();
      provider.setPickupLocation('Coimbatore Airport');
      expect(provider.pickupLocation, 'Coimbatore Airport');
    });

    test('Selecting destination updates provider state', () {
      final provider = BookingProvider();
      final destination = sampleDestinations.first;

      provider.selectDestination(destination);
      expect(provider.hasSelectedDestination, isTrue);
      expect(provider.selectedDestination?.name, destination.name);
    });

    test('Selecting vehicle updates vehicle and price calculation', () {
      final provider = BookingProvider();
      final vehicle = sampleVehicles.first;

      provider.setDurationDays(3);
      provider.selectVehicle(vehicle);

      expect(provider.hasSelectedVehicle, isTrue);
      expect(provider.selectedVehicle?.vehicleId, vehicle.vehicleId);
      expect(provider.estimatedTotalPrice, vehicle.basePrice * 3);
    });

    test('Changing travel duration validates bounds', () {
      final provider = BookingProvider();
      provider.setDurationDays(5);
      expect(provider.durationDays, 5);

      // Outside bounds should not change
      provider.setDurationDays(25);
      expect(provider.durationDays, 5);
    });

    test('Submitting booking request creates pending BookingModel with VZ reference', () async {
      final provider = BookingProvider();
      final vehicle = sampleVehicles.first;
      provider.selectVehicle(vehicle);
      provider.setDurationDays(2);

      final booking = await provider.submitBookingRequest(
        name: 'Karthik',
        phone: '9876543210',
        specialRequests: 'Need roof carrier',
      );

      expect(booking.bookingId, startsWith('VZ-'));
      expect(booking.customerName, 'Karthik');
      expect(booking.customerPhone, '9876543210');
      expect(booking.bookingStatus, 'pending'); // must be pending initially
      expect(booking.estimatedPrice, vehicle.basePrice * 2);
      expect(provider.submittedBooking, isNotNull);
    });
  });
}
