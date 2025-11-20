import 'dart:io';

import 'package:flutter/material.dart';
import 'package:customer_appointment_system/service/appointment_repository.dart';
import 'package:customer_appointment_system/model/customer.dart';
import 'package:customer_appointment_system/screen/customer/customer_information_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerListInformationScreen extends StatefulWidget {
  const CustomerListInformationScreen({
    super.key,
    required this.date,
    this.initialCustomerId,
  });

  final DateTime date;
  final String? initialCustomerId;

  @override
  State<CustomerListInformationScreen> createState() =>
      _CustomerListInformationScreenState();
}

class _CustomerListInformationScreenState
    extends State<CustomerListInformationScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _genderFilter = 'All';
  @override
  void initState() {
    super.initState();
    AppointmentRepository.instance.addListener(_onRepoChanged);
    _searchController.addListener(
      () => setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      }),
    );
  }

  @override
  void dispose() {
    AppointmentRepository.instance.removeListener(_onRepoChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRepoChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final customers = AppointmentRepository.instance.getForDate(widget.date);
    final theme = Theme.of(context);
    // Apply search & filter
    final filteredCustomers = customers.where((c) {
      final q = _searchQuery;
      final matchesQuery =
          q.isEmpty ||
          c.name.toLowerCase().contains(q) ||
          c.phone.toLowerCase().contains(q);
      final matchesGender =
          _genderFilter == 'All' ||
          c.gender.toLowerCase() == _genderFilter.toLowerCase();
      return matchesQuery && matchesGender;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Customers — ${widget.date.year}-${widget.date.month}-${widget.date.day}',
        ),
        centerTitle: true,
      ),
      floatingActionButton: Builder(
        builder: (fabCtx) {
          return FloatingActionButton.extended(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(fabCtx);
              final result = await Navigator.of(fabCtx).push<Customer>(
                MaterialPageRoute(
                  builder: (_) => CustomerInformationScreen(
                    initialAppointmentDate: widget.date,
                  ),
                ),
              );
              if (!mounted) return;
              if (result != null) {
                messenger.showSnackBar(
                  SnackBar(content: Text('Added ${result.name}')),
                );
                // Repository notifies listeners, the list will refresh.
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          );
        },
      ),
      body: Column(
        children: [
          // Search and filter row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search by name or phone',
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: _genderFilter,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'All', child: Text('All')),
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Unknown', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() {
                      _genderFilter = v ?? 'All';
                    }),
                  ),
                ),
              ],
            ),
          ),
          // Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Showing ${filteredCustomers.length} of ${customers.length}',
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredCustomers.isEmpty
                ? Center(child: Text('No customers for this date'))
                : ListView.separated(
                    itemCount: filteredCustomers.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final c = filteredCustomers[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showCustomerDetail(context, c),
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
                                  CircleAvatar(
                                    radius: 28,
                                    child: const Icon(Icons.person, size: 28),
                                  ),
                                const SizedBox(width: 12),
                                // Main info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        c.phone,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Appointment: ${_formatDateDisplay(c.appointmentDate)}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                        ),
                                      ),
                                      if (c.location != null &&
                                          c.location!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
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
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      const SizedBox(height: 8),
                                      // Result chip
                                      Chip(
                                        label: Text(
                                          (c.completed == true)
                                              ? 'Done'
                                              : 'Remaining',
                                        ),
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
                                      icon: const Icon(
                                        Icons.phone,
                                        color: Colors.green,
                                      ),
                                      iconSize: 26,
                                      onPressed: () => _tryCall(c.phone),
                                    ),
                                    const SizedBox(height: 6),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: Icon(
                                        (c.completed == true)
                                            ? Icons.check_circle
                                            : Icons.circle_outlined,
                                        color: (c.completed == true)
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      iconSize: 22,
                                      onPressed: () => AppointmentRepository
                                          .instance
                                          .setCustomerCompleted(
                                            widget.date,
                                            c.id,
                                            !(c.completed == true),
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetail(BuildContext context, Customer c) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final maxWidth = MediaQuery.of(ctx).size.width * 0.85;
        return AlertDialog(
          title: Text(c.name),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (c.photoPath != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(c.photoPath!),
                          width: maxWidth,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Text('Phone: ${c.phone}'),
                  const SizedBox(height: 6),
                  if (c.location != null && c.location!.isNotEmpty)
                    Text('Location: ${c.location}'),
                  const SizedBox(height: 6),
                  Text('Gender: ${c.gender}'),
                  const SizedBox(height: 6),
                  Text('DOB: ${_formatDateDisplay(c.dob)}'),
                  const SizedBox(height: 6),
                  Text('Appointment: ${_formatDateDisplay(c.appointmentDate)}'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Result: ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        (c.completed == true) ? 'Done' : 'Remaining',
                        style: TextStyle(
                          color: (c.completed == true)
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Delete this customer
                AppointmentRepository.instance.removeCustomer(
                  widget.date,
                  c.id,
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Format a date as 'D Mon YYYY' (e.g. '20 Nov 2025').
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

  Future<void> _tryCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        messenger.showSnackBar(
          const SnackBar(content: Text('Cannot place call on this device')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Error launching dialer: $e')),
      );
    }
  }
}
