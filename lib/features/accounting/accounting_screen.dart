import 'package:flutter/material.dart';
import '../../models/financial_account_model.dart';
import '../../services/accounting_service.dart';

class AccountingScreen extends StatefulWidget {
  final String somitiId;
  final String somitiName;
  final String currentUserName;

  const AccountingScreen({
    super.key,
    required this.somitiId,
    required this.somitiName,
    required this.currentUserName,
  });

  @override
  State<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends State<AccountingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AccountingService _accountingService = AccountingService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Ensure society has at least default cash drawer and wallet
    _accountingService.ensureDefaultAccounts(widget.somitiId);
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
        title: Text('${widget.somitiName} — হিসাব ও ক্যাশবহি', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.account_balance_rounded, size: 20), text: 'তহবিল ও ব্যাংক'),
            Tab(icon: Icon(Icons.menu_book_rounded, size: 20), text: 'দৈনিক ক্যাশ বহি'),
            Tab(icon: Icon(Icons.receipt_long_rounded, size: 20), text: 'আয় / ব্যয় এন্ট্রি'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAccountsTab(),
          _buildCashbookTab(),
          _buildVoucherEntryTab(),
        ],
      ),
    );
  }

  // ================= TAB 1: তহবিল ও ব্যাংক হিসাব (Accounts & Balances) =================
  Widget _buildAccountsTab() {
    return StreamBuilder<List<FinancialAccountModel>>(
      stream: _accountingService.getAccountsStream(widget.somitiId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }

        final accounts = snapshot.data ?? [];
        double totalBalance = 0.0;
        for (var a in accounts) {
          totalBalance += a.currentBalance;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Funds Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F5132), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('সর্বমোট আর্থিক তহবিল (Cash & Bank Balance)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 8),
                    Text('৳ ${totalBalance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _showTransferModal(accounts),
                          icon: const Icon(Icons.sync_alt_rounded, size: 16),
                          label: const Text('তহবিল স্থানান্তর'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () => _showAddAccountModal(),
                          icon: const Icon(Icons.add, size: 16, color: Colors.white),
                          label: const Text('নতুন একাউন্ট', style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('সক্রিয় হিসাব তালিকা (Accounts)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),

              ...accounts.map((acc) => _buildAccountItem(acc)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountItem(FinancialAccountModel acc) {
    IconData iconData;
    Color iconColor;

    switch (acc.type) {
      case AccountType.cashDrawer:
        iconData = Icons.payments_rounded;
        iconColor = const Color(0xFF16A34A);
        break;
      case AccountType.bankAccount:
        iconData = Icons.account_balance_rounded;
        iconColor = const Color(0xFF2563EB);
        break;
      case AccountType.mfsWallet:
        iconData = Icons.phone_android_rounded;
        iconColor = const Color(0xFFE11D48);
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: iconColor.withOpacity(0.12),
          child: Icon(iconData, color: iconColor, size: 22),
        ),
        title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
        subtitle: Text(
          acc.type == AccountType.bankAccount
              ? '${acc.bankName} • হি/নং: ${acc.accountNumber}'
              : (acc.type == AccountType.mfsWallet ? 'মোবাইল ওয়ালেট' : 'প্রধান কার্যালয় ক্যাশ'),
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
        ),
        trailing: Text(
          '৳ ${acc.currentBalance.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: acc.currentBalance >= 0 ? const Color(0xFF0F5132) : const Color(0xFFDC2626),
          ),
        ),
      ),
    );
  }

  // ================= TAB 2: দৈনিক ক্যাশ বহি (Daily Cashbook Ledger) =================
  Widget _buildCashbookTab() {
    return StreamBuilder<List<FinancialTransactionModel>>(
      stream: _accountingService.getTransactionsStream(widget.somitiId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
        }

        final txs = snapshot.data ?? [];
        if (txs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_rounded, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('ক্যাশ বহিতে এখনো কোনো এন্ট্রি নেই', style: TextStyle(color: Color(0xFF64748B), fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: txs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final tx = txs[index];
            final bool isCredit = tx.type == FinancialTransactionType.depositIn ||
                tx.type == FinancialTransactionType.loanRepayment ||
                (tx.type == FinancialTransactionType.adjustment && tx.amount >= 0);

            Color color = isCredit ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
            String sign = isCredit ? '+' : '-';

            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(tx.category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                              Text('$sign৳ ${tx.amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(tx.description, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('ভাউচার: ${tx.voucherNo}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                              Text('${tx.date.day}/${tx.date.month}/${tx.date.year} • ${tx.recordedBy}', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= TAB 3: আয় / ব্যয় ভাউচার এন্ট্রি (Voucher Entry) =================
  Widget _buildVoucherEntryTab() {
    bool isExpense = true;
    double amount = 0.0;
    String selectedCategory = 'অফিস পরিচালনা ব্যয়';
    String description = '';
    String referenceNo = '';
    String selectedAccountId = '';
    String selectedAccountName = '';

    final expenseCategories = [
      'অফিস পরিচালনা ব্যয়',
      'অফিস ভাড়া',
      'বিদ্যুৎ ও ইন্টারনেট বিল',
      'কর্মচারী বেতন ও ভাতা',
      'কাগজ, প্রিন্টিং ও স্টেশনারি',
      'আপ্যায়ন খরচ',
      'যাতায়াত ও যাতায়াত ভাতা',
      'ব্যাংক চার্জ ও ফিন্যান্স ফি',
      'সফটওয়্যার ও ক্লাউড ফি',
      'বিবিধ ব্যয়',
    ];

    final incomeCategories = [
      'সদস্য ভর্তি ফি',
      'পাসবুক ও ফরম বিক্রয়',
      'ব্যাংক মুনাফা / সুদ আয়',
      'বিলম্ব জরিমানা ফি',
      'দান ও অনুদান',
      'বিবিধ আয়',
    ];

    return StatefulBuilder(
      builder: (context, setFormState) {
        final currentCategories = isExpense ? expenseCategories : incomeCategories;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Segmented Toggle for Expense vs Income
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setFormState(() {
                            isExpense = true;
                            selectedCategory = expenseCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isExpense ? const Color(0xFFDC2626) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'খরচ এন্ট্রি (Expense)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: isExpense ? Colors.white : const Color(0xFF475569)),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setFormState(() {
                            isExpense = false;
                            selectedCategory = incomeCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !isExpense ? const Color(0xFF16A34A) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'আয় এন্ট্রি (Income)',
                            style: TextStyle(fontWeight: FontWeight.bold, color: !isExpense ? Colors.white : const Color(0xFF475569)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: isExpense ? 'খরচের খাত (Category) *' : 'আয়ের খাত (Category) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                value: selectedCategory,
                items: currentCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) {
                  if (val != null) setFormState(() => selectedCategory = val);
                },
              ),
              const SizedBox(height: 14),

              // Account Selector
              StreamBuilder<List<FinancialAccountModel>>(
                stream: _accountingService.getAccountsStream(widget.somitiId),
                builder: (context, snap) {
                  final accs = snap.data ?? [];
                  if (selectedAccountId.isEmpty && accs.isNotEmpty) {
                    selectedAccountId = accs.first.id;
                    selectedAccountName = accs.first.name;
                  }
                  return DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: isExpense ? 'যে হিসাব থেকে খরচ হয়েছে *' : 'যে হিসাবে জমা হবে *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    value: selectedAccountId.isNotEmpty ? selectedAccountId : null,
                    items: accs.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (৳${a.currentBalance.toStringAsFixed(0)})'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final a = accs.firstWhere((x) => x.id == val);
                        setFormState(() {
                          selectedAccountId = a.id;
                          selectedAccountName = a.name;
                        });
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 14),

              // Amount
              TextFormField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'টাকার পরিমাণ *',
                  prefixText: '৳ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (val) => amount = double.tryParse(val) ?? 0.0,
              ),
              const SizedBox(height: 14),

              // Reference / Bill No
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'বিল / মেমো / রেফারেন্স নম্বর',
                  hintText: 'ঐচ্ছিক',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (val) => referenceNo = val,
              ),
              const SizedBox(height: 14),

              // Description
              TextFormField(
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'বিবরণ / নোট *',
                  hintText: 'যেমন: মে মাসের বিদ্যুৎ বিল পরিশোধ ইত্যাদি',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (val) => description = val,
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (amount <= 0 || selectedAccountId.isEmpty || description.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('অনুগ্রহ করে পরিমাণ এবং বিবরণ পূরণ করুন!'), backgroundColor: Colors.orange),
                      );
                      return;
                    }

                    try {
                      if (isExpense) {
                        await _accountingService.recordExpense(
                          widget.somitiId,
                          accountId: selectedAccountId,
                          accountName: selectedAccountName,
                          amount: amount,
                          category: selectedCategory,
                          description: description,
                          recordedBy: widget.currentUserName,
                          referenceNo: referenceNo,
                        );
                      } else {
                        await _accountingService.recordIncome(
                          widget.somitiId,
                          accountId: selectedAccountId,
                          accountName: selectedAccountName,
                          amount: amount,
                          category: selectedCategory,
                          description: description,
                          recordedBy: widget.currentUserName,
                          referenceNo: referenceNo,
                        );
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isExpense ? 'খরচ সফলভাবে এন্ট্রি ও ব্যালেন্স সমন্বয় করা হয়েছে!' : 'আয় সফলভাবে রেকর্ড করা হয়েছে!'),
                            backgroundColor: isExpense ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                          ),
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
                    backgroundColor: isExpense ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: Text(isExpense ? 'খরচ ভাউচার সংরক্ষণ করুন' : 'আয় ভাউচার সংরক্ষণ করুন', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= MODALS =================

  /// Fund Transfer Modal
  void _showTransferModal(List<FinancialAccountModel> accounts) {
    if (accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('স্থানান্তরের জন্য অন্তত দুটি একাউন্ট থাকতে হবে।')),
      );
      return;
    }

    String fromId = accounts.first.id;
    String fromName = accounts.first.name;
    String toId = accounts[1].id;
    String toName = accounts[1].name;
    double amount = 0.0;
    String note = '';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('তহবিল স্থানান্তর (Fund Transfer)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'উৎস একাউন্ট (From)', border: OutlineInputBorder()),
                    value: fromId,
                    items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (৳${a.currentBalance.toStringAsFixed(0)})'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final a = accounts.firstWhere((x) => x.id == val);
                        setDialogState(() {
                          fromId = a.id;
                          fromName = a.name;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'গন্তব্য একাউন্ট (To)', border: OutlineInputBorder()),
                    value: toId,
                    items: accounts.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.name} (৳${a.currentBalance.toStringAsFixed(0)})'))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final a = accounts.firstWhere((x) => x.id == val);
                        setDialogState(() {
                          toId = a.id;
                          toName = a.name;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'স্থানান্তরের পরিমাণ (টাকা)', prefixText: '৳ ', border: OutlineInputBorder()),
                    onChanged: (val) => amount = double.tryParse(val) ?? 0.0,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'নোট / বিবরণ', hintText: 'যেমন: ব্যাংক ডিপোজিট', border: OutlineInputBorder()),
                    onChanged: (val) => note = val,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
                ElevatedButton(
                  onPressed: () async {
                    if (amount <= 0 || fromId == toId) return;
                    try {
                      await _accountingService.transferFunds(
                        widget.somitiId,
                        fromAccountId: fromId,
                        fromAccountName: fromName,
                        toAccountId: toId,
                        toAccountName: toName,
                        amount: amount,
                        recordedBy: widget.currentUserName,
                        note: note,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('তহবিল সফলভাবে স্থানান্তর করা হয়েছে!'), backgroundColor: Color(0xFF0F5132)),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                  child: const Text('স্থানান্তর নিশ্চিত করুন'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Add New Account Modal
  void _showAddAccountModal() {
    String name = '';
    AccountType type = AccountType.bankAccount;
    String accountNumber = '';
    String bankName = '';
    String branchName = '';
    double initialBalance = 0.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('নতুন ব্যাংক / আর্থিক একাউন্ট যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'একাউন্টের নাম *', hintText: 'যেমন: সোনালী ব্যাংক সাধারণ তহবিল', border: OutlineInputBorder()),
                      onChanged: (val) => name = val,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<AccountType>(
                      decoration: const InputDecoration(labelText: 'হিসাবের ধরন *', border: OutlineInputBorder()),
                      value: type,
                      items: const [
                        DropdownMenuItem(value: AccountType.bankAccount, child: Text('বাণিজ্যিক ব্যাংক হিসাব')),
                        DropdownMenuItem(value: AccountType.mfsWallet, child: Text('মোবাইল ওয়ালেট (বিকাশ/নগদ)')),
                        DropdownMenuItem(value: AccountType.cashDrawer, child: Text('শাখা ক্যাশ ড্রয়ার')),
                      ],
                      onChanged: (val) {
                        if (val != null) setDialogState(() => type = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'ব্যাংক / ওয়ালেটের নাম', hintText: 'যেমন: Sonali Bank PLC', border: OutlineInputBorder()),
                      onChanged: (val) => bankName = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'হিসাব নম্বর / মোবাইল নম্বর', border: OutlineInputBorder()),
                      onChanged: (val) => accountNumber = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'শাখার নাম', border: OutlineInputBorder()),
                      onChanged: (val) => branchName = val,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'প্রাথমিক উদ্বৃত্ত (টাকা)', prefixText: '৳ ', border: OutlineInputBorder()),
                      onChanged: (val) => initialBalance = double.tryParse(val) ?? 0.0,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
                ElevatedButton(
                  onPressed: () async {
                    if (name.trim().isEmpty) return;
                    try {
                      final acc = FinancialAccountModel(
                        id: '',
                        name: name.trim(),
                        type: type,
                        accountNumber: accountNumber,
                        bankName: bankName,
                        branchName: branchName,
                        currentBalance: initialBalance,
                        createdAt: DateTime.now(),
                      );
                      await _accountingService.createAccount(widget.somitiId, acc);
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('নতুন একাউন্ট সফলভাবে যুক্ত হয়েছে!'), backgroundColor: Color(0xFF0F5132)),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
                  child: const Text('সংরক্ষণ করুন'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
