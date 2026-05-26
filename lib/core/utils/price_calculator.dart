class PriceCalculator {
  static double applyRounding(double value, String roundingType) {
    if (roundingType == '500') {
      return (value / 500).ceil() * 500.0;
    } else if (roundingType == '1000') {
      return (value / 1000).ceil() * 1000.0;
    } else if (roundingType == 'Cientos' || roundingType == '100') {
      return (value / 100).ceil() * 100.0;
    }
    return value; // 'Sin redondeo'
  }

  static double calculateBasePrice(double cost, double multiplier, String roundingType) {
    return applyRounding(cost * multiplier, roundingType);
  }

  static double calculateMethodPrice(double basePrice, double percent, String roundingType) {
    return applyRounding(basePrice * (1 + percent / 100), roundingType);
  }
}
