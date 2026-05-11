import 'package:flutter/material.dart';
import '../resources/agora_methods.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';

class JoinMeetingScreen extends StatefulWidget {
  const JoinMeetingScreen({super.key});

  @override
  State<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends State<JoinMeetingScreen> {
  final _roomController = TextEditingController();
  final _nameController = TextEditingController();
  final AgoraMethods _agoraMethods = AgoraMethods();
  bool _audioMuted = false;
  bool _videoMuted = false;

  @override
  void initState() {
    super.initState();
    _nameController.text =
        AuthMethods().user.displayName ?? '';
  }

  @override
  void dispose() {
    _roomController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _join() {
    if (_roomController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Room ID')),
      );
      return;
    }
    _agoraMethods.createMeeting(
      context: context,
      channelName: _roomController.text.trim(),
      isAudioMuted: _audioMuted,
      isVideoMuted: _videoMuted,
      customUsername: _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Join Meeting',
          style: TextStyle(
              color: textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // ── Room ID input ──
            _InputLabel('Room ID'),
            const SizedBox(height: 8),
            _GlassInput(
              controller: _roomController,
              hint: 'Enter 8-digit room ID',
              icon: Icons.meeting_room_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // ── Name input ──
            _InputLabel('Your Name'),
            const SizedBox(height: 8),
            _GlassInput(
              controller: _nameController,
              hint: 'Display name',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 28),

            // ── Toggles ──
            _ToggleTile(
              icon: Icons.mic_off_outlined,
              label: 'Join with mic off',
              value: _audioMuted,
              onChanged: (v) => setState(() => _audioMuted = v),
            ),
            const SizedBox(height: 12),
            _ToggleTile(
              icon: Icons.videocam_off_outlined,
              label: 'Join with camera off',
              value: _videoMuted,
              onChanged: (v) => setState(() => _videoMuted = v),
            ),

            const SizedBox(height: 40),

            // ── Join Button ──
            GestureDetector(
              onTap: _join,
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  gradient: brandGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Join Meeting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
          color: textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
    );
  }
}

class _GlassInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const _GlassInput({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: textPrimary, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textHint),
          prefixIcon: Icon(icon, color: textSecondary, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        ),
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
