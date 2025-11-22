import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/screen/notification/notification_screen.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
    NotificationRepository.instance.clearDismissed();
  });

  testWidgets('NotificationScreen shows items and dismiss removes them', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final c = Customer(
      id: 'n1',
      name: 'Notify User',
      phone: '0913333333',
      gender: 'Unknown',
      appointmentDate: today,
    );
    AppointmentRepository.instance.addCustomer(c);

    await tester.pumpWidget(const MaterialApp(home: NotificationScreen()));
    await tester.pumpAndSettle();

    // The notification item should be present (find by visible text)
    final itemText = find.text('Notify User');
    expect(itemText, findsOneWidget);

    // Find the ListTile that contains the text and then find the Dismiss icon inside it
    final listTileFinder = find.ancestor(
      of: itemText,
      matching: find.byType(ListTile),
    );
    expect(listTileFinder, findsOneWidget);

    final dismissFinder = find.descendant(
      of: listTileFinder,
      matching: find.byIcon(Icons.close),
    );
    expect(dismissFinder, findsOneWidget);
    await tester.tap(dismissFinder);
    // allow the dismissal animation to run and repository to notify
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // Now the list should be empty
    expect(find.text('No upcoming appointments'), findsOneWidget);
    expect(NotificationRepository.instance.pendingCount(), 0);
  });
}
