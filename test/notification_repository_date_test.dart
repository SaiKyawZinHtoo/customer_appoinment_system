import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
    NotificationRepository.instance.clearDismissed();
  });

  test('dismissForDate clears notifications only for that date', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final a = Customer(
      id: 'd1',
      name: 'A',
      phone: '0910000001',
      gender: 'Unknown',
      appointmentDate: today,
    );
    final b = Customer(
      id: 'd2',
      name: 'B',
      phone: '0910000002',
      gender: 'Unknown',
      appointmentDate: today,
    );
    final c = Customer(
      id: 'd3',
      name: 'C',
      phone: '0910000003',
      gender: 'Unknown',
      appointmentDate: tomorrow,
    );

    AppointmentRepository.instance.addCustomer(a);
    AppointmentRepository.instance.addCustomer(b);
    AppointmentRepository.instance.addCustomer(c);

    // initially 3 pending (within default 7 days)
    expect(NotificationRepository.instance.pendingCount(), 3);

    // dismiss today's date
    NotificationRepository.instance.dismissForDate(today);

    // only tomorrow's should remain
    expect(NotificationRepository.instance.pendingCount(), 1);
  });
}
