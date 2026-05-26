import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/price_calculator.dart';

class CalculatorState {
  final double cost;
  final String productName;
  final double multiplier;
  final String roundingType;
  final List<Map<String, dynamic>> paymentMethods;

  CalculatorState({
    this.cost = 0.0,
    this.productName = '',
    this.multiplier = 2.0,
    this.roundingType = 'Sin redondeo',
    this.paymentMethods = const [],
  });

  double get basePrice => PriceCalculator.calculateBasePrice(cost, multiplier, roundingType);

  CalculatorState copyWith({
    double? cost,
    String? productName,
    double? multiplier,
    String? roundingType,
    List<Map<String, dynamic>>? paymentMethods,
  }) {
    return CalculatorState(
      cost: cost ?? this.cost,
      productName: productName ?? this.productName,
      multiplier: multiplier ?? this.multiplier,
      roundingType: roundingType ?? this.roundingType,
      paymentMethods: paymentMethods ?? this.paymentMethods,
    );
  }
}

class CalculatorNotifier extends Notifier<CalculatorState> {
  @override
  CalculatorState build() {
    return CalculatorState();
  }

  void updateCost(double newCost) {
    state = state.copyWith(cost: newCost);
  }

  void updateProductName(String newName) {
    state = state.copyWith(productName: newName);
  }

  void updateSettings(double multiplier, String roundingType, List<Map<String, dynamic>> methods) {
    state = state.copyWith(
      multiplier: multiplier,
      roundingType: roundingType,
      paymentMethods: methods,
    );
  }
}

final calculatorProvider = NotifierProvider<CalculatorNotifier, CalculatorState>(() {
  return CalculatorNotifier();
});
