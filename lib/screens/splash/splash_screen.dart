import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/api_client.dart';
import '../../core/supabase_client.dart';
import '../../core/session_boot.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final ApiClient _api;

  @override
  void initState() {
    super.initState();

    _api = ApiClient();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Kick off bootstrap logic
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    // Let the splash animation play a bit
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    final app = AppStateScope.of(context);

    try {
      if (Supa.currentUser != null) {
        // There is already a session → hydrate and go straight to shell
        await hydrateFromSupabaseSession(app, _api);
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/shell');
      } else {
        // No session → go to onboarding
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    } catch (_) {
      // If anything goes wrong, fall back to onboarding
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            'assets/ielt.png',
            width: 150,
            height: 150,
          ),
        ),
      ),
    );
  }
}
