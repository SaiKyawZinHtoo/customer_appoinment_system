import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
    NotificationRepository.instance.clearDismissed();
  });

  test('pending respects daysAhead boundary', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inThree = today.add(const Duration(days: 3));
    final inTen = today.add(const Duration(days: 10));

    final a = Customer(
      id: 'p1',
      name: 'A',
      phone: '',
      gender: 'U',
      appointmentDate: inThree,
    );
    final b = Customer(
      id: 'p2',
      name: 'B',
      phone: '',
      gender: 'U',
      appointmentDate: inTen,
    );

    AppointmentRepository.instance.addCustomer(a);
    AppointmentRepository.instance.addCustomer(b);

    // default daysAhead is 7, so only 'a' should be returned
    expect(NotificationRepository.instance.pendingCount(), 1);
    // increasing daysAhead to 14 includes both
    expect(NotificationRepository.instance.pendingCount(daysAhead: 14), 2);
  });
}
