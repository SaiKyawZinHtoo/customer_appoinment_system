import 'package:flutter/material.dart';
import 'package:customer_appointment_system/screen/appoinment/appoinment_screen.dart';
import 'package:customer_appointment_system/screen/customer/customer_information_screen.dart';
import 'package:customer_appointment_system/screen/contactUs/contact_us_screen.dart';
import 'package:customer_appointment_system/screen/FAQ/faq_screen.dart';
import 'package:customer_appointment_system/screen/aboutUs/about_us_screen.dart';
import 'package:customer_appointment_system/screen/notification/notification_screen.dart';
import 'package:customer_appointment_system/service/notification_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _lang = 'Eng';

  @override
  void initState() {
    super.initState();
    NotificationRepository.instance.addListener(_onNotifChanged);
  }

  @override
  void dispose() {
    NotificationRepository.instance.removeListener(_onNotifChanged);
    super.dispose();
  }

  void _onNotifChanged() => setState(() {});
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
    final int totalNotifs = NotificationRepository.instance.pendingCount(
      daysAhead: 30,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Customer Appointment System'),
            if (totalNotifs > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalNotifs',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: PopupMenuButton<String>(
              tooltip: 'Language',
              onSelected: (v) => setState(() => _lang = v),
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'Eng', child: Text('Eng')),
                PopupMenuItem(value: 'My', child: Text('မြန်မာ')),
              ],
              // child gives a compact, stable UI without a large overlay
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      _lang,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ),
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
                  // Notification tile: render badge inside the tile (keeps Card+InkWell)
                  if (item.title == 'Notification') {
                    final int count = NotificationRepository.instance
                        .pendingCount();
                    return _ActionTile(
                      label: item.title,
                      icon: item.icon,
                      badgeCount: count > 0 ? count : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NotificationScreen(),
                          ),
                        );
                      },
                    );
                  }

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
        onTap: (i) async {
          // show selection immediately
          setState(() => _currentIndex = i);
          // Navigate when Contact Us or About Us are tapped in bottom nav.
          if (i == 1) {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            );
            // when returning, reset to Home selection
            setState(() => _currentIndex = 0);
          } else if (i == 2) {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AboutUsScreen()),
            );
            setState(() => _currentIndex = 0);
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
  final int? badgeCount;
  // ignore: use_super_parameters
  const _ActionTile({
    Key? key,
    required this.label,
    required this.icon,
    this.onTap,
    this.badgeCount,
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
        child: Stack(
          children: [
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(icon, color: fgColor, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: fgColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (badgeCount != null && badgeCount! > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 24,
                    minHeight: 24,
                  ),
                  child: Center(
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
