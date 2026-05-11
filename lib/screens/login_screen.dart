import 'package:flutter/material.dart';
import '../resources/auth_methods.dart';
import '../utils/colors.dart';
import '../utils/utils.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthMethods _authMethods = AuthMethods();
  bool _loading = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() => _loading = true);
    bool res = await _authMethods.signInWithGoogle(context);
    if (mounted) setState(() => _loading = false);
    if (res && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: const BoxDecoration(gradient: darkGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 2),

                    // ── Logo / Brand ──
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: brandGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: primaryPurple.withOpacity(0.45),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.video_camera_front_rounded,
                        color: Colors.white,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 28),

                    ShaderMask(
                      shaderCallback: (bounds) =>
                          brandGradient.createShader(bounds),
                      child: const Text(
                        'ConnectNow',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Video meetings, reimagined.',
                      style: TextStyle(
                        color: textSecondary,
                        fontSize: 16,
                      ),
                    ),

                    const Spacer(flex: 2),

                    // ── Feature Pills ──
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: const [
                        _FeaturePill(icon: Icons.hd, label: 'HD Video'),
                        _FeaturePill(
                            icon: Icons.lock_outline, label: 'Encrypted'),
                        _FeaturePill(
                            icon: Icons.group_outlined,
                            label: 'Multi-party'),
                        _FeaturePill(
                            icon: Icons.history, label: 'History'),
                      ],
                    ),

                    const Spacer(flex: 3),

                    // ── Sign In Button ──
                    _loading
                        ? Container(
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: brandGradient,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _signIn,
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.login,
                                          color: primaryBlue,
                                          size: 16),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                    const SizedBox(height: 20),
                    const Text(
                      'By continuing, you agree to our Terms & Privacy Policy',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textHint, fontSize: 12),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeaturePill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: primaryBlue, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(color: textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}
