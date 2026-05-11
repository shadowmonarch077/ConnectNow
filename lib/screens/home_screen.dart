import 'package:flutter/material.dart';
import '../resources/auth_methods.dart';
import '../screens/history_meeting_screen.dart';
import '../screens/meeting_screen.dart';
import '../screens/login_screen.dart';
import '../screens/contacts_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.history_rounded, activeIcon: Icons.history_rounded, label: 'History'),
    _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Contacts'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      MeetingScreen(),
      const HistoryMeetingScreen(),
      const ContactsScreen(),
      SettingsScreen(onLogout: _logout),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (b) => brandGradient.createShader(b),
          child: const Text(
            'ConnectNow',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AuthMethods().user.photoURL != null
                  ? NetworkImage(AuthMethods().user.photoURL!)
                  : null,
              backgroundColor: primaryPurple,
              child: AuthMethods().user.photoURL == null
                  ? Text(
                      (AuthMethods().user.displayName ?? 'G')[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    )
                  : null,
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _page, children: pages),
      bottomNavigationBar: _BottomNav(
        currentIndex: _page,
        items: _navItems,
        onTap: (i) => setState(() => _page = i),
      ),
    );
  }

  void _logout() {
    AuthMethods().signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: const Border(top: BorderSide(color: dividerColor)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 4,
        top: 8,
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (active)
                    ShaderMask(
                      shaderCallback: (b) => brandGradient.createShader(b),
                      child: Icon(items[i].activeIcon,
                          color: Colors.white, size: 24),
                    )
                  else
                    Icon(items[i].icon, color: textSecondary, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    items[i].label,
                    style: TextStyle(
                      color: active ? primaryBlue : textSecondary,
                      fontSize: 11,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem(
      {required this.icon, required this.activeIcon, required this.label});
}
