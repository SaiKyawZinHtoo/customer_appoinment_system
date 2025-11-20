import 'package:flutter/material.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/screen/customer/customer_list_information_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    NotificationRepository.instance.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    NotificationRepository.instance.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pending = NotificationRepository.instance.pending(daysAhead: 30);
    // Group by date
    final Map<DateTime, List> grouped = {};
    for (final p in pending) {
      final d = DateTime(
        p.appointmentDate.year,
        p.appointmentDate.month,
        p.appointmentDate.day,
      );
      grouped.putIfAbsent(d, () => []).add(p);
    }
    final sortedDates = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: grouped.isEmpty
            ? Center(
                child: Text(
                  'No upcoming appointments',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            : ListView.builder(
                itemCount: sortedDates.length,
                itemBuilder: (context, idx) {
                  final date = sortedDates[idx];
                  final items = grouped[date] as List;
                  final dateLabel = '${date.day}-${date.month}-${date.year}';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              dateLabel,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              NotificationRepository.instance.dismissForDate(
                                date,
                              );
                            },
                            child: const Text('Dismiss all'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...items.map<Widget>((c) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text('${c.name}'),
                            subtitle: Text('${c.phone}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'View',
                                  icon: const Icon(Icons.visibility),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            CustomerListInformationScreen(
                                              date: DateTime(
                                                c.appointmentDate.year,
                                                c.appointmentDate.month,
                                                c.appointmentDate.day,
                                              ),
                                              initialCustomerId: c.id,
                                            ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  tooltip: 'Dismiss',
                                  icon: const Icon(Icons.close),
                                  onPressed: () => NotificationRepository
                                      .instance
                                      .dismiss(c.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
