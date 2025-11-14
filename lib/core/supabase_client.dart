import 'package:supabase_flutter/supabase_flutter.dart';

class Supa {
  static SupabaseClient get client => Supabase.instance.client;
  static User? get currentUser => client.auth.currentUser;
  static String? get currentUserId => currentUser?.id;

  static Future<void> init({required String url, required String anonKey}) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }
}

