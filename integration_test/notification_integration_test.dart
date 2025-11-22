import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/screen/notification/notification_screen.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppointmentRepository.instance.clearAll();
  });

  testWidgets('Notification integration: view and dismiss flows', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final c = Customer(
      id: 'in1',
      name: 'Integration Notify',
      phone: '0914444444',
      gender: 'Unknown',
      appointmentDate: today,
    );

    AppointmentRepository.instance.addCustomer(c);

    await tester.pumpWidget(const MaterialApp(home: NotificationScreen()));
    await tester.pumpAndSettle();

    // Ensure the item is visible and use the view button to navigate
    final itemText = find.text('Integration Notify');
    expect(itemText, findsOneWidget);

    final itemFinder = find.ancestor(
      of: itemText,
      matching: find.byType(ListTile),
    );
    expect(itemFinder, findsOneWidget);

    final viewFinder = find.descendant(
      of: itemFinder,
      matching: find.byIcon(Icons.visibility),
    );
    expect(viewFinder, findsOneWidget);
    await tester.tap(viewFinder);
    await tester.pumpAndSettle();

    // After viewing, we should be on the customer list screen (which shows the customer's name)
    expect(find.textContaining('Integration Notify'), findsWidgets);

    // Go back and dismiss the notification
    await tester.pageBack();
    await tester.pumpAndSettle();

    final dismissFinder = find.descendant(
      of: itemFinder,
      matching: find.byIcon(Icons.close),
    );
    expect(dismissFinder, findsOneWidget);
    await tester.tap(dismissFinder);
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // Now empty
    expect(find.text('No upcoming appointments'), findsOneWidget);
  });
}
