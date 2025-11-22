import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/screen/aboutUs/about_us_screen.dart';
import 'package:customer_appointment_system/screen/contactUs/contact_us_screen.dart';

void main() {
  testWidgets('AboutUsScreen renders and navigates to ContactUs', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AboutUsScreen()));

    // Title and main texts
    expect(find.text('About Us'), findsOneWidget);
    expect(find.text('Customer Appointment System'), findsOneWidget);

    // Circle avatar with app initials
    expect(find.byType(CircleAvatar), findsOneWidget);

    // Contact Us button exists inside About Us and navigates (use icon finder)
    // Tap the visible label text to trigger the button
    final contactLabel = find.text('Contact Us');
    expect(contactLabel, findsWidgets);
    await tester.tap(contactLabel.first);
    await tester.pumpAndSettle();

    // After navigation we should be on ContactUsScreen (title present)
    expect(find.byType(ContactUsScreen), findsOneWidget);
    expect(find.text('Contact Us'), findsWidgets);
  });
}
