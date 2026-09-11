import 'package:flutter_test/flutter_test.dart';

import 'package:wammetka/app.dart';

void main() {
  testWidgets('Splash muestra marca Wammetka', (WidgetTester tester) async {
    await tester.pumpWidget(const WammetkaApp());
    expect(find.text('Wammetka'), findsOneWidget);
    expect(find.text('Compra local, llega de verdad'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('Entrar a Wammetka'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
