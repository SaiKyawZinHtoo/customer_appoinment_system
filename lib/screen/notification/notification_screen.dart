import 'package:flutter/material.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';
import 'package:customer_appointment_system/screen/customer/customer_list_information_screen.dart';
import 'package:customer_appointment_system/model/customer.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // We use AnimatedBuilder in build() to listen to NotificationRepository
  // so we don't need to manually add/remove listeners in initState.

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: NotificationRepository.instance,
      builder: (context, _) {
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
                      final dateLabel =
                          '${date.day}-${date.month}-${date.year}';
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
                                  NotificationRepository.instance
                                      .dismissForDate(date);
                                },
                                child: const Text('Dismiss all'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...items.map<Widget>((c) {
                            // Use an animated NotificationItem so dismiss animates
                            return NotificationItem(
                              key: ValueKey(c.id),
                              customer: c as Customer,
                            );
                          }),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}

// Animated notification card widget that fades & collapses when dismissed.
class NotificationItem extends StatefulWidget {
  final Customer customer;
  const NotificationItem({super.key, required this.customer});

  @override
  State<NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<NotificationItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _size;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _size = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut));
    _fade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctl, curve: Curves.easeInOut));
    // play entrance animation
    // start from collapsed and expand quickly for subtle entrance
    _ctl.value = 0.0;
    _ctl.animateTo(1.0, duration: const Duration(milliseconds: 200));
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    // animate collapse, then mark dismissed in repository
    await _ctl.animateTo(0.0);
    NotificationRepository.instance.dismiss(widget.customer.id);
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _size,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _fade,
        child: Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(widget.customer.name),
            subtitle: Text(widget.customer.phone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'View',
                  icon: const Icon(Icons.visibility),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CustomerListInformationScreen(
                          date: DateTime(
                            widget.customer.appointmentDate.year,
                            widget.customer.appointmentDate.month,
                            widget.customer.appointmentDate.day,
                          ),
                          initialCustomerId: widget.customer.id,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  tooltip: 'Dismiss',
                  icon: const Icon(Icons.close),
                  onPressed: _dismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
