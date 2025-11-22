import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/screen/FAQ/faq_screen.dart';

void main() {
  testWidgets('FaqScreen renders and can search/filter', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: FaqScreen()));

    // FAQ title present
    expect(find.text('FAQ'), findsOneWidget);

    // Initially there should be ExpansionTile widgets (sample FAQs)
    expect(find.byType(ExpansionTile), findsWidgets);

    // Enter a query that yields no results
    final searchField = find.byType(TextFormField).first;
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'no-such-question-xyz');
    await tester.pumpAndSettle();

    expect(find.text('No results'), findsOneWidget);
  });

  testWidgets('FaqScreen Contact Support button navigates to ContactUs', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: FaqScreen()));

    final contactLabel = find.text('Contact Support');
    expect(contactLabel, findsOneWidget);
    await tester.tap(contactLabel);
    await tester.pumpAndSettle();

    // After navigation, Contact Us screen shows title
    expect(find.text('Contact Us'), findsWidgets);
  });
}
