import 'package:flutter_test/flutter_test.dart';
import 'package:vazhii/models/destination_model.dart';
import 'package:vazhii/models/vehicle_model.dart';
import 'package:vazhii/services/pricing_service.dart';

void main() {
  group('PricingService Tests', () {
    test('Standard trip without discounts or special ghat surcharges', () {
      final vehicle = sampleVehicles.first; // e.g. basePrice 3800
      final result = PricingService.instance.calculateEstimate(
        vehicle: vehicle,
        destination: null,
        durationDays: 3,
      );

      expect(result.baseDailyRate, vehicle.basePrice);
      expect(result.durationDays, 3);
      expect(result.grossAmount, vehicle.basePrice * 3);
      expect(result.durationDiscountAmount, 0);
      expect(result.ghatRoadSurcharge, 0);
      expect(result.totalEstimatedPrice, vehicle.basePrice * 3);
    });

    test('Trip for 5 days applies 5% discount', () {
      final vehicle = sampleVehicles.first;
      final result = PricingService.instance.calculateEstimate(
        vehicle: vehicle,
        destination: null,
        durationDays: 5,
      );

      final gross = vehicle.basePrice * 5;
      final discount = (gross * 0.05).round();
      expect(result.durationDiscountAmount, discount);
      expect(result.totalEstimatedPrice, gross - discount);
    });

    test('Trip for 7 days applies 10% discount', () {
      final vehicle = sampleVehicles.first;
      final result = PricingService.instance.calculateEstimate(
        vehicle: vehicle,
        destination: null,
        durationDays: 7,
      );

      final gross = vehicle.basePrice * 7;
      final discount = (gross * 0.10).round();
      expect(result.durationDiscountAmount, discount);
      expect(result.totalEstimatedPrice, gross - discount);
    });

    test('Ooty trip applies standard ghat surcharge', () {
      final vehicle = sampleVehicles.first;
      final ooty = sampleDestinations.firstWhere((d) => d.name.contains('Ooty'));
      final result = PricingService.instance.calculateEstimate(
        vehicle: vehicle,
        destination: ooty,
        durationDays: 2,
      );

      expect(result.ghatRoadSurcharge, 300 * 2); // ₹600 for 2 days
      expect(result.totalEstimatedPrice, (vehicle.basePrice * 2) + 600);
    });
  });
}

