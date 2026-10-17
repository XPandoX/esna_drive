import '../constants/app_constants.dart';

class FareCalculator {
  static double calculateSuggestedFare({
    required String categoryId,
    required double distanceKm,
    bool isDoorToDoor = false,
    bool isExtremeHeat = false,
    double? customPerKmRate,
    double? customBasePrice,
  }) {
    final category = AppConstants.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => AppConstants.categories[0],
    );

    final base = customBasePrice ?? category.basePrice;
    final perKm = customPerKmRate ?? category.perKmPrice;

    double fare = base + (distanceKm * perKm);

    if (isDoorToDoor && categoryId == 'marsoul') {
      fare += 5.0; // Door-to-door surcharge
    }

    if (isExtremeHeat) {
      fare += AppConstants.heatBonusEgp; // Extreme heat bonus for captains
    }

    // Round to nearest 5 EGP (inDrive convention in Egypt)
    return roundToNearest5(fare);
  }

  static double roundToNearest5(double value) {
    final rounded = (value / 5.0).round() * 5.0;
    return rounded < 10.0 ? 10.0 : rounded;
  }

  static double calculateCommission(double agreedPrice, double commissionRate) {
    return double.parse((agreedPrice * commissionRate).toStringAsFixed(2));
  }
}
