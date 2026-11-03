import '../models/destination_model.dart';
import '../models/vehicle_model.dart';

/// Calculation breakdown for transparent trip price estimates.
class PriceBreakdown {
  final int baseDailyRate;
  final int durationDays;
  final int grossAmount;
  final int durationDiscountAmount;
  final int ghatRoadSurcharge;
  final int totalEstimatedPrice;

  const PriceBreakdown({
    required this.baseDailyRate,
    required this.durationDays,
    required this.grossAmount,
    required this.durationDiscountAmount,
    required this.ghatRoadSurcharge,
    required this.totalEstimatedPrice,
  });
}

/// Service handling transparent and configurable package price estimations.
/// Ensures pricing logic is decoupled from UI widgets and providers.
class PricingService {
  PricingService._();
  static final PricingService instance = PricingService._();

  /// Estimates package price considering:
  /// - Vehicle base price (or destination starting rate fallback)
  /// - Trip duration with discounts for longer trips (>= 5 days: 5%, >= 7 days: 10%)
  /// - Ghat road / steep terrain surcharge based on destination elevation
  PriceBreakdown calculateEstimate({
    required VehicleModel? vehicle,
    required DestinationModel? destination,
    required int durationDays,
  }) {
    final effectiveDays = durationDays < 1 ? 1 : durationDays;

    final dailyRate = vehicle?.basePrice ??
        destination?.startingPricePerDay ??
        3800;

    final gross = dailyRate * effectiveDays;

    // Discount for extended hill station packages
    int discount = 0;
    if (effectiveDays >= 7) {
      discount = (gross * 0.10).round(); // 10% discount for 7+ days
    } else if (effectiveDays >= 5) {
      discount = (gross * 0.05).round(); // 5% discount for 5-6 days
    }

    // Ghat road / elevation surcharge for challenging hill stations (Valparai hairpin bends, Kolli Hills 70 bends, Meghamalai)
    int ghatSurcharge = 0;
    if (destination != null) {
      final destLower = destination.name.toLowerCase();
      if (destLower.contains('kolli') || destLower.contains('valparai') || destLower.contains('meghamalai')) {
        ghatSurcharge = 500 * effectiveDays; // ₹500/day for high hairpin bend routes
      } else if (destLower.contains('ooty') || destLower.contains('kodaikanal')) {
        ghatSurcharge = 300 * effectiveDays; // ₹300/day for standard ghat routes
      }
    }

    final total = gross - discount + ghatSurcharge;

    return PriceBreakdown(
      baseDailyRate: dailyRate,
      durationDays: effectiveDays,
      grossAmount: gross,
      durationDiscountAmount: discount,
      ghatRoadSurcharge: ghatSurcharge,
      totalEstimatedPrice: total,
    );
  }
}

