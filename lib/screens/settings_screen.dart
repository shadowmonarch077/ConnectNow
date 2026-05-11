import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const SettingsScreen({super.key, required this.onLogout});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _videoAutoOff = false;
  bool _audioAutoMute = false;

  void _showAbout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('About ConnectNow',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0',
                style: TextStyle(color: textSecondary, fontSize: 14)),
            SizedBox(height: 8),
            Text(
              'ConnectNow is a video meeting app powered by Agora RTC and Firebase.',
              style: TextStyle(
                  color: textSecondary, fontSize: 14, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(
                    color: primaryPurple, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showPrivacy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: dividerColor,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Privacy Policy',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              '• We only collect data necessary for authentication and meeting history.\n'
              '• Your Google profile (name, email, photo) is stored in Firebase.\n'
              '• Meeting room IDs are stored per-user in Firestore.\n'
              '• Video/audio streams go through Agora servers; we do not record them.\n'
              '• You can delete your data at any time by contacting support.',
              style: TextStyle(
                  color: textSecondary, fontSize: 14, height: 1.7),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: primaryPurple.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryPurple.withOpacity(0.4)),
                ),
                child: const Center(
                  child: Text('Close',
                      style: TextStyle(
                          color: primaryPurple, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: dividerColor,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Help & Support',
                  style: TextStyle(
                      color: textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _HelpItem(
                q: 'How do I start a meeting?',
                a: 'Tap "New Meeting" on the Home tab. A Room ID is generated automatically.',
              ),
              _HelpItem(
                q: 'How do I invite someone?',
                a: 'Share your Room ID with them. They tap "Join" and enter the ID.',
              ),
              _HelpItem(
                q: 'Why can\'t I join a meeting?',
                a: 'Make sure you entered the correct Room ID. Also check that camera and microphone permissions are granted in your device Settings.',
              ),
              _HelpItem(
                q: 'How do I mute/unmute?',
                a: 'Inside a call, use the Mic and Camera buttons at the bottom of the screen.',
              ),
              _HelpItem(
                q: 'Where is my meeting history?',
                a: 'Tap the "History" tab in the bottom navigation bar.',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: surfaceColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log Out',
            style: TextStyle(
                color: textPrimary, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text('Log Out',
                style: TextStyle(
                    color: redError, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthMethods().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: brandGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: user.photoURL != null
                      ? NetworkImage(user.photoURL!)
                      : null,
                  backgroundColor: Colors.white24,
                  child: user.photoURL == null
                      ? Text(
                          (user.displayName ?? 'G')[0].toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email ?? '',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Preferences section
          _SectionHeader('Preferences'),
          const SizedBox(height: 10),
          _ToggleTile(
            icon: Icons.notifications_none_rounded,
            label: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.volume_up_rounded,
            label: 'Meeting Sounds',
            value: _soundEnabled,
            onChanged: (v) => setState(() => _soundEnabled = v),
          ),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.videocam_off_outlined,
            label: 'Turn off video when joining',
            value: _videoAutoOff,
            onChanged: (v) => setState(() => _videoAutoOff = v),
          ),
          const SizedBox(height: 8),
          _ToggleTile(
            icon: Icons.mic_off_outlined,
            label: 'Mute mic when joining',
            value: _audioAutoMute,
            onChanged: (v) => setState(() => _audioAutoMute = v),
          ),

          const SizedBox(height: 24),

          _SectionHeader('Support'),
          const SizedBox(height: 10),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: _showPrivacy,
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: _showHelp,
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'About ConnectNow',
            onTap: _showAbout,
          ),

          const SizedBox(height: 24),

          // Logout
          GestureDetector(
            onTap: _confirmLogout,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: redError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: redError.withOpacity(0.4)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: redError, size: 20),
                  SizedBox(width: 10),
                  Text('Log Out',
                      style: TextStyle(
                          color: redError,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Text('ConnectNow v1.0.0',
              style: TextStyle(color: textHint, fontSize: 12)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
            color: textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? primaryPurple : textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(color: textPrimary, fontSize: 14)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: primaryPurple,
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: dividerColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryBlue, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style:
                      const TextStyle(color: textPrimary, fontSize: 14)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final String q;
  final String a;
  const _HelpItem({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q,
              style: const TextStyle(
                  color: textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(a,
              style: const TextStyle(
                  color: textSecondary, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}
