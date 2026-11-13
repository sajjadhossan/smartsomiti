import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/somiti_model.dart';
import '../../models/member_model.dart';
import '../../models/deposit_model.dart';
import '../../models/expense_model.dart';
import '../../services/auth_service.dart';
import '../../services/somiti_service.dart';
import '../../services/drive_service.dart';
import '../../services/feature_management_service.dart';
import '../admin/master_admin_screen.dart';
import '../loans/loan_management_screen.dart';
import '../accounting/accounting_screen.dart';
import '../reports/financial_reports_screen.dart';

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
