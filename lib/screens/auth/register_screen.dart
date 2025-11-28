import 'package:flutter/material.dart';
import '../../core/app_state.dart';
import '../../core/supabase_client.dart';
import '../../core/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    final api = ApiClient();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) =>
                          (v ?? '').trim().isNotEmpty ? null : 'Enter your name',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email'),
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirm,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _showConfirmPassword = !_showConfirmPassword);
                          },
                        ),
                      ),
                      validator: (v) => v == _password.text ? null : 'Passwords do not match',
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                if (!_form.currentState!.validate()) return;
                                setState(() => _isSubmitting = true);
                                try {
                                  final res = await Supa.client.auth.signUp(
                                    email: _email.text.trim(),
                                    password: _password.text,
                                  );
                                  final user = res.user;
                                  if (user == null) {
                                    throw Exception('Sign up failed');
                                  }

                                  // Ensure profile exists, then update name
                                  await api.getMe();
                                  await api.updateMe(
                                    fullName: _name.text.trim(),
                                  );
                                  final sub =
                                      await api.getCurrentSubscription();
                                  final isPremium =
                                      (sub?['profile']?['is_premium']
                                              as bool?) ??
                                          false;

                                  app.register(
                                    name: _name.text.trim(),
                                    email: _email.text.trim(),
                                    userId: user.id,
                                  );
                                  app.setPremium(isPremium);

                                  if (!mounted) return;
                                  Navigator.pushReplacementNamed(
                                      context, '/shell');
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Registration failed: ${e.toString()}'),
                                    ),
                                  );
                                } finally {
                                  if (mounted) {
                                    setState(() => _isSubmitting = false);
                                  }
                                }
                              },
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Create account'),
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                      child: const Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),

            // Thin loading bar at top while submitting
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
