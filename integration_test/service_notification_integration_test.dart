import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    AppointmentRepository.instance.clearAll();
    NotificationRepository.instance.clearDismissed();
  });

  testWidgets(
    'service integration: adding appointment updates NotificationRepository',
    (WidgetTester tester) async {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      expect(NotificationRepository.instance.pendingCount(), 0);

      final c = Customer(
        id: 's1',
        name: 'Service Integration',
        phone: '',
        gender: 'U',
        appointmentDate: today,
      );
      AppointmentRepository.instance.addCustomer(c);

      // NotificationRepository listens to AppointmentRepository and should update
      expect(NotificationRepository.instance.pendingCount(), 1);

      NotificationRepository.instance.dismiss('s1');
      expect(NotificationRepository.instance.pendingCount(), 0);
    },
  );
}
