import 'package:flutter_test/flutter_test.dart';

import 'package:wammetka/app.dart';

void main() {
  testWidgets('Splash muestra marca Wammetka y llega a login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(WammetkaApp());
    expect(find.text('Wammetka'), findsOneWidget);
    expect(find.text('Compra local, llega de verdad'), findsOneWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Entrar a Wammetka'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });

  testWidgets('Login valida correo vacío', (WidgetTester tester) async {
    await tester.pumpWidget(WammetkaApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Escribe un correo válido'), findsOneWidget);
    expect(find.text('Escribe tu contraseña'), findsOneWidget);
  });
}
