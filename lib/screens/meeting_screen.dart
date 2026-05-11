import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../resources/agora_methods.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import 'join_meeting_screen.dart';
import 'schedule_meeting_screen.dart';

class MeetingScreen extends StatelessWidget {
  MeetingScreen({super.key});

  final AgoraMethods _agoraMethods = AgoraMethods();
  final AuthMethods _authMethods = AuthMethods();

  String _generateRoomId() {
    final rng = Random();
    return (rng.nextInt(90000000) + 10000000).toString();
  }

  void _createNewMeeting(BuildContext context) {
    final roomId = _generateRoomId();
    _agoraMethods.createMeeting(
      context: context,
      channelName: roomId,
      isAudioMuted: false,
      isVideoMuted: false,
    );
  }

  void _joinMeeting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JoinMeetingScreen()),
    );
  }

  void _scheduleMeeting(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScheduleMeetingScreen()),
    );
  }

  void _shareScreen(BuildContext context) {
    // Show info sheet — screen share requires a live call
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: dividerColor,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF34D399)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.screen_share_rounded,
                  color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Screen Share',
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start or join a meeting first, then use the screen share button inside the call.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _createNewMeeting(context);
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF065F46), Color(0xFF34D399)]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text('Start a Meeting Now',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authMethods.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Welcome Banner ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: brandGradient,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: primaryPurple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
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
                                  fontSize: 18),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Good day! 👋',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                          Text(
                            user.displayName ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Ready to connect?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Start or join a secure video meeting.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Quick Actions',
            style: TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.video_call_rounded,
                  label: 'New Meeting',
                  sublabel: 'Start instantly',
                  gradient: brandGradient,
                  onTap: () => _createNewMeeting(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.add_link_rounded,
                  label: 'Join',
                  sublabel: 'Enter room ID',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0066FF), Color(0xFF00C2FF)],
                  ),
                  onTap: () => _joinMeeting(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.calendar_month_rounded,
                  label: 'Schedule',
                  sublabel: 'Plan ahead',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B21A8), Color(0xFFA855F7)],
                  ),
                  onTap: () => _scheduleMeeting(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionCard(
                  icon: Icons.screen_share_rounded,
                  label: 'Share Screen',
                  sublabel: 'Present ideas',
                  gradient: const LinearGradient(
                    colors: [Color(0xFF065F46), Color(0xFF34D399)],
                  ),
                  onTap: () => _shareScreen(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Tips',
            style: TextStyle(
              color: textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const _TipCard(
            icon: Icons.copy_rounded,
            text: 'Share your Room ID with others to invite them to your meeting.',
          ),
          const SizedBox(height: 10),
          const _TipCard(
            icon: Icons.security_rounded,
            text: 'All meetings are end-to-end encrypted via Agora RTC.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(sublabel,
                style: const TextStyle(color: textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryPurple, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    color: textSecondary, fontSize: 13, height: 1.4)),
          ),
        ],
      ),
    );
  }
}
