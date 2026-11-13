import 'package:flutter/material.dart';
import '../../models/loan_model.dart';
import '../../models/member_model.dart';
import '../../models/financial_account_model.dart';
import '../../services/loan_service.dart';
import '../../services/accounting_service.dart';
import '../../services/somiti_service.dart';

class LoanManagementScreen extends StatefulWidget {
  final String somitiId;
  final String somitiName;
  final String currentUserName;

  const LoanManagementScreen({
    super.key,
    required this.somitiId,
    required this.somitiName,
    required this.currentUserName,
  });

  @override
  State<LoanManagementScreen> createState() => _LoanManagementScreenState();
}

class _LoanManagementScreenState extends State<LoanManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LoanService _loanService = LoanService();
  final AccountingService _accountingService = AccountingService();
  final SomitiService _somitiService = SomitiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.somitiName} — ঋণ ব্যবস্থাপনা', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0F5132),
        foregroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFC107),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_wallet_outlined, size: 20), text: 'চলমান ঋণ'),
            Tab(icon: Icon(Icons.assignment_outlined, size: 20), text: 'ঋণের আবেদন'),
            Tab(icon: Icon(Icons.post_add_rounded, size: 20), text: 'নতুন আবেদন'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActiveLoansTab(),
          _buildApplicationsTab(),
          _buildNewApplicationForm(),
        ],
      ),
    );
  }

  // ================= TAB 1: চলমান ঋণ (Active Loans) =================
  Widget _buildActiveLoansTab() {
    return StreamBuilder<List<LoanModel>>(
      stream: _loanService.getLoansStream(widget.somitiId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F5132)));
        }

        final loans = snapshot.data ?? [];
        double totalDisbursed = 0.0;
        double totalCollected = 0.0;
        double totalOutstanding = 0.0;

        for (var l in loans) {
          totalDisbursed += l.principalAmount;
          totalCollected += l.totalPaid;
          totalOutstanding += l.outstandingBalance;
        }

        return Column(
          children: [
            // KPI Overview Banner
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(child: _buildKpiCard('মোট বিতরণ', '৳${totalDisbursed.toStringAsFixed(0)}', const Color(0xFF1E293B), Icons.outbox_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildKpiCard('মোট আদায়', '৳${totalCollected.toStringAsFixed(0)}', const Color(0xFF0F5132), Icons.move_to_inbox_rounded)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildKpiCard('অবশিষ্ট বাকি', '৳${totalOutstanding.toStringAsFixed(0)}', const Color(0xFFDC2626), Icons.pending_actions_rounded)),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            Expanded(
              child: loans.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_rounded, size: 60, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text('এখনো কোনো ঋণ বিতরণ করা হয়নি', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: loans.length,
                      itemBuilder: (context, index) {
                        return _buildLoanCard(loans[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Flexible(child: Text(title, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildLoanCard(LoanModel loan) {
    final double progress = loan.totalPayable > 0 ? (loan.totalPaid / loan.totalPayable).clamp(0.0, 1.0) : 0.0;
    final bool isSettled = loan.outstandingBalance <= 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSettled ? const Color(0xFF10B981) : const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFF0F5132).withOpacity(0.1),
                      child: const Icon(Icons.person, color: Color(0xFF0F5132), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loan.memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                        Text('সদস্য নং: ${loan.memberNumber}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (!isSettled && loan.schedule.any((s) => !s.isPaid && s.dueDate.isBefore(DateTime.now())))
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Text('⚠️ কিস্তি বকেয়া', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSettled ? const Color(0xFFDEF7EC) : const Color(0xFFFEF08A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isSettled ? 'পরিশোধিত' : 'চলমান',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSettled ? const Color(0xFF03543F) : const Color(0xFF854D0E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMiniMetric('মূল ঋণ', '৳${loan.principalAmount.toStringAsFixed(0)}'),
                  _buildMiniMetric('মোট পরিশোধযোগ্য', '৳${loan.totalPayable.toStringAsFixed(0)}'),
                  _buildMiniMetric('মোট আদায়', '৳${loan.totalPaid.toStringAsFixed(0)}'),
                  _buildMiniMetric('বাকি আছে', '৳${loan.outstandingBalance.toStringAsFixed(0)}', isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Progress Bar and Realtime Ratio (Tips 35 & 36)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'আদায় অনুপাত: ৳${loan.totalPaid.toStringAsFixed(0)} / ৳${loan.totalPayable.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% সম্পন্ন',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F5132)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(isSettled ? const Color(0xFF10B981) : const Color(0xFF0F5132)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAmortizationSchedule(loan),
                    icon: const Icon(Icons.calendar_month_outlined, size: 16),
                    label: const Text('সূচি দেখুন', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E293B),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                if (!isSettled) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showRepaymentDialog(loan),
                      icon: const Icon(Icons.add_task_rounded, size: 16),
                      label: const Text('কিস্তি আদায়', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F5132),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFFDC2626) : const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ================= TAB 2: ঋণের আবেদন (Loan Applications) =================
  Widget _buildApplicationsTab() {
    return StreamBuilder<List<LoanApplicationModel>>(
      stream: _loanService.getLoanApplicationsStream(widget.somitiId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF0F5132)));
        }

        final apps = snapshot.data ?? [];
        if (apps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('কোনো ঋণের আবেদন জমা নেই', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            final bool isPending = app.status == 'pending';
            final bool isApproved = app.status == 'approved';
            final bool isDisbursed = app.status == 'disbursed';

            Color statusColor = const Color(0xFFD97706);
            String statusText = 'অপেক্ষমাণ';
            if (isApproved) {
              statusColor = const Color(0xFF2563EB);
              statusText = 'অনুমোদিত';
            } else if (isDisbursed) {
              statusColor = const Color(0xFF16A34A);
              statusText = 'বিতরণকৃত';
            } else if (app.status == 'rejected') {
              statusColor = const Color(0xFFDC2626);
              statusText = 'বাতিল';
            }

            return Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(app.memberName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('সদস্য নং: ${app.memberNumber} • মোবাইল: ${app.memberPhone}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text('আবেদনের পরিমাণ: ৳${app.requestedAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5132))),
                        const Text('  •  ', style: TextStyle(color: Color(0xFF94A3B8))),
                        Text('মেয়াদ: ${app.durationMonths} মাস', style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('উদ্দেশ্য: ${app.purpose}', style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
                    if (app.guarantorName.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('জামিনদার: ${app.guarantorName} (${app.guarantorPhone})', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                    const SizedBox(height: 12),

                    // Action buttons based on status
                    if (isPending) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _reviewApplication(app, approve: false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side: const BorderSide(color: Color(0xFFFCA5A5)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('বাতিল করুন'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _reviewApplication(app, approve: true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F5132),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('অনুমোদন করুন'),
                            ),
                          ),
                        ],
                      ),
                    ] else if (isApproved) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showDisbursementModal(app),
                          icon: const Icon(Icons.payments_outlined, size: 18),
                          label: const Text('ঋণ বিতরণ করুন (ক্যাশ আউট)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= TAB 3: নতুন ঋণের আবেদন ফরম =================
  Widget _buildNewApplicationForm() {
    final formKey = GlobalKey<FormState>();
    String selectedMemberId = '';
    String selectedMemberName = '';
    String selectedMemberNumber = '';
    String memberPhone = '';
    double requestedAmount = 0.0;
    int durationMonths = 12;
    double interestRate = 10.0;
    LoanInterestType interestType = LoanInterestType.flat;
    String purpose = '';
    String guarantorName = '';
    String guarantorPhone = '';
    String guarantorRelation = '';

    return StatefulBuilder(
      builder: (context, setFormState) {
        // Estimated monthly calculation
        double estInterest = requestedAmount * (interestRate / 100.0) * (durationMonths / 12.0);
        double estTotal = requestedAmount + estInterest;
        double estMonthly = durationMonths > 0 ? (estTotal / durationMonths) : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('নতুন ঋণের আবেদন ফরম', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 6),
                const Text('সদস্য নির্বাচন করে ঋণের আবেদন ও সুদের হিসাব সম্পন্ন করুন', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 16),

                // Member selector from SomitiService
                StreamBuilder<List<MemberModel>>(
                  stream: _somitiService.getMembersStream(widget.somitiId),
                  builder: (context, snap) {
                    final members = snap.data ?? [];
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'ঋণগ্রহীতা সদস্য নির্বাচন করুন *',
                        prefixIcon: const Icon(Icons.person_search_rounded, color: Color(0xFF0F5132)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      value: selectedMemberId.isEmpty ? null : selectedMemberId,
                      items: members.map((m) {
                        return DropdownMenuItem<String>(
                          value: m.id,
                          child: Text('${m.name} (নং ${m.memberNumber})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final m = members.firstWhere((x) => x.id == val);
                          setFormState(() {
                            selectedMemberId = m.id;
                            selectedMemberName = m.name;
                            selectedMemberNumber = m.memberNumber;
                            memberPhone = m.phone;
                          });
                        }
                      },
                      validator: (val) => val == null || val.isEmpty ? 'সদস্য নির্বাচন করুন' : null,
                    );
                  },
                ),
                const SizedBox(height: 14),

                // Requested Amount & Duration
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'ঋণের পরিমাণ (টাকা) *',
                          prefixText: '৳ ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (val) {
                          setFormState(() {
                            requestedAmount = double.tryParse(val) ?? 0.0;
                          });
                        },
                        validator: (val) {
                          final v = double.tryParse(val ?? '');
                          if (v == null || v <= 0) return 'সঠিক পরিমাণ দিন';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        initialValue: '12',
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'মেয়াদ (মাস) *',
                          suffixText: 'মাস',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (val) {
                          setFormState(() {
                            durationMonths = int.tryParse(val) ?? 12;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Interest Rate & Type
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '10.0',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'সুদের হার (%) *',
                          suffixText: '% বার্ষিক',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (val) {
                          setFormState(() {
                            interestRate = double.tryParse(val) ?? 10.0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<LoanInterestType>(
                        decoration: InputDecoration(
                          labelText: 'সুদ পদ্ধতি *',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        value: interestType,
                        items: const [
                          DropdownMenuItem(value: LoanInterestType.flat, child: Text('সরল সুদ (Flat)')),
                          DropdownMenuItem(value: LoanInterestType.reducing, child: Text('হ্রাসমান (EMI)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setFormState(() => interestType = val);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Loan Calculation Preview Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5132).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF0F5132).withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('মোট প্রদেয় সুদ', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          Text('৳${estInterest.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F5132))),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('মোট পরিশোধযোগ্য', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          Text('৳${estTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('সম্ভাব্য মাসিক কিস্তি', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                          Text('৳${estMonthly.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Purpose
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'ঋণ গ্রহণের উদ্দেশ্য *',
                    hintText: 'যেমন: ব্যবসা সম্প্রসারণ, কৃষি উপকরণ ক্রয় ইত্যাদি',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (val) => purpose = val,
                  validator: (val) => val == null || val.trim().isEmpty ? 'উদ্দেশ্য উল্লেখ করুন' : null,
                ),
                const SizedBox(height: 14),

                // Guarantor Info
                const Text('জামিনদারের তথ্য', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'জামিনদারের নাম',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (val) => guarantorName = val,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'মোবাইল নম্বর',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onChanged: (val) => guarantorPhone = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      try {
                        final app = LoanApplicationModel(
                          id: '',
                          memberId: selectedMemberId,
                          memberName: selectedMemberName,
                          memberNumber: selectedMemberNumber,
                          memberPhone: memberPhone,
                          requestedAmount: requestedAmount,
                          durationMonths: durationMonths,
                          interestType: interestType,
                          proposedInterestRate: interestRate,
                          purpose: purpose,
                          guarantorName: guarantorName,
                          guarantorPhone: guarantorPhone,
                          status: 'pending',
                          appliedAt: DateTime.now(),
                          appliedBy: widget.currentUserName,
                        );

                        await _loanService.submitLoanApplication(widget.somitiId, app);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ঋণের আবেদন সফলভাবে দাখিল করা হয়েছে!'), backgroundColor: Color(0xFF0F5132)),
                          );
                          _tabController.animateTo(1);
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5132),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Text('আবেদন জমা দিন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= MODALS & ACTIONS =================

  /// Amortization Schedule Dialog
  void _showAmortizationSchedule(LoanModel loan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${loan.memberName} — কিস্তি পরিশোধ সূচি', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: double.maxFinite,
            height: 400,
            child: loan.schedule.isEmpty
                ? const Center(child: Text('কোনো সূচি তৈরি করা হয়নি'))
                : ListView.separated(
                    itemCount: loan.schedule.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final item = loan.schedule[i];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 12,
                          backgroundColor: item.isPaid ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                          child: Text('${item.installmentNo}', style: TextStyle(fontSize: 11, color: item.isPaid ? Colors.white : const Color(0xFF1E293B))),
                        ),
                        title: Text('কিস্তি ৳${item.totalInstallmentAmount.toStringAsFixed(0)} (আসল: ৳${item.principalPortion.toStringAsFixed(0)} + সুদ: ৳${item.interestPortion.toStringAsFixed(0)})'),
                        subtitle: Text('তারিখ: ${item.dueDate.day}/${item.dueDate.month}/${item.dueDate.year}'),
                        trailing: item.isPaid
                            ? const Text('পরিশোধিত', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11))
                            : const Text('বকেয়া', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 11)),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করুন')),
          ],
        );
      },
    );
  }

  /// Repayment Modal
  void _showRepaymentDialog(LoanModel loan) {
    double payAmount = loan.schedule.isNotEmpty ? loan.schedule.firstWhere((x) => !x.isPaid, orElse: () => loan.schedule.first).totalInstallmentAmount : 1000.0;
    String selectedAccountId = '';
    String selectedAccountName = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('ঋণের কিস্তি জমা নিন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${loan.memberName} (বাকি: ৳${loan.outstandingBalance.toStringAsFixed(0)})', style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: payAmount.toStringAsFixed(0),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'জমার পরিমাণ (টাকা)', prefixText: '৳ ', border: OutlineInputBorder()),
                    onChanged: (val) => payAmount = double.tryParse(val) ?? 0.0,
                  ),
                  const SizedBox(height: 12),
                  StreamBuilder<List<FinancialAccountModel>>(
                    stream: _accountingService.getAccountsStream(widget.somitiId),
                    builder: (context, snap) {
                      final accs = snap.data ?? [];
                      if (selectedAccountId.isEmpty && accs.isNotEmpty) {
                        selectedAccountId = accs.first.id;
                        selectedAccountName = accs.first.name;
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'জমা নেওয়ার হিসাব (ক্যাশ/ব্যাংক)', border: OutlineInputBorder()),
                        value: selectedAccountId.isNotEmpty ? selectedAccountId : null,
                        items: accs.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (৳${a.currentBalance.toStringAsFixed(0)})'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final a = accs.firstWhere((x) => x.id == val);
                            setDialogState(() {
                              selectedAccountId = a.id;
                              selectedAccountName = a.name;
                            });
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
                ElevatedButton(
                  onPressed: () async {
                    if (payAmount <= 0 || selectedAccountId.isEmpty) return;
                    try {
                      await _loanService.recordLoanRepayment(
                        widget.somitiId,
                        loanId: loan.id,
                        amountPaid: payAmount,
                        accountId: selectedAccountId,
                        accountName: selectedAccountName,
                        collectedBy: widget.currentUserName,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('কিস্তি আদায় ও ক্যাশবুকে রেকর্ড সফল হয়েছে!'), backgroundColor: Color(0xFF0F5132)),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F5132), foregroundColor: Colors.white),
                  child: const Text('জমা নিশ্চিত করুন'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Review Application Dialog
  void _reviewApplication(LoanApplicationModel app, {required bool approve}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(approve ? 'আবেদন অনুমোদন' : 'আবেদন বাতিল', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Text('${app.memberName}-এর ৳${app.requestedAmount.toStringAsFixed(0)} টাকার ঋণের আবেদনটি কি আপনি ${approve ? 'অনুমোদন' : 'বাতিল'} করতে চান?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('না')),
            ElevatedButton(
              onPressed: () async {
                await _loanService.reviewLoanApplication(
                  widget.somitiId,
                  app.id,
                  approve: approve,
                  reviewerName: widget.currentUserName,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(approve ? 'আবেদন অনুমোদিত হয়েছে!' : 'আবেদন বাতিল করা হয়েছে।'),
                      backgroundColor: approve ? const Color(0xFF0F5132) : Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: approve ? const Color(0xFF0F5132) : Colors.red, foregroundColor: Colors.white),
              child: const Text('হ্যাঁ, নিশ্চিত করুন'),
            ),
          ],
        );
      },
    );
  }

  /// Disbursement Modal: Cash Out from selected account
  void _showDisbursementModal(LoanApplicationModel app) {
    String selectedAccountId = '';
    String selectedAccountName = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('ঋণ বিতরণ ও ক্যাশ আউট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('সদস্য: ${app.memberName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('বিতরণযোগ্য পরিমাণ: ৳${app.requestedAmount.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF0F5132), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text('যে একাউন্ট থেকে টাকা প্রদান করা হবে নির্বাচন করুন:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  StreamBuilder<List<FinancialAccountModel>>(
                    stream: _accountingService.getAccountsStream(widget.somitiId),
                    builder: (context, snap) {
                      final accs = snap.data ?? [];
                      if (selectedAccountId.isEmpty && accs.isNotEmpty) {
                        selectedAccountId = accs.first.id;
                        selectedAccountName = accs.first.name;
                      }
                      return DropdownButtonFormField<String>(
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        value: selectedAccountId.isNotEmpty ? selectedAccountId : null,
                        items: accs.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (ব্যালেন্স: ৳${a.currentBalance.toStringAsFixed(0)})'))).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final a = accs.firstWhere((x) => x.id == val);
                            setDialogState(() {
                              selectedAccountId = a.id;
                              selectedAccountName = a.name;
                            });
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedAccountId.isEmpty) return;
                    try {
                      await _loanService.disburseApprovedLoan(
                        widget.somitiId,
                        app,
                        accountId: selectedAccountId,
                        accountName: selectedAccountName,
                        approvedBy: widget.currentUserName,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ঋণ সফলভাবে বিতরণ ও ক্যাশবুকে খরচ এন্ট্রি সম্পন্ন হয়েছে!'), backgroundColor: Color(0xFF0F5132)),
                        );
                        _tabController.animateTo(0);
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
                  child: const Text('বিতরণ সম্পন্ন করুন'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
