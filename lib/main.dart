import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'models/member_model.dart';
import 'models/deposit_model.dart';
import 'models/user_profile.dart';
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
      title: 'সমিতি ম্যানেজার',
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;
        if (user != null) {
          somitiService.ensureUserProfile(user);

          return StreamBuilder<UserProfile>(
            stream: somitiService.getUserProfileStream(user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final profile = profileSnapshot.data ??
                  UserProfile(
                    uid: user.uid,
                    email: user.email ?? '',
                    displayName: user.displayName ?? '',
                    role: 'admin',
                  );

              if (profile.role == 'member') {
                return SomitiMemberDashboard(user: user, profile: profile);
              }

              return SomitiAdminDashboard(user: user, profile: profile);
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}

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
                  'সমিতি ম্যানেজার',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'এডমিন ও সদস্য উভয় মোডসহ রিয়েলটাইম ক্লাউড সিঙ্ক এবং ড্রাইভ ব্যাকআপ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                _FeatureRow(
                  icon: Icons.admin_panel_settings_outlined,
                  title: 'এডমিন ও সদস্য প্যানেল',
                  subtitle: 'ম্যানেজারদের জন্য পূর্ণ হিসাব এবং সদস্যদের জন্য নিজস্ব সঞ্চয় খাতা',
                ),
                const SizedBox(height: 16),
                _FeatureRow(
                  icon: Icons.sync_rounded,
                  title: 'রিয়েলটাইম ক্রস-ডিভাইস সিঙ্ক',
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
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
/// ১. এডমিন ড্যাশবোর্ড (Somiti Admin Dashboard)
/// ============================================================
class SomitiAdminDashboard extends StatefulWidget {
  final User user;
  final UserProfile profile;
  const SomitiAdminDashboard({super.key, required this.user, required this.profile});

  @override
  State<SomitiAdminDashboard> createState() => _SomitiAdminDashboardState();
}

class _SomitiAdminDashboardState extends State<SomitiAdminDashboard> {
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
                    decoration: const InputDecoration(
                      labelText: 'সদস্য নং (যেমন: 01)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'সদস্যের নাম',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'মোবাইল নম্বর',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        final number = numberController.text.trim();

                        if (name.isEmpty || number.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('নাম এবং সদস্য নম্বর আবশ্যক')),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);
                        try {
                          await _somitiService.addMember(
                            userId: widget.user.uid,
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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ত্রুটি: $e')),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('সংরক্ষণ'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddDepositDialog(List<MemberModel> members) {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আগে সদস্য যোগ করুন')),
      );
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
            title: const Text('নতুন সঞ্চয় / চাঁদা জমা'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<MemberModel>(
                    value: selectedMember,
                    decoration: const InputDecoration(
                      labelText: 'সদস্য নির্বাচন করুন',
                      border: OutlineInputBorder(),
                    ),
                    items: members.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text('[${m.memberNumber}] ${m.name}'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedMember = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'টাকার পরিমাণ (৳)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: depositType,
                    decoration: const InputDecoration(
                      labelText: 'জমার ধরণ',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'দৈনিক', child: Text('দৈনিক')),
                      DropdownMenuItem(value: 'সাপ্তাহিক', child: Text('সাপ্তাহিক')),
                      DropdownMenuItem(value: 'মাসিক', child: Text('মাসিক')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => depositType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'মন্তব্য (ঐচ্ছিক)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(ctx),
                child: const Text('বাতিল'),
              ),
              FilledButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final amtStr = amountController.text.trim();
                        final amount = double.tryParse(amtStr);
                        if (amount == null || amount <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('সঠিক জমার পরিমাণ দিন')),
                          );
                          return;
                        }

                        setDialogState(() => isSaving = true);
                        try {
                          final device = kIsWeb ? 'Web Browser' : 'Mobile Device';
                          await _somitiService.addDeposit(
                            userId: widget.user.uid,
                            memberId: selectedMember.id,
                            memberName: selectedMember.name,
                            memberNumber: selectedMember.memberNumber,
                            amount: amount,
                            type: depositType,
                            date: selectedDate,
                            note: noteController.text.trim(),
                            deviceSource: device,
                          );

                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('জমা সফলভাবে লিপিবদ্ধ ও সিঙ্ক হয়েছে')),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSaving = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('ত্রুটি: $e')),
                          );
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('জমা করুন'),
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
      builder: (ctx) => const Center(
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
        members: members,
        deposits: deposits,
      );

      if (mounted) {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            icon: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
            title: const Text('Google ড্রাইভ ব্যাকআপ সম্পন্ন!'),
            content: Text(
              'আপনার Google Drive-এ "${file?.name ?? 'Somiti_Statement.csv'}" সফলভাবে সংরক্ষিত হয়েছে।',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ঠিক আছে'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ড্রাইভ ব্যাকআপ ব্যর্থ হয়েছে: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = widget.user;

    return StreamBuilder<List<MemberModel>>(
      stream: _somitiService.getMembersStream(user.uid),
      builder: (context, memberSnapshot) {
        final members = memberSnapshot.data ?? [];

        return StreamBuilder<List<DepositModel>>(
          stream: _somitiService.getDepositsStream(user.uid),
          builder: (context, depositSnapshot) {
            final deposits = depositSnapshot.data ?? [];
            final totalFund = members.fold(0.0, (sum, m) => sum + m.totalDeposit);

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'সমিতি ম্যানেজার',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'এডমিন',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      user.email ?? '',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                actions: [
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (val) async {
                      if (val == 'switch_member') {
                        await _somitiService.switchRole(user.uid, 'member');
                      } else if (val == 'logout') {
                        await AuthService().signOut();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'switch_member',
                        child: Row(
                          children: [
                            Icon(Icons.person_pin_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('সদস্য মোড দেখুন'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('লগআউট'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: Colors.green.withOpacity(0.12),
                    child: const Row(
                      children: [
                        Icon(Icons.sensors_rounded, color: Colors.green, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'লাইভ ক্লাউড সিঙ্ক সক্রিয় (এডমিন মোড)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
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
                  NavigationDestination(
                    icon: Icon(Icons.people_outline_rounded),
                    selectedIcon: Icon(Icons.people_rounded),
                    label: 'সদস্যগণ',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.payments_outlined),
                    selectedIcon: Icon(Icons.payments_rounded),
                    label: 'সঞ্চয় জমা',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.pie_chart_outline_rounded),
                    selectedIcon: Icon(Icons.pie_chart_rounded),
                    label: 'রিপোর্ট ও ড্রাইভ',
                  ),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_add_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'কোনো সদস্য নেই',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text('নিচের বাটনে ট্যাপ করে নতুন সদস্য যোগ করুন।'),
          ],
        ),
      );
    }

    final currencyFormat = NumberFormat('#,##,###');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final member = members[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                member.memberNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            title: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('ফোন: ${member.phone.isEmpty ? 'দেওয়া হয়নি' : member.phone}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'মোট সঞ্চয়',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  '৳${currencyFormat.format(member.totalDeposit)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepositsTab(List<DepositModel> deposits) {
    if (deposits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'কোনো জমা এন্ট্রি নেই',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 6),
            Text('নিচের বাটনে ট্যাপ করে নতুন জমা লিপিবদ্ধ করুন।'),
          ],
        ),
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final currencyFormat = NumberFormat('#,##,###');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: deposits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final deposit = deposits[index];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.arrow_downward_rounded, color: Colors.green),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '[${deposit.memberNumber}] ${deposit.memberName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '৳${currencyFormat.format(deposit.amount)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        deposit.type,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(deposit.date),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                if (deposit.note.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('নোট: ${deposit.note}', style: const TextStyle(fontSize: 12)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryTab(
    List<MemberModel> members,
    List<DepositModel> deposits,
    double totalFund,
  ) {
    final currencyFormat = NumberFormat('#,##,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'সমিতির মোট সঞ্চিত তহবিল',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '৳${currencyFormat.format(totalFund)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MetricCard(
                  icon: Icons.people_alt_rounded,
                  title: 'মোট সদস্য',
                  value: '${members.length} জন',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricCard(
                  icon: Icons.receipt_rounded,
                  title: 'মোট জমা এন্ট্রি',
                  value: '${deposits.length} টি',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 2,
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
                      Text(
                        'Google Drive ব্যাকআপ',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'সমিতির সকল সদস্য তালিকা এবং সম্পূর্ণ জমা স্টেটমেন্ট CSV ফরমেটে তৈরি করে আপনার ব্যক্তিগত Google Drive-এ স্বয়ংক্রিয়ভাবে ব্যাকআপ রাখুন।',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _backupToDrive(members, deposits),
                      icon: const Icon(Icons.cloud_upload_rounded),
                      label: const Text(
                        'Google ড্রাইভে রিপোর্ট ব্যাকআপ করুন',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
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

/// ============================================================
/// ২. সদস্য ড্যাশবোর্ড (Somiti Member Dashboard)
/// ============================================================
class SomitiMemberDashboard extends StatelessWidget {
  final User user;
  final UserProfile profile;
  const SomitiMemberDashboard({super.key, required this.user, required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final somitiService = SomitiService();
    final currencyFormat = NumberFormat('#,##,###');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'আমার সঞ্চয় খাতা',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'সদস্য ভিউ',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              user.email ?? '',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (val) async {
              if (val == 'switch_admin') {
                await somitiService.switchRole(user.uid, 'admin');
              } else if (val == 'logout') {
                await AuthService().signOut();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'switch_admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('এডমিন প্যানেলে যান'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('লগআউট'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<DepositModel>>(
        stream: somitiService.getDepositsStream(user.uid),
        builder: (context, snapshot) {
          final deposits = snapshot.data ?? [];
          final double myTotal = deposits.fold(0.0, (sum, d) => sum + d.amount);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.withOpacity(0.12),
                child: const Row(
                  children: [
                    Icon(Icons.sensors_rounded, color: Colors.blue, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'লাইভ সিঙ্ক সক্রিয়: এডমিন জমা তুললে এখানে সাথে সাথে দেখতে পাবেন',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          'আপনার মোট সঞ্চয় জমা',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '৳${currencyFormat.format(myTotal)}',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.history_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'জমার বিবরণী (${deposits.length} টি)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: deposits.isEmpty
                    ? const Center(
                        child: Text(
                          'এখনও কোনো জমা এন্ট্রি পাওয়া যায়নি।',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                child: Icon(Icons.check_rounded, color: Colors.green),
                              ),
                              title: Text(
                                '৳${currencyFormat.format(d.amount)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text(
                                '${d.type} জমা • ${dateFormat.format(d.date)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: d.note.isNotEmpty
                                  ? Tooltip(
                                      message: d.note,
                                      child: const Icon(Icons.info_outline, size: 18),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
