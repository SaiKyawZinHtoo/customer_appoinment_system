import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
    NotificationRepository.instance.clearDismissed();
  });

  test('NotificationRepository pending and dismiss flow', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final c = Customer(
      id: 't1',
      name: 'Test User',
      phone: '0910000000',
      gender: 'Unknown',
      appointmentDate: today,
    );

    AppointmentRepository.instance.addCustomer(c);

    expect(NotificationRepository.instance.pendingCount(), 1);

    NotificationRepository.instance.dismiss('t1');

    expect(NotificationRepository.instance.pendingCount(), 0);
  });
}
