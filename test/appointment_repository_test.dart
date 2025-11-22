import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
  });

  test('addCustomer and getForDate behavior', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final c = Customer(
      id: 'a1',
      name: 'Repo User',
      phone: '0999999999',
      gender: 'Unknown',
      appointmentDate: today,
    );

    expect(AppointmentRepository.instance.countForDate(today), 0);

    AppointmentRepository.instance.addCustomer(c);

    expect(AppointmentRepository.instance.countForDate(today), 1);
    final list = AppointmentRepository.instance.getForDate(today);
    expect(list.any((e) => e.id == 'a1'), isTrue);
  });
}
