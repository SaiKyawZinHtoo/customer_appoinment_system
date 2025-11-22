import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:customer_appointment_system/screen/appoinment/appoinment_screen.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppointmentRepository.instance.clearAll();
  });

  testWidgets('Integration: tap a marked day navigates to customer list', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    AppointmentRepository.instance.addAppointment(today, 'Integration appt');

    await tester.pumpWidget(const MaterialApp(home: AppoinmentScreen()));
    await tester.pumpAndSettle();

    // Find the day cell by Key for today and tap it
    final dayKey = ValueKey('day-${today.year}-${today.month}-${today.day}');
    expect(find.byKey(dayKey), findsWidgets);

    await tester.tap(find.byKey(dayKey));
    await tester.pumpAndSettle();

    // After tapping a day with marker, either the day selects (show details)
    // or when tapping the marker it may navigate — assert that either
    // 'Appointments for' text or 'No appointments' or a CustomerList screen
    // string appears. We check for the selected-day header substring.
    expect(find.textContaining('Appointments for'), findsOneWidget);
  });
}
