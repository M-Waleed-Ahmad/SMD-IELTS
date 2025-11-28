import '../core/app_state.dart';
import '../core/api_client.dart';
import '../core/supabase_client.dart';

Future<void> hydrateFromSupabaseSession(AppState app, ApiClient api) async {
  final user = Supa.currentUser;
  if (user == null) return;

  if (!app.isLoggedIn || app.currentUserId != user.id) {
    final email = user.email ?? '${user.id}@session';
    app.login(email: email, name: user.userMetadata?['full_name'] as String?, userId: user.id);
  }

  try {
    final profile = await api.getMe();
    app.setProfile(profile);
  } catch (_) {
    // ignore for now
  }

  try {
    final sub = await api.getCurrentSubscription();
    final isPremium = (sub?['profile']?['is_premium'] as bool?) ?? app.isPremium;
    app.setPremium(isPremium);
  } catch (_) {}
}

