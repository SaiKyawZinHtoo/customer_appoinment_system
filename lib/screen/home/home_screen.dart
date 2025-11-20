import 'package:flutter/material.dart';
import 'package:customer_appointment_system/screen/appoinment/appoinment_screen.dart';
import 'package:customer_appointment_system/screen/customer/customer_information_screen.dart';
import 'package:customer_appointment_system/screen/contactUs/contact_us_screen.dart';
import 'package:customer_appointment_system/screen/FAQ/faq_screen.dart';
import 'package:customer_appointment_system/screen/aboutUs/about_us_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<_TileData> _tiles = const [
    _TileData('Appointment', Icons.event),
    _TileData('Customer', Icons.people),
    _TileData('About Us', Icons.info_outline),
    _TileData('Contact Us', Icons.phone),
    _TileData('FAQ', Icons.help_outline),
    _TileData('Notification', Icons.notifications),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Appointment System'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'Eng',
                items: const [
                  DropdownMenuItem(value: 'Eng', child: Text('Eng')),
                  DropdownMenuItem(value: 'My', child: Text('မြန်မာ')),
                ],
                onChanged: (value) {},
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
                dropdownColor: theme.colorScheme.surface,
                iconEnabledColor: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: _tiles.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final item = _tiles[index];
                  return _ActionTile(
                    label: item.title,
                    icon: item.icon,
                    onTap: () {
                      if (item.title == 'Appointment') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AppoinmentScreen(),
                          ),
                        );
                      } else if (item.title == 'Customer') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                const CustomerInformationScreen(),
                          ),
                        );
                      } else if (item.title == 'Contact Us') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ContactUsScreen(),
                          ),
                        );
                      } else if (item.title == 'About Us') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AboutUsScreen(),
                          ),
                        );
                      } else if (item.title == 'FAQ') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FaqScreen(),
                          ),
                        );
                      } else {
                        // For other tiles, just show a placeholder route for now
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${item.title} not implemented'),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          // Navigate when Contact Us or About Us are tapped in bottom nav.
          if (i == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            );
          } else if (i == 2) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutUsScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact Us',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'About Us',
          ),
        ],
      ),
    );
  }
}

class _TileData {
  final String title;
  final IconData icon;
  const _TileData(this.title, this.icon);
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  // ignore: use_super_parameters
  const _ActionTile({
    Key? key,
    required this.label,
    required this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color bgColor = theme.colorScheme.secondary;
    final Color fgColor = theme.colorScheme.onSecondary;
    return Material(
      elevation: 4,
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: fgColor, size: 48),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(color: fgColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
