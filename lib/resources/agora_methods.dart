import 'package:flutter/material.dart';
import '../resources/auth_methods.dart';
import '../resources/firestore_methods.dart';
import '../screens/agora_call_screen.dart';

class AgoraMethods {
  final AuthMethods _authMethods = AuthMethods();
  final FirestoreMethods _firestoreMethods = FirestoreMethods();

  static const String agoraAppId = '3f1aebab46ea48c2974e6e83aeafb464';

  Future<void> createMeeting({
    required BuildContext context,
    required String channelName,
    required bool isAudioMuted,
    required bool isVideoMuted,
    String? customUsername,
  }) async {
    if (agoraAppId == 'PASTE_YOUR_AGORA_APP_ID_HERE' || agoraAppId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Agora App ID not set!'),
          backgroundColor: Color(0xFFFF3B30),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final String username =
      customUsername != null && customUsername.trim().isNotEmpty
          ? customUsername.trim()
          : (_authMethods.user.displayName ?? 'Guest');

      // ✅ Pehle navigate karo
      if (!context.mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgoraCallScreen(
            channelName: channelName,
            username: username,
            initialAudioMuted: isAudioMuted,
            initialVideoMuted: isVideoMuted,
          ),
        ),
      );

      // ✅ History baad mein save karo (await nahi)
      _firestoreMethods.addToMeetingHistory(channelName);

    } catch (e) {
      debugPrint('❌ AgoraMethods error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}