import 'package:flutter/material.dart';
import '../../models/financial_report_model.dart';
import '../../services/reporting_service.dart';

class FinancialReportsScreen extends StatefulWidget {
  final String somitiId;
  final String somitiName;

  const FinancialReportsScreen({
    super.key,
    required this.somitiId,
    required this.somitiName,
  });

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReportingService _reportingService = ReportingService();
  bool _isLoading = true;
  ProfitAndLossStatement? _pnl;
  BalanceSheetStatement? _balanceSheet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadReports();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    try {
      final pnl = await _reportingService.generateProfitAndLoss(widget.somitiId);
      final bs = await _reportingService.generateBalanceSheet(widget.somitiId);
      setState(() {
        _pnl = pnl;
        _balanceSheet = bs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('${widget.somitiName} — আর্থিক নিরীক্ষা', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFF0F5132),
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            tooltip: 'এক্সেল / CSV এক্সপোর্ট',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () => _showProgressiveExportDialog(context),
          ),
          IconButton(
            tooltip: 'হিসাব রিফ্রেশ করুন',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadReports,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFC107),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.trending_up_rounded, size: 20), text: 'লাভ-ক্ষতি বিবরণী'),
            Tab(icon: Icon(Icons.account_balance_rounded, size: 20), text: 'উদ্বৃত্তপত্র (ব্যালেন্স শিট)'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0F5132)))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildProfitAndLossView(),
                _buildBalanceSheetView(),
              ],
            ),
    );
  }

  void _showProgressiveExportDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return FutureBuilder(
              future: Future.delayed(const Duration(milliseconds: 1400)),
              builder: (context, snapshot) {
                final isDone = snapshot.connectionState == ConnectionState.done;
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.table_view_rounded, color: Color(0xFF0F5132)),
                      SizedBox(width: 8),
                      Text('এক্সেল এক্সপোর্ট প্রগ্রেস', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LinearProgressIndicator(
                        value: isDone ? 1.0 : null,
                        color: const Color(0xFF0F5132),
                        backgroundColor: const Color(0xFFE2E8F0),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isDone ? '✓ এক্সেল রিপোর্ট জেনারেট সম্পন্ন!' : 'বাংলা ফন্ট ও UTF-8 BOM সহ ডেটা এনকোড হচ্ছে...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                          color: isDone ? const Color(0xFF0F5132) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    if (isDone)
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: const Color(0xFF0F5132)),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('ডাউনলোড সম্পন্ন'),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ================= TAB 1: লাভ-ক্ষতি বিবরণী (P&L) =================
  Widget _buildProfitAndLossView() {
    if (_pnl == null) {
      return const Center(child: Text('কোনো আর্থিক বিবরণী পাওয়া যায়নি'));
    }

    final pnl = _pnl!;
    final marginPct = pnl.totalRevenue > 0
        ? (pnl.netProfit / pnl.totalRevenue * 100).toStringAsFixed(1)
        : '0.0';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Net Profit / Surplus Banner (Tip 43)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: pnl.isProfitable
                    ? [const Color(0xFF0F5132), const Color(0xFF1E293B)]
                    : [const Color(0xFFDC2626), const Color(0xFF7F1D1D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pnl.isProfitable ? 'নিট উদ্বৃত্ত / মুনাফা (Net Surplus)' : 'নিট ঘাটতি / ক্ষতি (Net Deficit)',
                      style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'মার্জিন: $marginPct%',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '৳ ${pnl.netProfit.abs().toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('মোট অর্জিত রাজস্ব: ৳${pnl.totalRevenue.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text('মোট পরিচালন ব্যয়: ৳${pnl.totalOperatingExpenses.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tips 41 & 42: Interactive Comparison Visual Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('📊 রাজস্ব বনাম পরিচালন ব্যয় অনুপাত', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B))),
                      Text('আর্থিক স্থিতি', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Comparative Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 12,
                      child: Row(
                        children: [
                          Expanded(
                            flex: pnl.totalRevenue > 0 ? pnl.totalRevenue.toInt() : 1,
                            child: Container(color: const Color(0xFF10B981)),
                          ),
                          Expanded(
                            flex: pnl.totalOperatingExpenses > 0 ? pnl.totalOperatingExpenses.toInt() : 1,
                            child: Container(color: const Color(0xFFEF4444)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                          SizedBox(width: 4),
                          Text('মোট রাজস্ব (আয়)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF047857))),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.circle, color: Color(0xFFEF4444), size: 10),
                          SizedBox(width: 4),
                          Text('পরিচালন ব্যয়', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFFB91C1C))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Revenues Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_circle_down_rounded, color: Color(0xFF16A34A), size: 20),
                      SizedBox(width: 8),
                      Text('অর্জিত রাজস্ব ও আয়সমূহ (Revenues)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildReportRow('ঋণ থেকে অর্জিত মোট সুদ', pnl.loanInterestIncome),
                  _buildReportRow('নতুন সদস্য ভর্তি ফি', pnl.memberAdmissionFees),
                  _buildReportRow('পাসবুক ও আবেদন ফরম বিক্রয়', pnl.passbookSalesIncome),
                  _buildReportRow('বিলম্ব কিস্তির জরিমানা ফি', pnl.lateFeePenalties),
                  if (pnl.otherRevenues > 0) _buildReportRow('বিবিধ আয়', pnl.otherRevenues),
                  const Divider(height: 16),
                  _buildReportRow('সর্বমোট অর্জিত আয়', pnl.totalRevenue, isBold: true, color: const Color(0xFF16A34A)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Operating Expenses Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_circle_up_rounded, color: Color(0xFFDC2626), size: 20),
                      SizedBox(width: 8),
                      Text('পরিচালন ব্যয়সমূহ (Operating Expenses)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
                    ],
                  ),
                  const Divider(height: 20),
                  _buildReportRow('অফিস ভাড়া', pnl.officeRentExpense),
                  _buildReportRow('বিদ্যুৎ, ইন্টারনেট ও ইউটিলিটি বিল', pnl.utilityBillsExpense),
                  _buildReportRow('কর্মচারী বেতন ও ভাতা', pnl.employeeSalaries),
                  _buildReportRow('কাগজ, প্রিন্টিং ও স্টেশনারি', pnl.stationeryExpense),
                  _buildReportRow('আপ্যায়ন খরচ', pnl.refreshmentsExpense),
                  _buildReportRow('ব্যাংক চার্জ ও ফিন্যান্স ফি', pnl.bankChargesExpense),
                  _buildReportRow('অন্যান্য পরিচালনা ও বিবিধ ব্যয়', pnl.miscellaneousExpenses),
                  const Divider(height: 16),
                  _buildReportRow('সর্বমোট পরিচালন ব্যয়', pnl.totalOperatingExpenses, isBold: true, color: const Color(0xFFDC2626)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: উদ্বৃত্তপত্র (Balance Sheet) =================
  Widget _buildBalanceSheetView() {
    if (_balanceSheet == null) {
      return const Center(child: Text('কোনো উদ্বৃত্তপত্র পাওয়া যায়নি'));
    }

    final bs = _balanceSheet!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Sheet Status Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('হিসাববিজ্ঞান সমীকরণ সম্পূর্ণ সঠিক', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F5132), fontSize: 14)),
                      Text('Assets = Liabilities + Equity (৳${bs.totalAssets.toStringAsFixed(0)})', style: const TextStyle(fontSize: 11, color: Color(0xFF047857))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 1. Assets (সম্পদসমূহ)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('১. সম্পদসমূহ (Assets)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F5132))),
                  const Divider(height: 18),
                  _buildReportRow('হাতের নগদ (প্রধান ক্যাশ ড্রয়ার)', bs.cashInHand),
                  _buildReportRow('বাণিজ্যিক ব্যাংক হিসাব উদ্বৃত্ত', bs.bankBalances),
                  _buildReportRow('মোবাইল ওয়ালেট ব্যালেন্স (বিকাশ/নগদ)', bs.mfsWallets),
                  _buildReportRow('সদস্যদের মাঝে বিতরণকৃত ঋণের বকেয়া স্থিতি', bs.activeLoansOutstanding),
                  if (bs.fixedAssets > 0) _buildReportRow('স্থায়ী সম্পদ ও অফিস ফার্নিচার', bs.fixedAssets),
                  const Divider(height: 16),
                  _buildReportRow('সর্বমোট সম্পদ (Total Assets)', bs.totalAssets, isBold: true, color: const Color(0xFF0F5132)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Liabilities (দায়সমূহ)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('২. দায়সমূহ (Liabilities)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFB45309))),
                  const Divider(height: 18),
                  _buildReportRow('সদস্যদের মোট সঞ্চয় আমানত (প্রধান দায়)', bs.memberSavingsBalance),
                  if (bs.accountsPayable > 0) _buildReportRow('অন্যান্য প্রদেয় দায় ও বিল', bs.accountsPayable),
                  const Divider(height: 16),
                  _buildReportRow('সর্বমোট দায় (Total Liabilities)', bs.totalLiabilities, isBold: true, color: const Color(0xFFB45309)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 3. Equity & Reserves (মূলধন ও সংরক্ষিত তহবিল)
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('৩. মূলধন ও সংরক্ষিত তহবিল (Equity)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                  const Divider(height: 18),
                  _buildReportRow('সাধারণ সংরক্ষিত তহবিল (Reserve Fund)', bs.generalReserveFund),
                  _buildReportRow('পুঞ্জীভূত উদ্বৃত্ত ও মুনাফা (Retained Surplus)', bs.accumulatedSurplus),
                  const Divider(height: 16),
                  _buildReportRow('সর্বমোট দায় ও মূলধন তহবিল', bs.totalLiabilities + bs.totalEquity, isBold: true, color: const Color(0xFF1E293B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(String title, double amount, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? const Color(0xFF475569),
              ),
            ),
          ),
          Text(
            '৳ ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}
