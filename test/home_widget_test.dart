import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/screen/home/home_screen.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
    NotificationRepository.instance.clearDismissed();
  });

  testWidgets('HomeScreen renders tiles and shows notification badge', (
    WidgetTester tester,
  ) async {
    // Ensure the test viewport is large enough so GridView builds all tiles.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final c = Customer(
      id: 'w1',
      name: 'Widget User',
      phone: '0911111111',
      gender: 'Unknown',
      appointmentDate: today,
    );

    AppointmentRepository.instance.addCustomer(c);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    // Basic tiles present (found by Key)
    expect(find.byKey(const ValueKey('tile-Appointment')), findsOneWidget);
    expect(find.byKey(const ValueKey('tile-Customer')), findsOneWidget);
    expect(find.byKey(const ValueKey('tile-Notification')), findsOneWidget);

    // The notification badge should show '1' (inside the badge container)
    expect(find.byKey(const ValueKey('badge-notification')), findsOneWidget);

    // Tap the Notification tile and ensure navigation to NotificationScreen
    await tester.tap(find.byKey(const ValueKey('tile-Notification')));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);

    // restore window test values
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
