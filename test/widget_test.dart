import 'package:flutter_test/flutter_test.dart';
import 'package:DentalConnect/main.dart'; // O el nombre de tu proyecto si es diferente

void main() {
  testWidgets('Prueba de carga de Login', (WidgetTester tester) async {
    // 1. Construye nuestra app
    await tester.pumpWidget(const DentalConnectApp());

    // 2. Busca un texto que sí exista en tu pantalla de Login
    expect(find.text('Iniciar Sesión'), findsWidgets);
  });
}
