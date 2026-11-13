import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/feature_flag_model.dart';
import '../../models/somiti_model.dart';
import '../../services/feature_management_service.dart';

class MasterAdminScreen extends StatefulWidget {
  final String userEmail;
  const MasterAdminScreen({super.key, required this.userEmail});

  @override
  State<MasterAdminScreen> createState() => _MasterAdminScreenState();
}

class _MasterAdminScreenState extends State<MasterAdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FeatureManagementService _featureService = FeatureManagementService();
  String _searchQuery = '';
  String? _selectedSocietyId; // null = Global Platform Mode, non-null = Society-Specific Mode
  List<SomitiModel> _availableSocieties = [];
  bool _isLoadingSocieties = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _featureService.initialize();
    _loadSocieties();
  }

  Future<void> _loadSocieties() async {
    setState(() => _isLoadingSocieties = true);
    try {
      final snap = await FirebaseFirestore.instance.collection('somitis').get();
      setState(() {
        _availableSocieties = snap.docs.map((d) => SomitiModel.fromSnapshot(d)).toList();
        _isLoadingSocieties = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingSocieties = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('প্ল্যাটফর্ম মাস্টার এডমিন কন্ট্রোল সেন্টার', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Master Admin Global Control Center & Feature Matrix', style: TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFF10B981),
          tabs: const [
            Tab(icon: Icon(Icons.tune_rounded), text: 'মডিউল ও ফিচার সুইচ'),
            Tab(icon: Icon(Icons.domain_verification_rounded), text: 'সমিতি ভিত্তিক নিয়ন্ত্রণ'),
            Tab(icon: Icon(Icons.history_edu_rounded), text: 'অডিট হিস্ট্রি লগ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGlobalFeaturesTab(theme),
          _buildSocietySpecificTab(theme),
          _buildAuditLogsTab(theme),
        ],
      ),
    );
  }

  // ============================================================================
  // TAB 1: GLOBAL MODULES & SUB-FEATURES CONTROLS
  // ============================================================================
  Widget _buildGlobalFeaturesTab(ThemeData theme) {
    return Column(
      children: [
        // Top Toolbar: Search & Bulk Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'মডিউল বা ফিচার খুঁজুন (Search)...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: theme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                ),
              ),
              const SizedBox(width: 10),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded),
                tooltip: 'বাল্ক একশন',
                onSelected: (val) async {
                  if (val == 'enable_all') {
                    for (final m in MasterFeatureRegistry.allModules) {
                      await _featureService.toggleGlobalModule(moduleKey: m.key, isEnabled: true, adminEmail: widget.userEmail);
                    }
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ সকল মডিউল সক্রিয় করা হয়েছে')));
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(value: 'enable_all', child: Text('সবগুলো মডিউল অন করুন')),
                ],
              ),
            ],
          ),
        ),

        // List of 24 Modules with collapsible sub-features
        Expanded(
          child: AnimatedBuilder(
            animation: _featureService.changeNotifier,
            builder: (context, _) {
              final filteredModules = MasterFeatureRegistry.allModules.where((m) {
                if (_searchQuery.isEmpty) return true;
                final matchTitle = m.title.toLowerCase().contains(_searchQuery);
                final matchSub = m.subFeatures.any((s) => s.title.toLowerCase().contains(_searchQuery));
                return matchTitle || matchSub;
              }).toList();

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: filteredModules.length,
                itemBuilder: (ctx, i) {
                  final module = filteredModules[i];
                  final isModuleActive = _featureService.canAccess(
                    featureKey: module.key,
                    userEmail: widget.userEmail,
                  );

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ExpansionTile(
                      leading: Text(module.icon, style: const TextStyle(fontSize: 24)),
                      title: Text(module.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      subtitle: Text(module.description, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                      trailing: Switch(
                        value: isModuleActive,
                        activeColor: const Color(0xFF10B981),
                        onChanged: (val) async {
                          await _featureService.toggleGlobalModule(
                            moduleKey: module.key,
                            isEnabled: val,
                            adminEmail: widget.userEmail,
                          );
                        },
                      ),
                      children: module.subFeatures.map((sub) {
                        final isSubActive = _featureService.canAccess(
                          featureKey: sub.key,
                          userEmail: widget.userEmail,
                        );

                        return Container(
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: theme.dividerColor.withOpacity(0.2))),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
                            title: Row(
                              children: [
                                Text(sub.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                if (sub.isCore) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(4)),
                                    child: const Text('CORE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.brown)),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(sub.description, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                            trailing: Switch(
                              value: isSubActive,
                              activeColor: const Color(0xFF10B981),
                              onChanged: sub.isCore
                                  ? null // Core features cannot be disabled
                                  : (val) async {
                                      await _featureService.toggleGlobalFeature(
                                        featureKey: sub.key,
                                        isEnabled: val,
                                        adminEmail: widget.userEmail,
                                      );
                                    },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB 2: SOCIETY-SPECIFIC OVERRIDE MATRIX
  // ============================================================================
  Widget _buildSocietySpecificTab(ThemeData theme) {
    if (_isLoadingSocieties) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_availableSocieties.isEmpty) {
      return const Center(child: Text('কোনো সমিতি পাওয়া যায়নি।'));
    }

    return Column(
      children: [
        // Society Picker Dropdown
        Container(
          padding: const EdgeInsets.all(14),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Row(
            children: [
              const Text('সমিতি নির্বাচন করুন: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSocietyId ?? _availableSocieties.first.id,
                  isDense: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: theme.cardColor,
                  ),
                  items: _availableSocieties.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.name} (${s.somitiCode})', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedSocietyId = val);
                      _featureService.watchSocietyFeatures(val);
                    }
                  },
                ),
              ),
            ],
          ),
        ),

        // Society-specific toggle list
        Expanded(
          child: AnimatedBuilder(
            animation: _featureService.changeNotifier,
            builder: (context, _) {
              final currentSocId = _selectedSocietyId ?? _availableSocieties.first.id;

              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.blue, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'এখানে আপনি নির্দিষ্ট এই সমিতির জন্য কোনো ফিচার আলাদাভাবে বন্ধ বা চালু করতে পারেন। গ্লোবালি বন্ধ থাকা ফিচার এখানে কার্যকর হবে না।',
                            style: TextStyle(fontSize: 11.5, color: Colors.blueGrey),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Feature Cards
                  ...MasterFeatureRegistry.allModules.map((m) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        leading: Text(m.icon, style: const TextStyle(fontSize: 20)),
                        title: Text(m.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        children: m.subFeatures.map((sub) {
                          final isEnabled = _featureService.canAccess(
                            featureKey: sub.key,
                            societyId: currentSocId,
                            userEmail: widget.userEmail,
                          );

                          return ListTile(
                            dense: true,
                            title: Text(sub.title, style: const TextStyle(fontSize: 12.5)),
                            subtitle: Text(sub.description, style: const TextStyle(fontSize: 10.5)),
                            trailing: Switch(
                              value: isEnabled,
                              activeColor: const Color(0xFF10B981),
                              onChanged: (val) async {
                                await _featureService.toggleSocietyFeature(
                                  societyId: currentSocId,
                                  featureKey: sub.key,
                                  isEnabled: val,
                                  adminEmail: widget.userEmail,
                                );
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // TAB 3: IMMUTABLE AUDIT LOGS TRAIL
  // ============================================================================
  Widget _buildAuditLogsTab(ThemeData theme) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('audit_logs')
          .orderBy('timestamp', descending: true)
          .limit(100)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(child: Text('কোনো অডিট লগ রেকর্ড নেই।'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (ctx, i) {
            final data = docs[i].data();
            final action = data['action'] ?? 'UNKNOWN';
            final details = data['details'] ?? '';
            final user = data['userEmail'] ?? 'System';

            DateTime dt = DateTime.now();
            final ts = data['timestamp'];
            if (ts is Timestamp) dt = ts.toDate();

            return ListTile(
              dense: true,
              leading: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFF1F5F9),
                child: Icon(Icons.shield_rounded, size: 16, color: Color(0xFF475569)),
              ),
              title: Text(action, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
              subtitle: Text('$details\nদ্বারা: $user | সময়: ${dt.toLocal().toString().split(".")[0]}', style: const TextStyle(fontSize: 11)),
            );
          },
        );
      },
    );
  }
}
