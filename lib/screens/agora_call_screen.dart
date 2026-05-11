import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../resources/agora_methods.dart';
import '../utils/colors.dart';

class AgoraCallScreen extends StatefulWidget {
  final String channelName;
  final String username;
  final bool initialAudioMuted;
  final bool initialVideoMuted;

  const AgoraCallScreen({
    super.key,
    required this.channelName,
    required this.username,
    this.initialAudioMuted = false,
    this.initialVideoMuted = false,
  });

  @override
  State<AgoraCallScreen> createState() => _AgoraCallScreenState();
}

class _AgoraCallScreenState extends State<AgoraCallScreen> {
  RtcEngine? _engine;
  bool _joined = false;
  bool _engineReady = false;
  bool _initError = false;
  String _errorMessage = '';

  int? _remoteUid;
  bool _audioMuted = false;
  bool _videoMuted = false;
  bool _speakerOn = true;
  bool _frontCamera = true;
  bool _isSwapped = false;

  // Elapsed call timer
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _audioMuted = widget.initialAudioMuted;
    _videoMuted = widget.initialVideoMuted;
    _initAgora();
  }

  Future<void> _initAgora() async {
    try {
      // Request permissions
      final cameraStatus = await Permission.camera.request();
      final micStatus = await Permission.microphone.request();

      if (cameraStatus.isDenied || micStatus.isDenied) {
        setState(() {
          _initError = true;
          _errorMessage =
              'Camera and microphone permissions are required.\nPlease grant them in device Settings.';
        });
        return;
      }

      // Create engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: AgoraMethods.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('✅ Joined channel: ${connection.channelId}');
            setState(() {
              _joined = true;
              _engineReady = true;
            });
            // Start call timer
            _timer = Timer.periodic(const Duration(seconds: 1), (_) {
              if (mounted) setState(() => _seconds++);
            });
          },
          onUserJoined:
              (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('👤 Remote user joined: $remoteUid');
            setState(() => _remoteUid = remoteUid);
          },
          onUserOffline: (RtcConnection connection, int remoteUid,
              UserOfflineReasonType reason) {
            debugPrint('👤 Remote user left: $remoteUid');
            setState(() => _remoteUid = null);
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('❌ Agora error $err: $msg');
            if (mounted) {
              setState(() {
                _initError = true;
                _errorMessage = 'Agora Error ($err): $msg';
              });
            }
          },
          onTokenPrivilegeWillExpire:
              (RtcConnection connection, String token) {
            debugPrint('⚠️ Token will expire');
          },
        ),
      );

      // Enable video
      await _engine!.enableVideo();
      await _engine!.enableAudio();
      await _engine!.setDefaultAudioRouteToSpeakerphone(true);
      await _engine!.startPreview();

      // Apply initial mute states
      await _engine!.muteLocalAudioStream(_audioMuted);
      await _engine!.muteLocalVideoStream(_videoMuted);

      // Join the channel (token is empty string for Testing Mode)
      await _engine!.joinChannel(
        token: '',
        channelId: widget.channelName,
        uid: 0,
        options: const ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      debugPrint('❌ Init error: $e');
      if (mounted) {
        setState(() {
          _initError = true;
          _errorMessage = 'Failed to initialize video call:\n$e';
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _engine?.leaveChannel();
    _engine?.release();
    super.dispose();
  }

  void _toggleAudio() async {
    setState(() => _audioMuted = !_audioMuted);
    await _engine?.muteLocalAudioStream(_audioMuted);
  }

  void _toggleVideo() async {
    setState(() => _videoMuted = !_videoMuted);
    await _engine?.muteLocalVideoStream(_videoMuted);
  }

  void _toggleSpeaker() async {
    setState(() => _speakerOn = !_speakerOn);
    await _engine?.setEnableSpeakerphone(_speakerOn);
  }

  void _switchCamera() async {
    setState(() => _frontCamera = !_frontCamera);
    await _engine?.switchCamera();
  }

  void _copyRoomId() {
    Clipboard.setData(ClipboardData(text: widget.channelName));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Room ID copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _endCall() {
    _timer?.cancel();
    _engine?.leaveChannel();
    Navigator.pop(context);
  }

  String get _callDuration {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Widget _buildLocalView() {
    if (_videoMuted || _engine == null || !_engineReady) {
      return _AvatarPlaceholder(
          name: widget.username, size: 56, fontSize: 22, isSmall: true);
    }
    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: _engine!,
        canvas: const VideoCanvas(uid: 0),
      ),
    );
  }

  Widget _buildRemoteView() {
    if (_remoteUid == null) {
      return Container(
        color: const Color(0xFF0D0D0D),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  gradient: brandGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 46),
              ),
              const SizedBox(height: 20),
              const Text(
                'Waiting for others...',
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 17,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _copyRoomId,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.copy_rounded,
                          color: Colors.white60, size: 15),
                      const SizedBox(width: 6),
                      Text(
                        'Room: ${widget.channelName}',
                        style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap to copy & share',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: widget.channelName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Error screen
    if (_initError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: redError.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline,
                        color: redError, size: 40),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Could not start call',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50,
                      width: 160,
                      decoration: BoxDecoration(
                        color: redError,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Go Back',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Loading screen while joining
    if (!_joined) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: primaryPurple),
              const SizedBox(height: 20),
              const Text('Joining meeting...',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              Text(
                'Room: ${widget.channelName}',
                style: const TextStyle(color: primaryBlue, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Remote / Main view ──
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _isSwapped = !_isSwapped),
              child: _isSwapped ? _buildLocalView() : _buildRemoteView(),
            ),
          ),

          // ── Local PiP ──
          Positioned(
            top: MediaQuery.of(context).padding.top + 56,
            right: 16,
            width: 110,
            height: 160,
            child: GestureDetector(
              onTap: () => setState(() => _isSwapped = !_isSwapped),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: primaryPurple.withValues(alpha: 0.7), width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _isSwapped ? _buildRemoteView() : _buildLocalView(),
                ),
              ),
            ),
          ),
          // ── Top bar ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Live badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: brandGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record,
                            color: Colors.white, size: 9),
                        SizedBox(width: 4),
                        Text('LIVE',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Duration
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _callDuration,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  const Spacer(),
                  // Copy room ID
                  GestureDetector(
                    onTap: _copyRoomId,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.copy_rounded,
                              color: Colors.white60, size: 13),
                          const SizedBox(width: 5),
                          Text(
                            widget.channelName,
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_remoteUid != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: greenOnline.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: greenOnline, width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people, color: greenOnline, size: 14),
                          SizedBox(width: 4),
                          Text('2',
                              style: TextStyle(
                                  color: greenOnline,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Bottom controls ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.95),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ControlBtn(
                    icon: _audioMuted ? Icons.mic_off : Icons.mic,
                    label: _audioMuted ? 'Unmute' : 'Mute',
                    active: !_audioMuted,
                    onTap: _toggleAudio,
                  ),
                  _ControlBtn(
                    icon: _videoMuted ? Icons.videocam_off : Icons.videocam,
                    label: _videoMuted ? 'Start Cam' : 'Stop Cam',
                    active: !_videoMuted,
                    onTap: _toggleVideo,
                  ),
                  _ControlBtn(
                    icon:
                        _speakerOn ? Icons.volume_up : Icons.volume_off,
                    label: 'Speaker',
                    active: _speakerOn,
                    onTap: _toggleSpeaker,
                  ),
                  _ControlBtn(
                    icon: Icons.flip_camera_ios_rounded,
                    label: 'Flip',
                    active: true,
                    onTap: _switchCamera,
                  ),
                  // End call
                  GestureDetector(
                    onTap: _endCall,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: redError,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: redError.withValues(alpha: 0.4),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.call_end,
                              color: Colors.white, size: 28),
                        ),
                        const SizedBox(height: 6),
                        const Text('End',
                            style: TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar Placeholder ──
class _AvatarPlaceholder extends StatelessWidget {
  final String name;
  final double size;
  final double fontSize;
  final bool isSmall;

  const _AvatarPlaceholder({
    required this.name,
    this.size = 100,
    this.fontSize = 40,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      color: isSmall ? const Color(0xFF1A1A2E) : const Color(0xFF0D0D0D),
      child: Center(
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            gradient: brandGradient,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Control Button ──
class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? Colors.white.withValues(alpha: 0.28)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon,
              color: active ? Colors.white : Colors.white38,
              size: 22,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
                color: active ? Colors.white : Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
