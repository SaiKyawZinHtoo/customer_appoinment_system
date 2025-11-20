import 'package:flutter/foundation.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

/// Simple in-memory notification repository.
///
/// Observes the `AppointmentRepository` and exposes a list of pending
/// notifications (appointments that are not completed and not dismissed).
class NotificationRepository extends ChangeNotifier {
  NotificationRepository._internal() {
    AppointmentRepository.instance.addListener(_onAppointmentsChanged);
  }

  static final NotificationRepository instance =
      NotificationRepository._internal();

  final Set<String> _dismissed = <String>{};

  DateTime _nowDateOnly() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Return pending notifications for the next [daysAhead] days (inclusive).
  List<Customer> pending({int daysAhead = 7}) {
    final from = _nowDateOnly();
    final to = from.add(Duration(days: daysAhead));
    final repo = AppointmentRepository.instance;
    // Flatten all appointments from the repo
    final all = repo.getAll().values.expand((l) => l);
    return all.where((c) {
      if (c.completed == true) return false;
      final d = DateTime(
        c.appointmentDate.year,
        c.appointmentDate.month,
        c.appointmentDate.day,
      );
      if (d.isBefore(from) || d.isAfter(to)) return false;
      if (_dismissed.contains(c.id)) return false;
      return true;
    }).toList()..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
  }

  /// Number of pending notifications in next [daysAhead] days.
  int pendingCount({int daysAhead = 7}) => pending(daysAhead: daysAhead).length;

  /// Dismiss a single notification for a customer id.
  void dismiss(String customerId) {
    _dismissed.add(customerId);
    notifyListeners();
  }

  /// Dismiss all notifications for a specific date.
  void dismissForDate(DateTime date) {
    final keyDate = DateTime(date.year, date.month, date.day);
    final repo = AppointmentRepository.instance;
    for (final c in repo.getForDate(date)) {
      final d = DateTime(
        c.appointmentDate.year,
        c.appointmentDate.month,
        c.appointmentDate.day,
      );
      if (d == keyDate) _dismissed.add(c.id);
    }
    notifyListeners();
  }

  /// Clear all dismissed markers.
  void clearDismissed() {
    _dismissed.clear();
    notifyListeners();
  }

  void _onAppointmentsChanged() => notifyListeners();
}
