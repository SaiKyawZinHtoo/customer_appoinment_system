import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/screen/appoinment/appoinment_screen.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
  });

  testWidgets('AppoinmentScreen shows marker for day with appointment', (
    WidgetTester tester,
  ) async {
    // ensure grid builds by providing larger viewport
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // add a simple appointment using addAppointment helper
    AppointmentRepository.instance.addAppointment(today, 'Test appt');

    await tester.pumpWidget(const MaterialApp(home: AppoinmentScreen()));
    await tester.pumpAndSettle();

    // The marker shows the count '1' inside the day cell; find the day cell by Key
    final dayKey = ValueKey('day-${today.year}-${today.month}-${today.day}');
    expect(find.byKey(dayKey), findsWidgets);
    expect(
      find.descendant(of: find.byKey(dayKey), matching: find.text('1')),
      findsOneWidget,
    );

    // cleanup test view overrides
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
