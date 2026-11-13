import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/somiti_model.dart';
import '../../services/auth_service.dart';
import '../admin/master_admin_screen.dart';
import 'create_somiti_screen.dart';
import '../dashboard/somiti_main_dashboard.dart';

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
