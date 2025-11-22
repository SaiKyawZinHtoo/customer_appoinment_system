import 'package:flutter_test/flutter_test.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  setUp(() {
    AppointmentRepository.instance.clearAll();
  });

  test('setCustomerCompleted toggles completed flag', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final c = Customer(
      id: 'c1',
      name: 'Complete Me',
      phone: '',
      gender: 'Unknown',
      appointmentDate: today,
    );
    AppointmentRepository.instance.addCustomer(c);

    expect(
      AppointmentRepository.instance.getForDate(today).first.completed,
      isFalse,
    );

    AppointmentRepository.instance.setCustomerCompleted(today, 'c1', true);
    expect(
      AppointmentRepository.instance.getForDate(today).first.completed,
      isTrue,
    );
  });

  test('removeCustomer removes and clears date key', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final c = Customer(
      id: 'r1',
      name: 'Remove Me',
      phone: '',
      gender: 'Unknown',
      appointmentDate: today,
    );
    AppointmentRepository.instance.addCustomer(c);

    expect(
      AppointmentRepository.instance.hasAppointmentsForDate(today),
      isTrue,
    );

    AppointmentRepository.instance.removeCustomer(today, 'r1');
    expect(
      AppointmentRepository.instance.hasAppointmentsForDate(today),
      isFalse,
    );
  });

  test('getAll returns unmodifiable map', () {
    final m = AppointmentRepository.instance.getAll();
    expect(() => m.clear(), throwsA(isA<UnsupportedError>()));
  });
}
