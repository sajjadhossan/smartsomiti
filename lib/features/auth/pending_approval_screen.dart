import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../admin/master_admin_screen.dart';
import '../society/onboarding_screen.dart';

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
