import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:customer_appointment_system/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Navigate from Home to About Us', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final aboutTile = find.byKey(const ValueKey('tile-About-Us'));
    expect(aboutTile, findsOneWidget);
    await tester.tap(aboutTile);
    await tester.pumpAndSettle();

    expect(find.text('About Us'), findsOneWidget);
  });

  testWidgets('Navigate from Home to Contact Us', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final contactTile = find.byKey(const ValueKey('tile-Contact-Us'));
    expect(contactTile, findsOneWidget);
    await tester.tap(contactTile);
    await tester.pumpAndSettle();

    expect(find.text('Contact Us'), findsOneWidget);
  });

  testWidgets('Navigate from Home to FAQ', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final faqTile = find.byKey(const ValueKey('tile-FAQ'));
    expect(faqTile, findsOneWidget);
    await tester.tap(faqTile);
    await tester.pumpAndSettle();

    expect(find.text('FAQ'), findsOneWidget);
  });
}
