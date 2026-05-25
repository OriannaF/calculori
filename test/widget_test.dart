import 'package:flutter_test/flutter_test.dart';
// Asegurate de cambiar 'calculori' por el nombre exacto de tu proyecto si fuera diferente
import 'package:calculori/main.dart'; 

void main() {
  testWidgets('Counter value smoke test', (WidgetTester tester) async {
    // Cambiamos const MyApp() por const CalculOriApp()
    await tester.pumpWidget(const CalculOriApp());

    // Verificamos que la app inicie buscando un elemento de tu HomeScreen
    expect(find.text('CalculOri'), findsWidgets);
  });
}