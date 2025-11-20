import 'package:flutter/material.dart';
import 'package:customer_appointment_system/widget/app_text_field.dart';
import 'package:customer_appointment_system/widget/color.dart';
import 'package:customer_appointment_system/screen/contactUs/contact_us_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const List<Map<String, String>> _sampleFaqs = [
    {
      'q': 'How do I add a customer appointment?',
      'a':
          'Tap the Add button on the Customer form or use the calendar FAB to create an appointment for a selected date.',
    },
    {
      'q': 'Can I attach a photo to a customer?',
      'a':
          'Yes — use the photo area on the Customer Information form to pick or take a photo. The app stores a local file path for the image.',
    },
    {
      'q': 'How do I mark an appointment as completed?',
      'a':
          'Open the customer list for the appointment date and tap the completion icon to toggle Done/Remaining.',
    },
    {
      'q': 'Where is my data stored?',
      'a':
          'Currently the app stores data in memory during runtime. To persist across restarts we can add local storage (Hive or sqflite).',
    },
    {
      'q': 'How do I contact support?',
      'a':
          'Use the Contact Us screen (tap the button below or via Home → Contact Us).',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _sampleFaqs.where((f) {
      if (_query.isEmpty) return true;
      return f['q']!.toLowerCase().contains(_query) ||
          f['a']!.toLowerCase().contains(_query);
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('FAQ'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: AppTextField(
              controller: _searchController,
              hintText: 'Search FAQs',
              leadingIcon: const Icon(Icons.search),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text('No results', style: theme.textTheme.bodyLarge),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      return ExpansionTile(
                        title: Text(item['q']!),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12,
                            ),
                            child: Text(
                              item['a']!,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContactUsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.contact_mail),
                    label: const Text('Contact Support'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
