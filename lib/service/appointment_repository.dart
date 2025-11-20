import 'package:flutter/foundation.dart';
import 'package:customer_appointment_system/model/customer.dart';

class AppointmentRepository extends ChangeNotifier {
  AppointmentRepository._internal() {
    // Seed a couple of example customers for visual/debug purposes
    final c1 = Customer(
      id: 'seed-1',
      name: 'John Doe',
      phone: '0912345678',
      gender: 'Male',
      appointmentDate: DateTime(2025, 1, 3),
      dob: DateTime(1990, 6, 15),
      photoPath: null,
    );
    final c2 = Customer(
      id: 'seed-2',
      name: 'Supplier A',
      phone: '0987654321',
      gender: 'Male',
      appointmentDate: DateTime(2025, 1, 3),
      dob: null,
      photoPath: null,
    );
    _appointments[_dateKey(c1.appointmentDate)] = [c1, c2];
  }

  static final AppointmentRepository instance =
      AppointmentRepository._internal();

  // Appointments keyed by date string (yyyy-MM-dd)
  final Map<String, List<Customer>> _appointments = {};

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Returns a shallow immutable view of all appointments keyed by date.
  Map<String, List<Customer>> getAll() => Map.unmodifiable(_appointments);

  /// Returns the customers for [d] (empty list if none).
  List<Customer> getForDate(DateTime d) =>
      List.unmodifiable(_appointments[_dateKey(d)] ?? []);

  int countForDate(DateTime d) => (_appointments[_dateKey(d)] ?? []).length;

  bool hasAppointmentsForDate(DateTime d) =>
      _appointments.containsKey(_dateKey(d));

  /// Add a fully-formed [customer] to the repository for its appointment date.
  void addCustomer(Customer customer) {
    final key = _dateKey(customer.appointmentDate);
    _appointments.putIfAbsent(key, () => []).add(customer);
    notifyListeners();
  }

  /// Mark a customer as completed or not.
  void setCustomerCompleted(DateTime d, String customerId, bool completed) {
    final key = _dateKey(d);
    final list = _appointments[key];
    if (list == null) return;
    for (var i = 0; i < list.length; i++) {
      final c = list[i];
      if (c.id == customerId) {
        list[i] = Customer(
          id: c.id,
          name: c.name,
          phone: c.phone,
          gender: c.gender,
          appointmentDate: c.appointmentDate,
          dob: c.dob,
          photoPath: c.photoPath,
          location: c.location,
          completed: completed,
        );
        notifyListeners();
        return;
      }
    }
  }

  /// Backwards-compatible helper: create a simple customer record using a
  /// title string (name will be the title and phone left empty).
  void addAppointment(DateTime d, String title) {
    final customer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: title,
      phone: '',
      gender: 'Unknown',
      appointmentDate: d,
      dob: null,
      photoPath: null,
    );
    addCustomer(customer);
  }

  /// Remove a customer by id for a given date.
  void removeCustomer(DateTime d, String customerId) {
    final key = _dateKey(d);
    final list = _appointments[key];
    if (list == null) return;
    list.removeWhere((c) => c.id == customerId);
    if (list.isEmpty) _appointments.remove(key);
    notifyListeners();
  }

  void clearAll() {
    _appointments.clear();
    notifyListeners();
  }
}
