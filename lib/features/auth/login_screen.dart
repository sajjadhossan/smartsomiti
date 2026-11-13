import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/somiti_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _rememberMe = true;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final cred = await AuthService().signInWithGoogle();
      if (cred == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সাইন-ইন বাতিল করা হয়েছে।')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('লগইন ত্রুটি: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitEmailAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        // Sign Up & Member Registration Application
        final cred = await AuthService().signUpWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
        );

          // Register as pending applicant in Firestore
          await SomitiService().registerPendingUser(
            uid: cred.user!.uid,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            email: _emailController.text.trim(),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: Color(0xFF0F9D58),
                content: Text('🎉 অ্যাকাউন্ট তৈরি হয়েছে! সমিতি কর্তৃপক্ষ সদস্যপদ বরাদ্দ দিলে ড্যাশবোর্ড সচল হবে।'),
              ),
            );
          }
      } else {
        // Sign In
        await AuthService().signInWithEmailPassword(
          _emailController.text,
          _passwordController.text,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.error,
            content: Text('ত্রুটি: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController(text: _emailController.text.trim());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lock_reset_rounded, color: Color(0xFF0F9D58)),
            SizedBox(width: 8),
            Text('পাসওয়ার্ড রিসেট করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'আপনার একাউন্টের ইমেইল ঠিকানা দিন। পাসওয়ার্ড পরিবর্তনের সিকিউর লিংক পাঠানো হবে।',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: resetEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'ইমেইল এড্রেস',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              try {
                await AuthService().sendPasswordResetEmail(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF0F9D58),
                      content: Text('✅ $email ঠিকানায় পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে!'),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('ত্রুটি: $e')),
                  );
                }
              }
            },
            child: const Text('লিংক পাঠান'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.account_balance_rounded,
                      size: 56,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'স্মার্ট সমিতি প্ল্যাটফর্ম',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ডিজিটাল জমা রসিদ, খরচ খাতা ও ড্রাইভ ব্যাকআপসহ সম্পূর্ণ সমিতি ব্যবস্থাপনা',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Authentication Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Sign In vs Sign Up Tab Bar
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Center(
                                        child: Text('লগইন / সাইন-ইন', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      selected: !_isSignUp,
                                      onSelected: (val) {
                                        if (val) setState(() => _isSignUp = false);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: ChoiceChip(
                                      label: const Center(
                                        child: Text('সদস্য আবেদন', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      selected: _isSignUp,
                                      onSelected: (val) {
                                        if (val) setState(() => _isSignUp = true);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            if (_isSignUp) ...[
                              TextFormField(
                                controller: _nameController,
                                decoration: const InputDecoration(
                                  labelText: 'পূর্ণ নাম *',
                                  hintText: 'যেমন: জনাব মোঃ আব্দুল্লাহ',
                                  prefixIcon: Icon(Icons.person_outline),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'অনুগ্রহ করে আপনার নাম দিন';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  labelText: 'মোবাইল নম্বর *',
                                  hintText: '০১৭১২-৩৪৫৬৭৮',
                                  prefixIcon: Icon(Icons.phone_outlined),
                                  border: OutlineInputBorder(),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'অনুগ্রহ করে মোবাইল নম্বর দিন';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                            ],

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'ইমেইল এড্রেস *',
                                hintText: 'example@gmail.com',
                                prefixIcon: Icon(Icons.email_outlined),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'ইমেইল প্রদান করুন';
                                }
                                if (!val.contains('@') || !val.contains('.')) {
                                  return 'সঠিক ইমেইল দিন';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'পাসওয়ার্ড *',
                                hintText: 'কমপক্ষে ৬ ডিজিটের পাসওয়ার্ড',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().length < 6) {
                                  return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষরের হতে হবে';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),

                            // Remember Me & Forgot Password Row (Only in Sign In)
                            if (!_isSignUp)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: _rememberMe,
                                        onChanged: (val) {
                                          setState(() => _rememberMe = val ?? true);
                                        },
                                      ),
                                      const Text('মনে রাখুন', style: TextStyle(fontSize: 13)),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: _showForgotPasswordDialog,
                                    child: const Text('পাসওয়ার্ড ভুলে গেছেন?', style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 12),

                            if (_isLoading)
                              const Center(child: CircularProgressIndicator())
                            else
                              FilledButton(
                                onPressed: _submitEmailAuth,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  _isSignUp ? '📝 সদস্য আবেদন জমা ও সাইন-আপ' : '🔐 সাইন-ইন করুন',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                              ),

                            const SizedBox(height: 18),
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text('অথবা', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 18),

                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleSignIn,
                              icon: const Icon(Icons.g_mobiledata_rounded, size: 26, color: Color(0xFF4285F4)),
                              label: const Text(
                                'Google দিয়ে সরাসরি প্রবেশ করুন',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
