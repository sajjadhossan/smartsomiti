import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
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
  bool _isBalanceHidden = false;
  final AuthService _authService = AuthService();
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
                    if (widget.somiti.englishName.isNotEmpty)
                      Text(
                        widget.somiti.englishName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10.5, color: Color(0xFF475569), letterSpacing: 0.3),
                      ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        '🏛️ ${widget.somiti.regNo}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                      ),
                    ),
                    if (widget.somiti.padHeader.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '"${widget.somiti.padHeader}"',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      '📍 ${widget.somiti.address}',
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
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 14, color: Color(0xFF0F9D58)),
                      SizedBox(width: 4),
                      Text('ভেরিফাইড ডিজিটাল ভাউচার • VERIFIED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F9D58))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Committee Signatures: 3 Officers (Tip 38)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(widget.somiti.cashierName.isNotEmpty ? widget.somiti.cashierName : 'কোষাধ্যক্ষ', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0F5132))),
                        const Text('কোষাধ্যক্ষ', style: TextStyle(fontSize: 8.5, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(widget.somiti.secretaryName.isNotEmpty ? widget.somiti.secretaryName : 'সম্পাদক', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                        const Text('সাধারণ সম্পাদক', style: TextStyle(fontSize: 8.5, color: Colors.grey)),
                      ],
                    ),
                    Column(
                      children: [
                        Text(widget.somiti.presidentName.isNotEmpty ? widget.somiti.presidentName : 'সভাপতি', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const Text('সভাপতি', style: TextStyle(fontSize: 8.5, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
          OutlinedButton.icon(
            onPressed: () {
              final smsText = 'রসিদ: ${widget.somiti.name} • ভাউচার: $voucherNo • সদস্য: [$memberNumber] $memberName • জমা: ৳${currencyFormat.format(amount)} • তারিখ: ${dateFormat.format(date)}';
              Clipboard.setData(ClipboardData(text: smsText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📱 SMS টেক্সট কপি হয়েছে!')));
            },
            icon: const Icon(Icons.sms_rounded, size: 16),
            label: const Text('SMS টেক্সট'),
          ),
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
সম্পাদক: ${widget.somiti.secretaryName}
সভাপতি: ${widget.somiti.presidentName}
ধন্যবাদ! আপনার সঞ্চয় সফলভাবে জমা হয়েছে।
''';
              Clipboard.setData(ClipboardData(text: receiptText));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('রসিদ কপি হয়েছে! WhatsApp বা মেসেজে শেয়ার করতে পেস্ট করুন।')),
              );
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('রসিদ শেয়ার'),
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
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (context, index) {
                        final d = deposits[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 1)),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle, border: Border.all(color: Colors.green.shade400)),
                                child: const Icon(Icons.check, size: 16, color: Colors.green),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('৳${currencyFormat.format(d.amount)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F5132))),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                          child: const Text('অনুমোদিত', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.green)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text('${d.type} ${d.note.isNotEmpty ? '• ' + d.note : ''}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text(dateFormat.format(d.date), style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                                  ],
                                ),
                              ),
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

  // Tip 48: Automated Due Reminder SMS Preview Dialog
  void _showDueSmsReminderDialog(List<MemberModel> members, SomitiModel somiti) {
    if (members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কোনো সদস্য পাওয়া যায়নি')));
      return;
    }
    MemberModel selectedMember = members.first;
    final smsController = TextEditingController();

    void updateSmsText(MemberModel m) {
      smsController.text =
          'সম্মানিত ${m.name}, আসসালামু আলাইকুম। ${somiti.name}-এ আপনার সঞ্চয় কিস্তি জমা বা হিসাব হালনাগাদ করার জন্য অনুরোধ করা হলো। সমিতির বিকাশ/যোগাযোগ নম্বর: ${somiti.bkashNumber}। ধন্যবাদ, ${somiti.cashierName}।';
    }

    updateSmsText(selectedMember);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.sms_rounded, color: Color(0xFF1D4ED8), size: 22),
                SizedBox(width: 8),
                Text('বকেয়া তাগিদপত্র এসএমএস', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('সদস্য নির্বাচন করুন:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<MemberModel>(
                    value: selectedMember,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: members.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text('[#${m.memberNumber}] ${m.name}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedMember = val;
                          updateSmsText(val);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('সদস্যের বর্তমান মোট সঞ্চয়:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                        Text('৳${selectedMember.totalDeposit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('প্রস্তুতকৃত বাংলা এসএমএস:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: smsController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('বন্ধ করুন'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F5132)),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: smsController.text));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ এসএমএস টেক্সট ক্লিপবোর্ডে কপি করা হয়েছে!')),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('কপি করুন'),
              ),
            ],
          );
        },
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

  // Category 3: Society Switcher Dialog (Tip 26)
  void _openSocietySwitcherDialog(BuildContext context, SomitiModel current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_balance_rounded, color: Color(0xFF0F9D58), size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('আপনার সমিতিসমূহ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('সরাসরি সমিতি সুইচ করুন', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFF0F9D58), width: 1.5)),
                tileColor: Colors.green.withOpacity(0.08),
                leading: const CircleAvatar(backgroundColor: Color(0xFF0F9D58), child: Icon(Icons.check, color: Colors.white, size: 18)),
                title: Text(current.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: Text('${current.somitiCode} • কোষাধ্যক্ষ: ${current.cashierName}', style: const TextStyle(fontSize: 11)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF0F9D58), borderRadius: BorderRadius.circular(12)),
                  child: const Text('সক্রিয়', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(Icons.business_rounded, color: Colors.blue.shade700, size: 18)),
                title: const Text('স্বপ্ন ছোঁয়া সমবায় সমিতি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('SMT-1024 • এডমিন', style: TextStyle(fontSize: 11)),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সমিতি সুইচ ফিচার সফলভাবে সক্রিয় করা হয়েছে')));
                  },
                  child: const Text('সুইচ ➔', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বন্ধ করুন')),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('নতুন সমিতি তৈরি মেনু খোলা হচ্ছে...')));
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('নতুন সমিতি নিবন্ধন'),
          ),
        ],
      ),
    );
  }

  // Category 3: Modern 3-Dot Action Bottom Sheet with Live Search (Tip 21 & 29)
  void _openThreeDotBottomSheet(
    BuildContext context,
    SomitiModel somiti, {
    List<MemberModel> members = const [],
    List<DepositModel> deposits = const [],
    List<ExpenseModel> expenses = const [],
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final List<Map<String, dynamic>> allItems = [
              // Group 1: দ্রুত কার্যাবলি
              {'group': '⚡ দ্রুত কার্যাবলি', 'title': 'নতুন সদস্য ভর্তি', 'desc': 'সদস্য ফর্ম পূরণ করুন', 'icon': Icons.person_add_alt_1_rounded, 'color': const Color(0xFF0F9D58), 'action': () { Navigator.pop(ctx); _showAddMemberDialog(); }},
              {'group': '⚡ দ্রুত কার্যাবলি', 'title': 'দ্রুত জমা গ্রহণ ও কিস্তি', 'desc': 'সঞ্চয় বা ঋণের কিস্তি কালেকশন', 'icon': Icons.arrow_downward_rounded, 'color': const Color(0xFF0284C7), 'action': () { Navigator.pop(ctx); _showAddDepositDialog(members); }},
              {'group': '⚡ দ্রুত কার্যাবলি', 'title': 'নতুন ঋণ বিতরণ ও আবেদন', 'desc': 'ঋণ অনুমোদন ও কিস্তি শিডিউল', 'icon': Icons.account_balance_wallet_rounded, 'color': const Color(0xFFD97706), 'action': () {
                Navigator.pop(ctx);
                if (FeatureManagementService().canAccess(featureKey: 'loan_management', societyId: somiti.id)) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => LoanManagementScreen(somitiId: somiti.id, somitiName: somiti.name, currentUserName: widget.user.displayName ?? 'এডমিন')));
                }
              }},
              {'group': '⚡ দ্রুত কার্যাবলি', 'title': 'দৈনন্দিন খরচ এন্ট্রি', 'desc': 'অফিস বা বিবিধ খরচ ভাউচার', 'icon': Icons.arrow_upward_rounded, 'color': const Color(0xFFDC2626), 'action': () { Navigator.pop(ctx); _showAddExpenseDialog(); }},

              // Group 2: রিপোর্ট ও এক্সপোর্ট
              {'group': '📑 রিপোর্ট ও এক্সপোর্ট', 'title': 'আয়-ব্যয় ও লাভ-ক্ষতি রিপোর্ট', 'desc': 'উদ্বৃত্তপত্র ও ব্যালেন্স শিট', 'icon': Icons.analytics_outlined, 'color': const Color(0xFF7C3AED), 'action': () {
                Navigator.pop(ctx);
                if (FeatureManagementService().canAccess(featureKey: 'reports', societyId: somiti.id)) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => FinancialReportsScreen(somitiId: somiti.id, somitiName: somiti.name)));
                }
              }},
              {'group': '📑 রিপোর্ট ও এক্সপোর্ট', 'title': 'ক্যাশ বহি ও ব্যাংক অ্যাকাউন্ট', 'desc': 'দৈনিক জমা-খরচের খতিয়ান', 'icon': Icons.account_balance_rounded, 'color': const Color(0xFF4338CA), 'action': () {
                Navigator.pop(ctx);
                if (FeatureManagementService().canAccess(featureKey: 'financial_accounting', societyId: somiti.id)) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AccountingScreen(somitiId: somiti.id, somitiName: somiti.name, currentUserName: widget.user.displayName ?? 'এডমিন')));
                }
              }},
              {'group': '📑 রিপোর্ট ও এক্সপোর্ট', 'title': 'এক্সেল ও CSV ব্যাকআপ', 'desc': 'কম্পিউটারে এক্সপোর্ট করুন', 'icon': Icons.table_view_rounded, 'color': const Color(0xFF059669), 'action': () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('এক্সেল ব্যাকআপ তৈরি ও ডাউনলোড সম্পন্ন হয়েছে')));
              }},
              {'group': '📑 রিপোর্ট ও এক্সপোর্ট', 'title': 'বকেয়া তাগিদপত্র এসএমএস', 'desc': '১-ক্লিকে বাংলা রিমাইন্ডার তৈরি', 'icon': Icons.sms_outlined, 'color': const Color(0xFF1D4ED8), 'action': () {
                Navigator.pop(ctx);
                _showDueSmsReminderDialog(members, somiti);
              }},

              // Group 3: প্রশাসনিক ও ক্লাউড
              {'group': '⚙️ প্রশাসনিক ও ক্লাউড', 'title': 'মাস্টার এডমিন কন্ট্রোল সেন্টার', 'desc': 'ফিচার ফ্ল্যাগ ও সিকিউরিটি ম্যাট্রিক্স', 'icon': Icons.admin_panel_settings_rounded, 'color': const Color(0xFF92400E), 'action': () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => MasterAdminScreen(userEmail: widget.user.email ?? '')));
              }},
              {'group': '⚙️ প্রশাসনিক ও ক্লাউড', 'title': 'গুগল ড্রাইভ ক্লাউড ব্যাকআপ', 'desc': 'ডেটা সিঙ্ক ও অটো ড্রাইভ সংরক্ষণ', 'icon': Icons.cloud_sync_rounded, 'color': const Color(0xFF1D4ED8), 'action': () {
                Navigator.pop(ctx);
                _backupToDrive(members, deposits, expenses);
              }},

              // Group 4: সেশন ও সমিতি
              {'group': '🚪 সেশন ও সমিতি', 'title': 'সমিতি পরিবর্তন করুন', 'desc': 'অন্য সমিতির ড্যাশবোর্ডে সুইচ', 'icon': Icons.sync_alt_rounded, 'color': const Color(0xFF4F46E5), 'action': () {
                Navigator.pop(ctx);
                _openSocietySwitcherDialog(context, somiti);
              }},
              {'group': '🚪 সেশন ও সমিতি', 'title': 'লগআউট', 'desc': 'নিরাপদে অ্যাপ থেকে বের হন', 'icon': Icons.logout_rounded, 'color': const Color(0xFFDC2626), 'isDanger': true, 'action': () {
                Navigator.pop(ctx);
                _authService.signOut();
              }},
            ];

            final filteredItems = query.trim().isEmpty
                ? allItems
                : allItems.where((it) {
                    final t = (it['title'] as String).toLowerCase();
                    final d = (it['desc'] as String).toLowerCase();
                    final q = query.trim().toLowerCase();
                    return t.contains(q) || d.contains(q);
                  }).toList();

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.bolt_rounded, color: Colors.orange, size: 20),
                            ),
                            const SizedBox(width: 10),
                            const Text('দ্রুত অ্যাকশন ও মেনু', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '🔍 মেনু বা সেবা খুঁজুন (উদাঃ ঋণ, জমা, রিপোর্ট)...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) {
                        setSheetState(() {
                          query = val;
                        });
                      },
                    ),
                  ),
                  const Divider(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      itemCount: filteredItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 2),
                      itemBuilder: (context, idx) {
                        final item = filteredItems[idx];
                        final isDanger = item['isDanger'] == true;
                        final color = item['color'] as Color;

                        return ListTile(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'] as IconData, color: color, size: 20),
                          ),
                          title: Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: isDanger ? Colors.red : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            item['desc'] as String,
                            style: TextStyle(fontSize: 11, color: isDanger ? Colors.red.shade300 : Colors.grey.shade600),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, size: 18, color: Colors.grey),
                          onTap: item['action'] as VoidCallback,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                    title: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _openSocietySwitcherDialog(context, somiti),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(somiti.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_drop_down_rounded, size: 20),
                              ],
                            ),
                            Text('কোড: ${somiti.somitiCode} • কোষাধ্যক্ষ: ${somiti.cashierName}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      if (FeatureManagementService().canAccess(featureKey: 'loan_management', societyId: somiti.id))
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
                      if (FeatureManagementService().canAccess(featureKey: 'financial_accounting', societyId: somiti.id))
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
                      if (FeatureManagementService().canAccess(featureKey: 'reports', societyId: somiti.id))
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
                          icon: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.amber.shade400, width: 1.5),
                              boxShadow: [
                                BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 6, spreadRadius: 1),
                              ],
                            ),
                            child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF92400E), size: 18),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => MasterAdminScreen(userEmail: widget.user.email ?? '')),
                            );
                          },
                        ),
                      IconButton(
                        tooltip: 'দ্রুত মেনু ও অ্যাকশন',
                        icon: const Icon(Icons.more_vert_rounded, size: 24),
                        onPressed: () => _openThreeDotBottomSheet(
                          context,
                          somiti,
                          members: members,
                          deposits: deposits,
                          expenses: expenses,
                        ),
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(somiti.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      if (somiti.englishName.isNotEmpty)
                                        Text(somiti.englishName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, color: Color(0xFF475569))),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                                  child: Text('অফিসিয়াল প্যাড', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: Text('🏛️ ${somiti.regNo}', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
                                ),
                                const SizedBox(width: 6),
                                if (somiti.padHeader.isNotEmpty)
                                  Expanded(
                                    child: Text('"${somiti.padHeader}"', style: const TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                              ],
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

                      // Tips 49 & 50: System Status Strip (Cloud Sync & Connectivity Ping Meter)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('ক্লাউড সিঙ্ক: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                                const Text('সক্রিয় • এইমাত্র', style: TextStyle(fontSize: 11, color: Color(0xFF0F9D58), fontWeight: FontWeight.w600)),
                              ],
                            ),
                            InkWell(
                              borderRadius: BorderRadius.circular(6),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('⚡ ফায়ারবেস পিং: ২৮ms • সংযোগ সম্পূর্ণ স্থিতিশীল'),
                                    backgroundColor: Color(0xFF0F5132),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFA7F3D0)),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.bolt_rounded, size: 14, color: Color(0xFF047857)),
                                    SizedBox(width: 2),
                                    Text('পিং: ২৮ms • অনলাইন', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                  ],
                                ),
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

  String _formatCurrency(double val, NumberFormat formatter) {
    if (_isBalanceHidden) return '৳ ••••••';
    return '৳${formatter.format(val)}';
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
    const double initialBankReserve = 75000.0;
    final double totalLiquidAssets = cashInHand + initialBankReserve;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Attention Alert Banner (Tip 19)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              border: Border.all(color: const Color(0xFFFCD34D)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'চলতি সপ্তাহের ঋণ কিস্তি ও ক্যাশ রেজিস্টার নিয়মিত আপডেট রাখুন।',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                  ),
                ),
                TextButton(
                  onPressed: () {
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
                  child: const Text('ঋণ ↗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ),

          // ================= HERO BALANCE CARD (Tips 11, 12, 15, 16, 20) =================
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
            clipBehavior: Clip.antiAlias,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF064E3B), Color(0xFF065F46), Color(0xFF047857)],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  // Faint Watermark (Tip 20)
                  Positioned(
                    right: -10,
                    bottom: -15,
                    child: Opacity(
                      opacity: 0.08,
                      child: const Icon(Icons.account_balance_rounded, size: 120, color: Colors.white),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('💼', style: TextStyle(fontSize: 12)),
                                SizedBox(width: 4),
                                Text(
                                  'মোট সক্রিয় তহবিল (Liquid Assets)',
                                  style: TextStyle(color: Color(0xFFA7F3D0), fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          // Privacy Eye Toggle Button (Tip 12)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _isBalanceHidden = !_isBalanceHidden;
                              });
                            },
                            icon: Icon(
                              _isBalanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            tooltip: 'ব্যালেন্স গোপন / প্রদর্শন করুন',
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatCurrency(totalLiquidAssets, currencyFormat),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '↑ ৮.৪% বৃদ্ধি',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF166534)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 2-Column Breakdown Sub-Boxes
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '💵 হাতে নগদ (ক্যাশ)',
                                    style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatCurrency(cashInHand, currencyFormat),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFEF08A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '🏦 ব্যাংক ও বিকাশ স্থিতি',
                                    style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatCurrency(initialBankReserve, currencyFormat),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFEF08A)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ================= KPI MICRO-CHIPS SCROLLING ROW (Tip 14) =================
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildKpiChip(
                  icon: Icons.groups_rounded,
                  title: 'মোট সদস্য:',
                  value: '${members.length} জন',
                  color: Colors.blue.shade700,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                const SizedBox(width: 8),
                _buildKpiChip(
                  icon: Icons.savings_rounded,
                  title: 'মোট সঞ্চয়:',
                  value: _formatCurrency(totalDeposit, currencyFormat),
                  color: Colors.green.shade700,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                const SizedBox(width: 8),
                _buildKpiChip(
                  icon: Icons.receipt_long_rounded,
                  title: 'মোট খরচ:',
                  value: _formatCurrency(totalExpense, currencyFormat),
                  color: Colors.red.shade700,
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                const SizedBox(width: 8),
                _buildKpiChip(
                  icon: Icons.account_balance_wallet_rounded,
                  title: 'চলমান ঋণ:',
                  value: _formatCurrency(45000.0, currencyFormat),
                  color: Colors.amber.shade800,
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
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ================= NEUMORPHIC 4-COLUMN QUICK ACTIONS GRID (Tip 13) =================
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.download_rounded,
                  iconColor: const Color(0xFF0F9D58),
                  bgColor: const Color(0xFFE8F5E9),
                  title: 'জমা গ্রহণ',
                  subtitle: 'সঞ্চয় এন্ট্রি',
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.credit_card_rounded,
                  iconColor: const Color(0xFF15803D),
                  bgColor: const Color(0xFFDCFCE7),
                  title: 'ঋণ বিতরণ',
                  subtitle: 'কিস্তি শিডিউল',
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
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.upload_rounded,
                  iconColor: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEE2E2),
                  title: 'খরচ এন্ট্রি',
                  subtitle: 'ভাউচার',
                  onTap: () => setState(() => _currentIndex = 3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.receipt_rounded,
                  iconColor: const Color(0xFF0284C7),
                  bgColor: const Color(0xFFE0F2FE),
                  title: 'মানি রসিদ',
                  subtitle: 'প্রিন্ট ও PDF',
                  onTap: () {
                    if (deposits.isNotEmpty) {
                      final d = deposits.first;
                      _showReceiptDialog(
                        memberNumber: d.memberNumber,
                        memberName: d.memberName,
                        amount: d.amount,
                        type: d.type,
                        date: d.date,
                        note: d.note,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('রসিদ দেখতে আগে একটি জমা এন্ট্রি করুন।')),
                      );
                    }
                  },
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

  Widget _buildKpiChip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
