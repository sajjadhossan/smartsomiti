import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/somiti_service.dart';
import 'create_somiti_screen.dart';
import '../dashboard/somiti_main_dashboard.dart';

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
