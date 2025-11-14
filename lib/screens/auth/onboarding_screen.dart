import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/constants.dart';
import '../../core/supabase_client.dart';
import '../../core/api_client.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    // If already logged in, skip to shell
    if (app.isLoggedIn || Supa.currentUser != null) {
      // defer push to end of build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/shell');
      });
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Gradient hero
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 280),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kHeroGradStart, kHeroGradEnd],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('IELTS Prep', style: Theme.of(context).textTheme.displayLarge?.copyWith(color: Colors.white)),
                          const SizedBox(height: 8),
                          const Text('Timed practice, band-based sets, and full exam simulations — all in one clean app.', style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(kPageHPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 16),
                    _Bullet(text: 'Practice by skill: Listening, Reading, Writing, Speaking'),
                    _Bullet(text: 'Band-style levels with quick sets'),
                    _Bullet(text: 'Realistic timers to build pacing'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(kPageHPad, 0, kPageHPad, kPageHPad),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Session restore
                        final user = Supa.currentUser;
                        if (user != null) {
                          final api = ApiClient();
                          final profile = await api.getMe();
                          final sub = await api.getCurrentSubscription();
                          app.login(email: '${profile['full_name'] ?? 'user'}@supabase', name: profile['full_name'], userId: user.id);
                          app.setPremium((sub?['profile']?['is_premium'] as bool?) ?? false);
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(context, '/shell');
                          return;
                        }
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text('Login'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: const Text('Create account'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final String text;
  const _Bullet({required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(children: [const Icon(Icons.check_circle, size: 18), const SizedBox(width: 8), Expanded(child: Text(text))]),
    );
  }
}
