import 'dart:io';

import 'package:flutter/material.dart';
import 'package:customer_appointment_system/model/customer.dart';

typedef VoidCustomerCallback = void Function();

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onCall,
    this.onToggleCompleted,
  });

  final Customer customer;
  final VoidCustomerCallback onTap;
  final VoidCustomerCallback onCall;
  final VoidCustomerCallback? onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = customer;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar / photo
              if (c.photoPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(c.photoPath!),
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                )
              else
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person, size: 28),
                ),
              const SizedBox(width: 12),
              // Main info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(c.phone, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Appointment: ${_formatDateDisplay(c.appointmentDate)}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    if (c.location != null && c.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                c.location!,
                                style: theme.textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Chip(
                      label: Text((c.completed == true) ? 'Done' : 'Remaining'),
                      backgroundColor: (c.completed == true)
                          ? Colors.green[50]
                          : Colors.orange[50],
                      labelStyle: TextStyle(
                        color: (c.completed == true)
                            ? Colors.green[800]
                            : Colors.orange[800],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Actions column
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.phone, color: Colors.green),
                    iconSize: 26,
                    onPressed: onCall,
                  ),
                  const SizedBox(height: 6),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      (c.completed == true)
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: (c.completed == true) ? Colors.green : Colors.grey,
                    ),
                    iconSize: 22,
                    onPressed: onToggleCompleted,
                    tooltip: (c.completed == true)
                        ? 'Completed (cannot undo)'
                        : 'Mark as done',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateDisplay(DateTime? d) {
    if (d == null) return 'N/A';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = d.day;
    final monthName = months[d.month - 1];
    final year = d.year;
    return '$day $monthName $year';
  }
}
