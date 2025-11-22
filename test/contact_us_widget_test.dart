import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/screen/contactUs/contact_us_screen.dart';

void main() {
  testWidgets('ContactUsScreen shows validation errors when empty', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ContactUsScreen()));

    expect(find.text('Contact Us'), findsOneWidget);

    // Tap Send Message without filling fields
    final sendBtn = find.widgetWithText(ElevatedButton, 'Send Message');
    expect(sendBtn, findsOneWidget);

    await tester.tap(sendBtn);
    await tester.pumpAndSettle();

    // Validators should show errors for name, email and message
    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter an email'), findsOneWidget);
    expect(find.text('Please enter a message'), findsOneWidget);
  });

  testWidgets('ContactUsScreen shows Choose Image button when none picked', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ContactUsScreen()));

    // 'Choose Image' button exists
    expect(find.text('Choose Image'), findsOneWidget);
    expect(find.byIcon(Icons.attach_file), findsOneWidget);
  });
}
