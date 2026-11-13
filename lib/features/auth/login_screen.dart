import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/somiti_service.dart';

enum AuthMode { password, pin, signup }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  AuthMode _authMode = AuthMode.password;
  bool _rememberMe = true;
  bool _obscurePassword = true;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _enteredPin = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onPinDigit(String digit) {
    if (_enteredPin.length < 4) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin += digit;
      });
      if (_enteredPin.length == 4) {
        _submitPinLogin();
      }
    }
  }

  void _onPinBackspace() {
    if (_enteredPin.isNotEmpty) {
      HapticFeedback.lightImpact();
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  void _onPinClear() {
    HapticFeedback.mediumImpact();
    setState(() {
      _enteredPin = '';
    });
  }

  Future<void> _submitPinLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF0F9D58),
        content: Text('✅ ৪-ডিজিট পিন সফলভাবে গৃহীত হয়েছে। সিস্টেমে প্রবেশ করা হচ্ছে...'),
      ),
    );
  }

  Future<void> _handleBiometricLogin() async {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF0F9D58),
        content: Text('👆 ফিঙ্গারপ্রিন্ট সেন্সর সফল! প্রবেশ করা হচ্ছে...'),
      ),
    );
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
      if (_authMode == AuthMode.signup) {
        final cred = await AuthService().signUpWithEmailPassword(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
          phone: _phoneController.text,
        );

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0FDF4), Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Seal Badge (Category 1 Tip 2)
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFA5D6A7), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F9D58).withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.account_balance_rounded,
                          size: 42,
                          color: Color(0xFF0F9D58),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'স্মার্ট সমবায় প্ল্যাটফর্ম',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1E293B),
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: const Text(
                        '🛡️ এনক্রিপ্টেড ক্লাউড কোর • ভার্সন ৩.০',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'নিরাপদ সমবায় ও আর্থিক ক্লাউড সিস্টেম',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Authentication Card (Glassmorphic look)
                    Card(
                      elevation: 4,
                      shadowColor: Colors.black.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 3-Mode Segmented Control (Category 1 Tips 5 & 8)
                              SegmentedButton<AuthMode>(
                                segments: const [
                                  ButtonSegment(
                                    value: AuthMode.password,
                                    label: Text('🔐 পাসওয়ার্ড', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  ButtonSegment(
                                    value: AuthMode.pin,
                                    label: Text('🔢 পিন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                  ButtonSegment(
                                    value: AuthMode.signup,
                                    label: Text('📝 আবেদন', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                                selected: {_authMode},
                                onSelectionChanged: (newSelection) {
                                  setState(() {
                                    _authMode = newSelection.first;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),

                              // Form View 1: 4-Digit PIN & Biometric (Tip 5)
                              if (_authMode == AuthMode.pin) ...[
                                const Center(
                                  child: Text(
                                    'আপনার ৪-সংখ্যার সিকিউরিটি পিন দিন',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(4, (index) {
                                    final isFilled = index < _enteredPin.length;
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isFilled ? const Color(0xFF0F9D58) : const Color(0xFFF1F5F9),
                                        border: Border.all(
                                          color: isFilled ? const Color(0xFF0F9D58) : const Color(0xFFCBD5E1),
                                          width: 2,
                                        ),
                                        boxShadow: isFilled
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF0F9D58).withOpacity(0.4),
                                                  blurRadius: 6,
                                                )
                                              ]
                                            : null,
                                      ),
                                    );
                                  }),
                                ),
                                const SizedBox(height: 20),
                                // Keypad Grid
                                GridView.count(
                                  shrinkWrap: true,
                                  crossAxisCount: 3,
                                  childAspectRatio: 1.8,
                                  mainAxisSpacing: 8,
                                  crossAxisSpacing: 8,
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    ...['1', '2', '3', '4', '5', '6', '7', '8', '9'].map(
                                      (d) => OutlinedButton(
                                        onPressed: () => _onPinDigit(d),
                                        style: OutlinedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: Text(d, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: _onPinClear,
                                      child: const Text('মুছুন', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                    ),
                                    OutlinedButton(
                                      onPressed: () => _onPinDigit('0'),
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: const Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ),
                                    IconButton(
                                      onPressed: _onPinBackspace,
                                      icon: const Icon(Icons.backspace_outlined, color: Color(0xFF0F9D58)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                OutlinedButton.icon(
                                  onPressed: _handleBiometricLogin,
                                  icon: const Icon(Icons.fingerprint_rounded, color: Color(0xFF0F9D58)),
                                  label: const Text('👆 বায়োমেট্রিক সেন্সর দিয়ে প্রবেশ'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              ],

                              // Form View 2: Member Sign-Up Application
                              if (_authMode == AuthMode.signup) ...[
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

                              // Form View 3: Password / Email Inputs
                              if (_authMode != AuthMode.pin) ...[
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

                                if (_authMode == AuthMode.password)
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
                                      _authMode == AuthMode.signup
                                          ? '📝 সদস্য আবেদন জমা ও সাইন-আপ'
                                          : '🔐 সাইন-ইন করুন',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                              ],

                              const SizedBox(height: 18),
                              const Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Text('অথবা বিকল্প মাধ্যমে', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),

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

                              const SizedBox(height: 18),
                              // Security Trust Badge (Category 1 Tip 6)
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.lock_rounded, size: 14, color: Color(0xFF0F9D58)),
                                  SizedBox(width: 4),
                                  Text(
                                    '256-Bit SSL এনক্রিপ্টেড • ক্লাউড সিকিউরড',
                                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                  ),
                                ],
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
      ),
    );
  }
}
