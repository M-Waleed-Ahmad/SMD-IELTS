import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/supabase_client.dart';
import '../../core/api_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSubmitting = false;
  bool _showPassword = false;


  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final api = ApiClient();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.97, end: 1.0),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _form,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              validator: (v) {
                                final value = v?.trim() ?? '';
                                if (value.isEmpty) return 'Email is required';
                                return emailRegex.hasMatch(value)
                                    ? null
                                    : 'Enter a valid email';
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _password,
                              obscureText: !_showPassword,       // <— invert because false = hidden
                              decoration: InputDecoration(
                                labelText: 'Password',
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showPassword ? Icons.visibility : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() => _showPassword = !_showPassword);
                                  },
                                ),
                              ),
                              validator: (v) =>
                                  (v ?? '').length >= 6 ? null : 'Min 6 characters',
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () async {
                                        if (!_form.currentState!.validate()) {
                                          return;
                                        }

                                        setState(() => _isSubmitting = true);

                                        try {
                                          await Supa.client.auth
                                              .signInWithPassword(
                                            email: _email.text.trim(),
                                            password: _password.text,
                                          );

                                          final user = Supa.currentUser;
                                          if (user == null) {
                                            throw Exception('No user');
                                          }

                                          // Ensure profile exists
                                          final me = await api.getMe();

                                          final sub =
                                              await api.getCurrentSubscription();
                                          final isPremium =
                                              (sub?['profile']?['is_premium']
                                                      as bool?) ??
                                                  false;

                                          final userName =
                                              me['full_name'] as String?;

                                          app.login(
                                            email: _email.text.trim(),
                                            name: userName,
                                            userId: user.id,
                                          );
                                          app.setPremium(isPremium);

                                          if (!mounted) return;
                                          Navigator.pushReplacementNamed(
                                              context, '/shell');
                                        } catch (e) {
                                          if (!mounted) return;
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Login failed: ${e.toString()}'),
                                            ),
                                          );
                                        } finally {
                                          if (mounted) {
                                            setState(() =>
                                                _isSubmitting = false);
                                          }
                                        }
                                      },
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                            ),
                            const SizedBox(height: 10),

                            /// Forgot Password
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: _isSubmitting
                                    ? null
                                    : () =>
                                        Navigator.pushNamed(context, '/forgotPassword'),
                                child: const Text('Forgot password?'),
                              ),
                            ),

                            const SizedBox(height: 8),

                            /// Create Account
                            TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () => Navigator.pushReplacementNamed(
                                        context,
                                        '/register',
                                      ),
                              child: const Text('Create account'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Thin loading indicator at the top
            if (_isSubmitting)
              const Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }
}
