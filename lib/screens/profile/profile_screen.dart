import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/api_client.dart';
import '../../core/supabase_client.dart';
import 'faq_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiClient();
  late Future<Map<String, dynamic>> _profileFut;

  @override
  void initState() {
    super.initState();
    _profileFut = _api.getMe();
  }

  // Helper to avoid navigator '_debugLocked' issues
  void _safeNavigate(Future<void> Function(NavigatorState nav) action) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await action(Navigator.of(context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final total = app.results;
    final testsCompleted = total.length;
    final avg =
        total.isEmpty ? 0 : total.map((e) => e.accuracy).reduce((a, b) => a + b) / total.length;
    final email = Supa.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFut,
          builder: (context, snap) {
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Error loading profile'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _profileFut = _api.getMe();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final prof = snap.data!;
            // Prefer backend values, fall back to AppState, then defaults
            final profileName = (prof['full_name'] as String?)?.trim();
            final displayName = profileName?.isNotEmpty == true
                ? profileName!
                : (app.displayName ?? 'Learner');

            final bandGoal = prof['band_goal'] ?? app.bandGoal;
            // Prefer profile avatar URL; AppState only as fallback
            final avatar = (prof['avatar_url'] as String?) ?? app.avatarUrl;
            final avatarUrl = avatar; // no extra rev param — new path will force reload

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(email),
                    subtitle: bandGoal == null
                        ? null
                        : Text('Target band: $bandGoal'),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: Icon(
                      app.isPremium
                          ? Icons.workspace_premium
                          : Icons.lock_outline,
                    ),
                    title: Text(
                      'Premium: ${app.isPremium ? 'Active' : 'Free tier'}',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () {
                        _safeNavigate(
                          (nav) async => nav.pushNamed('/premium'),
                        );
                      },
                      child: const Text('Manage'),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit profile'),
                    subtitle:
                        const Text('Update your name, avatar, and band goal'),
                    onTap: () {
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        final updated = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfileScreen(profile: prof)),
                        );

                        if (!mounted) return;

                        if (updated is Map<String, dynamic>) {
                          setState(() => _profileFut = Future.value(updated));
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & FAQ'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _safeNavigate(
                        (nav) async => nav.push(
                          MaterialPageRoute(
                            builder: (_) => const FaqScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your stats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _stat(
                            'Tests completed',
                            '$testsCompleted',
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _stat(
                            'Average score',
                            '${(avg * 100).round()}%',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Log out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    await Supa.client.auth.signOut();
                    app.logout();
                    _safeNavigate((nav) async {
                      nav.pushNamedAndRemoveUntil(
                        '/onboarding',
                        (route) => false,
                      );
                    });
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }
}
