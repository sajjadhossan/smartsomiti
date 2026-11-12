import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'models/somiti_model.dart';
import 'models/member_model.dart';
import 'models/deposit_model.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/drive_service.dart';
import 'services/somiti_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
              if (somitis.isEmpty) {
                return OnboardingScreen(user: user);
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
/// ১. গুগল লগইন স্ক্রিন (Login Screen)
/// ============================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 72,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'স্মার্ট সমিতি প্ল্যাটফর্ম',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'যেকোনো সমিতির জন্য সম্পূর্ণ ডিজিটাল ব্যবস্থাপনা ও ক্লাউড সিঙ্ক প্ল্যাটফর্ম',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                _FeatureRow(
                  icon: Icons.add_business_rounded,
                  title: 'মাল্টি-সমিতি তৈরি ও ব্যবস্থাপনা',
                  subtitle: 'নিজস্ব প্যাড, লোগো, ঠিকানা, ব্যাংক ও বিকাশ একাউন্ট দিয়ে সমিতি চালু',
                ),
                const SizedBox(height: 16),
                _FeatureRow(
                  icon: Icons.sync_rounded,
                  title: 'রিয়েলটাইম ডিভাইস ও ওয়েব সিঙ্ক',
                  subtitle: 'এক মোবাইলে হিসাব দিলে সাথে সাথে অন্য সব ডিভাইসে আপডেট',
                ),
                const SizedBox(height: 16),
                _FeatureRow(
                  icon: Icons.add_to_drive_rounded,
                  title: 'Google ড্রাইভে পূর্ণাঙ্গ ব্যাকআপ',
                  subtitle: 'সমিতির সকল স্টেটমেন্ট সরাসরি আপনার ড্রাইভে সেভ থাকবে',
                ),
                const SizedBox(height: 40),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  FilledButton.icon(
                    onPressed: _handleGoogleSignIn,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text(
                      'Google দিয়ে সাইন-ইন করুন',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
              ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
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
              const Text('সমিতির মূল পরিচিতি', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'সমিতির নাম *',
                  hintText: 'যেমন: প্রগতি ক্ষুদ্র সমবায় সমিতি',
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
                  labelText: 'বিকাশ / নগদ নম্বর (মার্চেন্ট বা পার্সোনাল)',
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
                  hintText: widget.user.displayName ?? 'আপনি (এডমিন)',
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
                      ? const CircularProgressIndicator(color: whiteColor)
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

const Color whiteColor = Colors.white;

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

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final numberController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('নতুন সদস্য যোগ করুন'),
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
                    decoration: const InputDecoration(labelText: 'সদস্যের নাম', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'মোবাইল নম্বর', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
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
                        if (name.isEmpty || number.isEmpty) return;

                        setDialogState(() => isSaving = true);
                        try {
                          await _somitiService.addMember(
                            somitiId: widget.somiti.id,
                            name: name,
                            phone: phone,
                            memberNumber: number,
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('সদস্য সফলভাবে যুক্ত ও সিঙ্ক হয়েছে')),
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
                            recordedBy: widget.user.email ?? 'এডমিন',
                            deviceSource: kIsWeb ? 'Web Browser' : 'Mobile Device',
                          );
                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('জমা সফলভাবে লিপিবদ্ধ ও সিঙ্ক হয়েছে')),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                        }
                      },
                child: isSaving ? const CircularProgressIndicator() : const Text('জমা করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _backupToDrive(List<MemberModel> members, List<DepositModel> deposits) async {
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
      final file = await _driveService.uploadSomitiBackupCsv(members: members, deposits: deposits);
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
            final totalFund = members.fold(0.0, (sum, m) => sum + m.totalDeposit);

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(somiti.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    Text('কোড: ${somiti.somitiCode}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                  ],
                ),
                actions: [
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
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(somiti.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
                            child: Text(somiti.padHeader, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                          ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (somiti.bkashNumber.isNotEmpty)
                              Expanded(child: Text('📱 বিকাশ/নগদ: ${somiti.bkashNumber}', style: const TextStyle(fontSize: 11))),
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
                        _buildSummaryTab(members, deposits, totalFund),
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
                  NavigationDestination(icon: Icon(Icons.pie_chart_outline_rounded), selectedIcon: Icon(Icons.pie_chart_rounded), label: 'রিপোর্ট ও ড্রাইভ'),
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
                          label: const Text('জমা এন্ট্রি'),
                        )
                      : null,
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
            subtitle: Text('ফোন: ${m.phone.isEmpty ? 'নেই' : m.phone}'),
            trailing: Text(
              '৳${currencyFormat.format(m.totalDeposit)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
            ),
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
            trailing: Text('৳${currencyFormat.format(d.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16)),
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab(List<MemberModel> members, List<DepositModel> deposits, double totalFund) {
    final currencyFormat = NumberFormat('#,##,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('সমিতির মোট সঞ্চিত তহবিল', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('৳${currencyFormat.format(totalFund)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('মোট সদস্য', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${members.length} জন', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text('মোট জমা এন্ট্রি', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text('${deposits.length} টি', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_to_drive_rounded, color: Color(0xFF0F9D58), size: 28),
                      SizedBox(width: 10),
                      Text('Google Drive ব্যাকআপ', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'সমিতির সকল সদস্য ও সম্পূর্ণ জমা স্টেটমেন্ট CSV ফরমেটে তৈরি করে আপনার ব্যক্তিগত Google Drive-এ সেভ রাখুন।',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _backupToDrive(members, deposits),
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text('Google ড্রাইভে রিপোর্ট ব্যাকআপ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
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
