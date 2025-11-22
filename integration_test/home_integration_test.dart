import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:customer_appointment_system/screen/home/home_screen.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppointmentRepository.instance.clearAll();
  });

  testWidgets('Integration: tap Notification tile navigates to Notifications', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final c = Customer(
      id: 'i1',
      name: 'Integration User',
      phone: '0912222222',
      gender: 'Unknown',
      appointmentDate: today,
    );
    AppointmentRepository.instance.addCustomer(c);

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('tile-Notification')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('tile-Notification')));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
  });
}
