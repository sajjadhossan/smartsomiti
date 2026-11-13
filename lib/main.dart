import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'models/somiti_model.dart';
import 'models/member_model.dart';
import 'models/deposit_model.dart';
import 'models/expense_model.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/drive_service.dart';
import 'services/somiti_service.dart';
import 'services/feature_management_service.dart';
import 'features/admin/master_admin_screen.dart';
import 'features/loans/loan_management_screen.dart';
import 'features/accounting/accounting_screen.dart';
import 'features/reports/financial_reports_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FeatureManagementService().initialize();
  } catch (e) {
    debugPrint('Firebase initialization note: $e');
  }
  runApp(const SomitiApp());
}

class SomitiApp extends StatelessWidget {
  const SomitiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'স্মার্ট সমিতি প্ল্যাটফর্ম',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F9D58),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final somitiService = SomitiService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final user = snapshot.data;
        if (user != null) {
          return StreamBuilder<List<SomitiModel>>(
            stream: somitiService.getUserSomitisStream(user.email ?? '', user.uid),
            builder: (context, somitiSnapshot) {
              if (somitiSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              final somitis = somitiSnapshot.data ?? [];
              final userEmail = (user.email ?? '').toLowerCase().trim();
              final isSuperAdmin = userEmail == 'hossansajjad1994@gmail.com';
              if (somitis.isEmpty) {
                if (isSuperAdmin) {
                  return OnboardingScreen(user: user);
                }
                return PendingApprovalScreen(user: user);
              }

              return SomitiListScreen(user: user, somitis: somitis);

            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}

/// ============================================================
/// অপেক্ষমাণ স্ক্রিন (Pending / Locked Approval Screen)
/// ============================================================
class PendingApprovalScreen extends StatefulWidget {
  final User user;
  const PendingApprovalScreen({super.key, required this.user});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen> {
  bool _isChecking = false;

  void _checkStatus() {
    setState(() => _isChecking = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('অনুমোদন স্ট্যাটাস যাচাই করা হয়েছে।')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('অনুমোদন অপেক্ষমাণ', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if ((widget.user.email ?? '').trim().toLowerCase() == 'hossansajjad1994@gmail.com')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amber),
              tooltip: 'মাস্টার এডমিন কন্ট্রোল সেন্টার',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MasterAdminScreen(userEmail: widget.user.email ?? '')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'লগআউট',
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber.shade400, width: 2),
                    ),
                    child: const Icon(
                      Icons.lock_clock_rounded,
                      size: 46,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'আপনাকে এখনও কোনো সমিতিতে যুক্ত করা হয়নি',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'আপনার ইমেইল: ${widget.user.email ?? "অনুল্লিখিত"}',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'আপনার অ্যাকাউন্ট সফলভাবে তৈরি হয়েছে। তবে সমিতির অ্যাডমিন/কর্তৃপক্ষ কর্তৃক সদস্যপদ বরাদ্দ ছাড়া আপনি কোনো তথ্য দেখতে পারবেন না।',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Contact Authority Card
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.support_agent_rounded, color: Color(0xFF0F9D58)),
                              SizedBox(width: 8),
                              Text(
                                'সমিতি কর্তৃপক্ষের সাথে যোগাযোগ করুন',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text(
                            'সদস্য হিসেবে যুক্ত হতে নিম্নের নম্বরে যোগাযোগ করে আপনার ইমেইলটি জানান:',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          const ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              child: Icon(Icons.person, size: 20),
                            ),
                            title: Text('জনাব সাজ্জাদ হোসেন (কোষাধ্যক্ষ / অ্যাডমিন)', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('মোবাইল: ০১৭১২-৩৪৫৬৭৮'),
                          ),
                          const SizedBox(height: 6),
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '📞 ফোন ও WhatsApp: ০১৭১২-৩৪৫৬৭৮',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F9D58)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  if (_isChecking)
                    const CircularProgressIndicator()
                  else
                    FilledButton.icon(
                      onPressed: _checkStatus,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('🔄 অনুমোদন স্থিতি পুনরায় চেক করুন'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => AuthService().signOut(),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('লগআউট করুন'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OnboardingScreen(user: widget.user),
                        ),
                      );
                    },
                    child: const Text('নতুন সমিতি তৈরি করতে চান? (এডমিন প্যানেল)'),
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


/// ============================================================
/// ১. গুগল লগইন স্ক্রিন (Login Screen)
/// ============================================================
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

/// ============================================================
/// ২. অনবোর্ডিং স্ক্রিন (নতুন সমিতি তৈরি বা জয়েন)
/// ============================================================
class OnboardingScreen extends StatelessWidget {
  final User user;
  const OnboardingScreen({super.key, required this.user});

  void _showJoinDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('সমিতিতে যুক্ত হোন'),
        content: TextField(
          controller: codeController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'সমিতির জয়েনিং কোড (যেমন: SMT-1234)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          FilledButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) return;
              try {
                final somiti = await SomitiService().joinSomitiByCode(
                  somitiCode: code,
                  userId: user.uid,
                  userEmail: user.email ?? '',
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SomitiMainDashboard(somiti: somiti, user: user),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
                }
              }
            },
            child: const Text('যুক্ত হোন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('স্বাগতম'),
        actions: [
          IconButton(
            tooltip: 'লগআউট',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.diversity_3_rounded, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                'আপনার কোনো সক্রিয় সমিতি নেই',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'আপনার নিজের সমিতি শুরু করতে "নতুন সমিতি তৈরি করুন" বাটনে ক্লিক করুন অথবা বিদ্যমান সমিতিতে যোগ দিন।',
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateSomitiScreen(user: user)),
                    );
                  },
                  icon: const Icon(Icons.add_business_rounded),
                  label: const Text('নতুন সমিতি তৈরি করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showJoinDialog(context),
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('কোড দিয়ে সমিতিতে যোগ দিন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// ৩. নতুন সমিতি তৈরির স্ক্রিন (Create Somiti Form)
/// ============================================================
class CreateSomitiScreen extends StatefulWidget {
  final User user;
  const CreateSomitiScreen({super.key, required this.user});

  @override
  State<CreateSomitiScreen> createState() => _CreateSomitiScreenState();
}

class _CreateSomitiScreenState extends State<CreateSomitiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _padHeaderCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _bkashCtrl = TextEditingController();
  final _presidentCtrl = TextEditingController();
  final _secretaryCtrl = TextEditingController();
  final _cashierCtrl = TextEditingController();
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final somiti = await SomitiService().createSomiti(
        name: _nameCtrl.text.trim(),
        padHeader: _padHeaderCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        bankAccount: _bankCtrl.text.trim(),
        bkashNumber: _bkashCtrl.text.trim(),
        presidentName: _presidentCtrl.text.trim(),
        secretaryName: _secretaryCtrl.text.trim(),
        cashierName: _cashierCtrl.text.trim(),
        creatorId: widget.user.uid,
        creatorEmail: widget.user.email ?? '',
      );

      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SomitiMainDashboard(somiti: somiti, user: widget.user),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ত্রুটি: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন সমিতি সেটআপ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('সমিতির মূল পরিচিতি ও অফিসিয়াল প্যাড', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'সমিতির নাম *',
                  hintText: 'যেমন: প্রগতি ক্ষুদ্র সঞ্চয় সমবায় সমিতি',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'সমিতির নাম আবশ্যক' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _padHeaderCtrl,
                decoration: const InputDecoration(
                  labelText: 'অফিসিয়াল প্যাডের স্লোগান / হেডার',
                  hintText: 'যেমন: সঞ্চয়ে সমৃদ্ধি, একতায় শক্তি',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'কার্যালয়ের পূর্ণ ঠিকানা',
                  hintText: 'যেমন: মিরপুর-১০, ঢাকা',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),
              const Text('আর্থিক একাউন্ট তথ্য', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bankCtrl,
                decoration: const InputDecoration(
                  labelText: 'ব্যাংক হিসাব নম্বর ও ব্যাংকের নাম',
                  hintText: 'যেমন: সোনালী ব্যাংক - ১২৩৪৫৬৭৮',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _bkashCtrl,
                decoration: const InputDecoration(
                  labelText: 'বিকাশ / নগদ নম্বর',
                  hintText: 'যেমন: ০১৭১২-৩৪৫৬৭৮ (পার্সোনাল)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_android_rounded),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              const Text('কমিটির প্রধান দায়িত্বশীলগণ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _presidentCtrl,
                decoration: const InputDecoration(
                  labelText: 'সভাপতির নাম',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _secretaryCtrl,
                decoration: const InputDecoration(
                  labelText: 'সাধারণ সম্পাদকের নাম',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _cashierCtrl,
                decoration: InputDecoration(
                  labelText: 'কোষাধ্যক্ষের নাম',
                  hintText: widget.user.displayName ?? 'সাজ্জাদ হোসেন (আপনি)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.price_check_rounded),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('সমিতি সম্পন্ন ও চালু করুন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// ৪. ব্যবহারকারীর সমিতিসমূহের তালিকা (Somiti List Screen)
/// ============================================================
class SomitiListScreen extends StatelessWidget {
  final User user;
  final List<SomitiModel> somitis;
  const SomitiListScreen({super.key, required this.user, required this.somitis});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('আমার সমিতিসমূহ', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if ((user.email ?? '').trim().toLowerCase() == 'hossansajjad1994@gmail.com')
            IconButton(
              tooltip: 'মাস্টার এডমিন কন্ট্রোল সেন্টার',
              icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amber),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MasterAdminScreen(userEmail: user.email ?? '')),
                );
              },
            ),
          IconButton(
            tooltip: 'লগআউট',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: somitis.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final s = somitis[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SomitiMainDashboard(somiti: s, user: user),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(Icons.account_balance_rounded, color: theme.colorScheme.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                              if (s.padHeader.isNotEmpty)
                                Text(s.padHeader, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            s.somitiCode,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('📍 ${s.address.isEmpty ? 'ঠিকানা দেওয়া নেই' : s.address}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        const Row(
                          children: [
                            Text('ড্যাশবোর্ড', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13)),
                            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateSomitiScreen(user: user)),
          );
        },
        icon: const Icon(Icons.add_business_rounded),
        label: const Text('নতুন সমিতি তৈরি করুন'),
      ),
    );
  }
}

/// ============================================================
/// ৫. নির্বাচিত সমিতির মূল ড্যাশবোর্ড (Somiti Main Dashboard)
/// ============================================================
class SomitiMainDashboard extends StatefulWidget {
  final SomitiModel somiti;
  final User user;
  const SomitiMainDashboard({super.key, required this.somiti, required this.user});

  @override
  State<SomitiMainDashboard> createState() => _SomitiMainDashboardState();
}

class _SomitiMainDashboardState extends State<SomitiMainDashboard> {
  int _currentIndex = 0;
  final SomitiService _somitiService = SomitiService();
  final DriveService _driveService = DriveService();

  @override
  void initState() {
    super.initState();
    FeatureManagementService().watchSocietyFeatures(widget.somiti.id);
  }

  // Dialog: ডিজিটাল জমা রসিদ (Digital Money Receipt)
  void _showReceiptDialog({
    required String memberNumber,
    required String memberName,
    required double amount,
    required String type,
    required DateTime date,
    required String note,
  }) {
    final currencyFormat = NumberFormat('#,##,###');
    final dateFormat = DateFormat('dd-MM-yyyy, hh:mm a');
    final voucherNo = 'VCH-${date.millisecondsSinceEpoch.toString().substring(7)}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pad Header in Receipt
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.somiti.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F9D58)),
                    ),
                    if (widget.somiti.padHeader.isNotEmpty)
                      Text(
                        '"${widget.somiti.padHeader}"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      widget.somiti.address,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: const Text('ডিজিটাল জমা মানি রিসিট', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ভাউচার নং: $voucherNo', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text(dateFormat.format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              _receiptRow('সদস্য নম্বর:', '[$memberNumber]'),
              _receiptRow('সদস্যের নাম:', memberName),
              _receiptRow('জমার ধরণ:', '$type সঞ্চয়'),
              if (note.isNotEmpty) _receiptRow('মন্তব্য / নোট:', note),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('জমার পরিমাণ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('৳${currencyFormat.format(amount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('স্বাক্ষর: ${widget.somiti.cashierName}', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                  const Text('● ডিজিটাল সিলমোহর', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
          FilledButton.icon(
            onPressed: () {
              final receiptText = '''
🏛️ *${widget.somiti.name}*
${widget.somiti.padHeader.isNotEmpty ? '"' + widget.somiti.padHeader + '"\n' : ''}📍 ঠিকানা: ${widget.somiti.address}
🧾 *ডিজিটাল জমা মানি রিসিট*
--------------------------------
ভাউচার নং: $voucherNo
তারিখ: ${dateFormat.format(date)}
সদস্য: [$memberNumber] $memberName
জমার ধরণ: $type সঞ্চয়
${note.isNotEmpty ? 'নোট: ' + note + '\n' : ''}💰 *জমার পরিমাণ: ৳${currencyFormat.format(amount)}*
--------------------------------
কোষাধ্যক্ষ: ${widget.somiti.cashierName}
ধন্যবাদ! আপনার সঞ্চয় সফলভাবে জমা হয়েছে।
''';
              Clipboard.setData(ClipboardData(text: receiptText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('রসিদ কপি হয়েছে! WhatsApp বা মেসেজে শেয়ার করতে পেস্ট করুন।')),
              );
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('রসিদ শেয়ার করুন'),
          ),
        ],
      ),
    );
  }

  // Dialog: সদস্যের বিস্তারিত ব্যক্তিগত পাসবুক (Member Detailed Passbook Dialog)
  void _showMemberPassbookDialog(MemberModel member) {
    final currencyFormat = NumberFormat('#,##,###');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(member.memberNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('ফোন: ${member.phone.isEmpty ? 'নেই' : member.phone}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('মোট সঞ্চয় ব্যালেন্স:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('৳${currencyFormat.format(member.totalDeposit)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('এই সদস্যের জমার খতিয়ান:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Flexible(
                child: StreamBuilder<List<DepositModel>>(
                  stream: _somitiService.getMemberDepositsStream(widget.somiti.id, member.memberNumber),
                  builder: (context, snapshot) {
                    final deposits = snapshot.data ?? [];
                    if (deposits.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(child: Text('এখনও কোনো জমা নেই')),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: deposits.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final d = deposits[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('৳${currencyFormat.format(d.amount)} (${d.type})', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(dateFormat.format(d.date), style: const TextStyle(fontSize: 11)),
                          trailing: IconButton(
                            icon: const Icon(Icons.receipt_rounded, size: 20, color: Colors.green),
                            tooltip: 'রসিদ দেখুন',
                            onPressed: () => _showReceiptDialog(
                              memberNumber: d.memberNumber,
                              memberName: d.memberName,
                              amount: d.amount,
                              type: d.type,
                              date: d.date,
                              note: d.note,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  // Dialog: নতুন সদস্য যোগ (Add Member & Assign by Email)
  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final numberController = TextEditingController();
    final emailController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('নতুন সদস্য যোগ ও বরাদ্দ করুন'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: numberController,
                    decoration: const InputDecoration(labelText: 'সদস্য নং (যেমন: 01)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'সদস্যের নাম *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'মোবাইল নম্বর', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'সদস্যের জিমেইল/ইমেইল (লগইন অনুমোদনের জন্য)',
                      hintText: 'member@gmail.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '💡 এই ইমেইল দিলে সদস্য তার ফোনে লগইন করলেই এই সমিতিতে সরাসরি ঢুকতে পারবে।',
                    style: TextStyle(fontSize: 11, color: Color(0xFF0F9D58)),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(ctx), child: const Text('বাতিল')),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        final number = numberController.text.trim();
                        final email = emailController.text.trim().toLowerCase();
                        if (name.isEmpty || number.isEmpty) return;

                        setDialogState(() => isSaving = true);
                        try {
                          await _somitiService.addMember(
                            somitiId: widget.somiti.id,
                            name: name,
                            phone: phone,
                            memberNumber: number,
                            email: email,
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('সদস্য সফলভাবে যুক্ত ও বরাদ্দ করা হয়েছে')),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                        }
                      },
                child: isSaving ? const CircularProgressIndicator() : const Text('সংরক্ষণ'),
              ),
            ],
          );
        },
      ),
    );
  }


  // Dialog: সঞ্চয় জমা নেওয়া (Add Deposit with instant Receipt popup)
  void _showAddDepositDialog(List<MemberModel> members) {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('আগে সদস্য যোগ করুন')));
      return;
    }

    MemberModel selectedMember = members.first;
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String depositType = 'মাসিক';
    DateTime selectedDate = DateTime.now();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('সঞ্চয় জমা এন্ট্রি'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<MemberModel>(
                    value: selectedMember,
                    decoration: const InputDecoration(labelText: 'সদস্য নির্বাচন করুন', border: OutlineInputBorder()),
                    items: members.map((m) => DropdownMenuItem(value: m, child: Text('[${m.memberNumber}] ${m.name}'))).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedMember = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: depositType,
                    decoration: const InputDecoration(labelText: 'জমার ধরণ', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'দৈনিক', child: Text('দৈনিক')),
                      DropdownMenuItem(value: 'সাপ্তাহিক', child: Text('সাপ্তাহিক')),
                      DropdownMenuItem(value: 'মাসিক', child: Text('মাসিক')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => depositType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'মন্তব্য / রসিদ নং', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(ctx), child: const Text('বাতিল')),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final amt = double.tryParse(amountController.text.trim());
                        if (amt == null || amt <= 0) return;

                        setDialogState(() => isSaving = true);
                        try {
                          await _somitiService.addDeposit(
                            somitiId: widget.somiti.id,
                            memberId: selectedMember.id,
                            memberName: selectedMember.name,
                            memberNumber: selectedMember.memberNumber,
                            amount: amt,
                            type: depositType,
                            date: selectedDate,
                            note: noteController.text.trim(),
                            recordedBy: widget.somiti.cashierName,
                            deviceSource: kIsWeb ? 'Web Browser' : 'Mobile Device',
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            // Open Digital Receipt directly!
                            _showReceiptDialog(
                              memberNumber: selectedMember.memberNumber,
                              memberName: selectedMember.name,
                              amount: amt,
                              type: depositType,
                              date: selectedDate,
                              note: noteController.text.trim(),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                        }
                      },
                child: isSaving ? const CircularProgressIndicator() : const Text('জমা ও রসিদ তৈরি'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog: খরচ এন্ট্রি (Add Expense)
  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String category = 'অফিস খরচ';
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('সমিতির নতুন খরচ এন্ট্রি'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'খরচের বিবরণ *', hintText: 'যেমন: খাতা ও স্টেশনারি', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'খরচের পরিমাণ (৳) *', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(labelText: 'ক্যাটাগরি', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'অফিস খরচ', child: Text('অফিস খরচ')),
                      DropdownMenuItem(value: 'আপ্যায়ন', child: Text('আপ্যায়ন')),
                      DropdownMenuItem(value: 'যাতায়াত', child: Text('যাতায়াত')),
                      DropdownMenuItem(value: 'সঞ্চয় ফেরত', child: Text('সঞ্চয় ফেরত')),
                      DropdownMenuItem(value: 'অন্যান্য', child: Text('অন্যান্য')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => category = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'নোট / ভাউচার', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: isSaving ? null : () => Navigator.pop(ctx), child: const Text('বাতিল')),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final title = titleController.text.trim();
                        final amt = double.tryParse(amountController.text.trim());
                        if (title.isEmpty || amt == null || amt <= 0) return;

                        setDialogState(() => isSaving = true);
                        try {
                          await _somitiService.addExpense(
                            somitiId: widget.somiti.id,
                            title: title,
                            amount: amt,
                            category: category,
                            date: DateTime.now(),
                            note: noteController.text.trim(),
                            recordedBy: widget.somiti.cashierName,
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('খরচ হিসাব সফলভাবে সংরক্ষিত হয়েছে')),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                        }
                      },
                child: isSaving ? const CircularProgressIndicator() : const Text('সংরক্ষণ'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _backupToDrive(List<MemberModel> members, List<DepositModel> deposits, List<ExpenseModel> expenses) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Google ড্রাইভে স্টেটমেন্ট আপলোড হচ্ছে...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final file = await _driveService.uploadSomitiBackupCsv(
        somiti: widget.somiti,
        members: members,
        deposits: deposits,
        expenses: expenses,
      );
      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
            title: const Text('Google ড্রাইভ ব্যাকআপ সম্পন্ন!'),
            content: Text('আপনার Google Drive-এ "${file?.name ?? 'Somiti_Statement.csv'}" সংরক্ষিত হয়েছে।'),
            actions: [
              FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('ঠিক আছে')),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ড্রাইভ ব্যাকআপ ব্যর্থ: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final somiti = widget.somiti;

    return StreamBuilder<List<MemberModel>>(
      stream: _somitiService.getMembersStream(somiti.id),
      builder: (context, memberSnapshot) {
        final members = memberSnapshot.data ?? [];

        return StreamBuilder<List<DepositModel>>(
          stream: _somitiService.getDepositsStream(somiti.id),
          builder: (context, depositSnapshot) {
            final deposits = depositSnapshot.data ?? [];

            return StreamBuilder<List<ExpenseModel>>(
              stream: _somitiService.getExpensesStream(somiti.id),
              builder: (context, expenseSnapshot) {
                final expenses = expenseSnapshot.data ?? [];

                final totalDeposit = members.fold(0.0, (sum, m) => sum + m.totalDeposit);
                final totalExpense = expenses.fold(0.0, (sum, e) => sum + e.amount);
                final cashInHand = totalDeposit - totalExpense;

                return Scaffold(
                  appBar: AppBar(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(somiti.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('কোড: ${somiti.somitiCode} • কোষাধ্যক্ষ: ${somiti.cashierName}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    actions: [
                      if (FeatureManagementService().canAccess('loan_management', somitiId: somiti.id))
                        IconButton(
                          tooltip: 'ঋণ ব্যবস্থাপনা',
                          icon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0F5132)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoanManagementScreen(
                                  somitiId: somiti.id,
                                  somitiName: somiti.name,
                                  currentUserName: widget.user.displayName ?? widget.user.email ?? 'এডমিন',
                                ),
                              ),
                            );
                          },
                        ),
                      if (FeatureManagementService().canAccess('financial_accounting', somitiId: somiti.id))
                        IconButton(
                          tooltip: 'হিসাব ও ক্যাশবহি',
                          icon: const Icon(Icons.account_balance_rounded, color: Color(0xFF1E293B)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccountingScreen(
                                  somitiId: somiti.id,
                                  somitiName: somiti.name,
                                  currentUserName: widget.user.displayName ?? widget.user.email ?? 'এডমিন',
                                ),
                              ),
                            );
                          },
                        ),
                      if (FeatureManagementService().canAccess('reports', somitiId: somiti.id))
                        IconButton(
                          tooltip: 'আর্থিক নিরীক্ষা (লাভ-ক্ষতি ও ব্যালেন্স শিট)',
                          icon: const Icon(Icons.analytics_outlined, color: Color(0xFF10B981)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FinancialReportsScreen(
                                  somitiId: somiti.id,
                                  somitiName: somiti.name,
                                ),
                              ),
                            );
                          },
                        ),
                      if ((widget.user.email ?? '').trim().toLowerCase() == 'hossansajjad1994@gmail.com')
                        IconButton(
                          tooltip: 'মাস্টার এডমিন কন্ট্রোল সেন্টার',
                          icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.amber),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MasterAdminScreen(userEmail: widget.user.email ?? '')),
                            );
                          },
                        ),
                      IconButton(
                        tooltip: 'সমিতির কোড কপি করুন',
                        icon: const Icon(Icons.share_rounded),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: somiti.somitiCode));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('সমিতি কোড (${somiti.somitiCode}) কপি হয়েছে! সদস্যদের সাথে শেয়ার করুন।')),
                          );
                        },
                      ),
                    ],
                  ),
                  body: Column(
                    children: [
                      // Official Pad Banner
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: theme.colorScheme.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(somiti.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text('অফিসিয়াল প্যাড', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                                ),
                              ],
                            ),
                            if (somiti.padHeader.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text('"${somiti.padHeader}"', style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                              ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (somiti.bkashNumber.isNotEmpty)
                                  Expanded(child: Text('📱 বিকাশ: ${somiti.bkashNumber}', style: const TextStyle(fontSize: 11))),
                                if (somiti.bankAccount.isNotEmpty)
                                  Expanded(child: Text('🏦 ব্যাংক: ${somiti.bankAccount}', style: const TextStyle(fontSize: 11))),
                              ],
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        child: IndexedStack(
                          index: _currentIndex,
                          children: [
                            _buildMembersTab(members),
                            _buildDepositsTab(deposits),
                            _buildExpensesTab(expenses),
                            _buildSummaryTab(members, deposits, expenses, totalDeposit, totalExpense, cashInHand),
                          ],
                        ),
                      ),
                    ],
                  ),
                  bottomNavigationBar: NavigationBar(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (i) => setState(() => _currentIndex = i),
                    destinations: const [
                      NavigationDestination(icon: Icon(Icons.people_outline_rounded), selectedIcon: Icon(Icons.people_rounded), label: 'সদস্যগণ'),
                      NavigationDestination(icon: Icon(Icons.payments_outlined), selectedIcon: Icon(Icons.payments_rounded), label: 'সঞ্চয় জমা'),
                      NavigationDestination(icon: Icon(Icons.money_off_rounded), selectedIcon: Icon(Icons.money_off_csred_rounded), label: 'খরচ খাতা'),
                      NavigationDestination(icon: Icon(Icons.pie_chart_outline_rounded), selectedIcon: Icon(Icons.pie_chart_rounded), label: 'ক্যাশ ও ড্রাইভ'),
                    ],
                  ),
                  floatingActionButton: _currentIndex == 0
                      ? FloatingActionButton.extended(
                          onPressed: _showAddMemberDialog,
                          icon: const Icon(Icons.person_add_rounded),
                          label: const Text('নতুন সদস্য'),
                        )
                      : _currentIndex == 1
                          ? FloatingActionButton.extended(
                              onPressed: () => _showAddDepositDialog(members),
                              icon: const Icon(Icons.add_card_rounded),
                              label: const Text('জমা ও রসিদ'),
                            )
                          : _currentIndex == 2
                              ? FloatingActionButton.extended(
                                  onPressed: _showAddExpenseDialog,
                                  icon: const Icon(Icons.receipt_long_rounded),
                                  label: const Text('নতুন খরচ'),
                                )
                              : null,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMembersTab(List<MemberModel> members) {
    if (members.isEmpty) {
      return const Center(child: Text('কোনো সদস্য নেই। নিচের বাটনে ট্যাপ করে সদস্য যোগ করুন।'));
    }
    final currencyFormat = NumberFormat('#,##,###');

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final m = members[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(m.memberNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('ফোন: ${m.phone.isEmpty ? 'নেই' : m.phone} • পাসবুক দেখতে ট্যাপ করুন'),
            trailing: Text(
              '৳${currencyFormat.format(m.totalDeposit)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
            ),
            onTap: () => _showMemberPassbookDialog(m),
          ),
        );
      },
    );
  }

  Widget _buildDepositsTab(List<DepositModel> deposits) {
    if (deposits.isEmpty) {
      return const Center(child: Text('কোনো জমা এন্ট্রি নেই।'));
    }
    final dateFormat = DateFormat('dd MMM, hh:mm a');
    final currencyFormat = NumberFormat('#,##,###');

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: deposits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = deposits[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.arrow_downward_rounded, color: Colors.green),
            ),
            title: Text('[${d.memberNumber}] ${d.memberName}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${d.type} জমা • ${dateFormat.format(d.date)} ${d.note.isNotEmpty ? '• ' + d.note : ''}', style: const TextStyle(fontSize: 12)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('৳${currencyFormat.format(d.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.receipt_rounded, size: 20, color: Colors.green),
                  tooltip: 'রসিদ দেখুন',
                  onPressed: () => _showReceiptDialog(
                    memberNumber: d.memberNumber,
                    memberName: d.memberName,
                    amount: d.amount,
                    type: d.type,
                    date: d.date,
                    note: d.note,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpensesTab(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return const Center(child: Text('কোনো খরচ এন্ট্রি নেই। নিচে "নতুন খরচ" বাটনে চাপুন।'));
    }
    final dateFormat = DateFormat('dd MMM, hh:mm a');
    final currencyFormat = NumberFormat('#,##,###');

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final e = expenses[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFFFEBEE),
              child: Icon(Icons.arrow_upward_rounded, color: Colors.red),
            ),
            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${e.category} • ${dateFormat.format(e.date)} ${e.note.isNotEmpty ? '• ' + e.note : ''}', style: const TextStyle(fontSize: 12)),
            trailing: Text('৳${currencyFormat.format(e.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab(
    List<MemberModel> members,
    List<DepositModel> deposits,
    List<ExpenseModel> expenses,
    double totalDeposit,
    double totalExpense,
    double cashInHand,
  ) {
    final currencyFormat = NumberFormat('#,##,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Hero Cash-in-hand Card
          Card(
            color: const Color(0xFF0F9D58),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('হাতে নগদ ক্যাশ (Cash in Hand)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text('৳${currencyFormat.format(cashInHand)}', style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('মোট সঞ্চয় জমা', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('৳${currencyFormat.format(totalDeposit)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Container(width: 1, height: 28, color: Colors.white24),
                      Column(
                        children: [
                          const Text('মোট খরচ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('৳${currencyFormat.format(totalExpense)}', style: const TextStyle(color: Color(0xFFFFCDD2), fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Text('মোট সদস্য', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${members.length} জন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Text('জমা এন্ট্রি', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${deposits.length} টি', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        const Text('খরচ এন্ট্রি', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${expenses.length} টি', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Advanced Enterprise Modules Section
          Row(
            children: [
              Expanded(
                child: Card(
                  elevation: 0,
                  color: const Color(0xFF0F5132).withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFF0F5132).withOpacity(0.2)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LoanManagementScreen(
                            somitiId: widget.somiti.id,
                            somitiName: widget.somiti.name,
                            currentUserName: widget.user.displayName ?? widget.user.email ?? 'এডমিন',
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0F5132), size: 28),
                          SizedBox(height: 6),
                          Text('ঋণ ব্যবস্থাপনা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F5132))),
                          SizedBox(height: 2),
                          Text('বিতরণ ও কিস্তি আদায়', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Card(
                  elevation: 0,
                  color: const Color(0xFF1E293B).withOpacity(0.08),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: const Color(0xFF1E293B).withOpacity(0.2)),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountingScreen(
                            somitiId: widget.somiti.id,
                            somitiName: widget.somiti.name,
                            currentUserName: widget.user.displayName ?? widget.user.email ?? 'এডমিন',
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Icon(Icons.account_balance_rounded, color: Color(0xFF1E293B), size: 28),
                          SizedBox(height: 6),
                          Text('হিসাব ও ক্যাশবহি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                          SizedBox(height: 2),
                          Text('তহবিল ও সাধারণ খতিয়ান', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Financial Reports Card
          Card(
            elevation: 0,
            color: const Color(0xFF10B981).withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: const Color(0xFF10B981).withOpacity(0.25)),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FinancialReportsScreen(
                      somitiId: widget.somiti.id,
                      somitiName: widget.somiti.name,
                    ),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF10B981),
                      child: Icon(Icons.analytics_rounded, color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('আর্থিক নিরীক্ষা ও স্টেটমেন্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F5132))),
                          Text('লাভ-ক্ষতি বিবরণী ও উদ্বৃত্তপত্র (ব্যালেন্স শিট)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF64748B)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_to_drive_rounded, color: Color(0xFF0F9D58), size: 26),
                      SizedBox(width: 10),
                      Text('Google Drive পূর্ণাঙ্গ ব্যাকআপ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'সদস্য তালিকা, জমার বিবরণী, খরচের হিসাব এবং হাতে নগদ ক্যাশের পূর্ণাঙ্গ অফিশিয়াল রিপোর্ট আপনার Google Drive-এ সরাসরি ব্যাকআপ রাখুন।',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _backupToDrive(members, deposits, expenses),
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text('Google ড্রাইভে পূর্ণাঙ্গ ব্যাকআপ নিন', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
