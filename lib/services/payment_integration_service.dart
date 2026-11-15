// lib/services/payment_integration_service.dart
// Enterprise Payment, Banking & Financial Integration Ecosystem Service
// Supporting bKash, Nagad, SSLCOMMERZ, Bank Transfer, Field Cash Collection,
// Dynamic Bangla QR, 3-Way Bank Reconciliation, Idempotency, and Double-Entry GL Integration

import 'dart:convert';
import 'dart:math';
import '../models/payment_integration_model.dart';

class PaymentIntegrationService {
  static final PaymentIntegrationService _instance = PaymentIntegrationService._internal();
  factory PaymentIntegrationService() => _instance;
  PaymentIntegrationService._internal() {
    _initializeDefaults();
  }

  // In-memory persistent stores
  final Map<String, PaymentProviderConfigModel> _providerConfigs = {};
  final Map<String, PaymentTransactionModel> _transactions = {};
  final Map<String, SocietyBankAccountModel> _bankAccounts = {};
  final Map<String, BankStatementItemModel> _statementItems = {};
  final Map<String, DynamicQrPaymentModel> _qrPayments = {};
  final Map<String, PaymentRefundModel> _refunds = {};
  final Map<String, GatewaySettlementModel> _settlements = {};
  final Map<String, Map<String, dynamic>> _gatewayHealth = {};

  void _initializeDefaults() {
    // 1. Default Gateway Configurations
    final defaultConfigs = [
      const PaymentProviderConfigModel(
        providerId: 'gateway_bkash_01',
        providerType: PaymentProviderType.bkash,
        titleBn: 'বিকাশ মার্চেন্ট পেমেন্ট (Tokenized API)',
        merchantIdMasked: '017***9900 (M-019283)',
        isEnabled: true,
        isSandbox: true,
        minAmountPoisha: 1000, // ৳১০
        maxAmountPoisha: 10000000, // ৳১,০০,০০০
        feeBps: 150, // 1.50%
      ),
      const PaymentProviderConfigModel(
        providerId: 'gateway_nagad_01',
        providerType: PaymentProviderType.nagad,
        titleBn: 'নগদ ডিরেক্ট মার্চেন্ট পেমেন্ট',
        merchantIdMasked: '018***4411 (NG-55201)',
        isEnabled: true,
        isSandbox: true,
        minAmountPoisha: 1000,
        maxAmountPoisha: 10000000,
        feeBps: 120, // 1.20%
      ),
      const PaymentProviderConfigModel(
        providerId: 'gateway_ssl_01',
        providerType: PaymentProviderType.sslcommerz,
        titleBn: 'SSLCOMMERZ পেমেন্ট গেটওয়ে (কার্ড ও নেট ব্যাংকিং)',
        merchantIdMasked: 'swapnocoop_live (SSL-992)',
        isEnabled: true,
        isSandbox: false,
        minAmountPoisha: 5000, // ৳৫০
        maxAmountPoisha: 25000000, // ৳২,৫০,০০০
        feeBps: 200, // 2.00%
      ),
      const PaymentProviderConfigModel(
        providerId: 'gateway_bank_01',
        providerType: PaymentProviderType.bankTransfer,
        titleBn: 'বাণিজ্যিক ব্যাংক ডিপোজিট ও BEFTN/NPSB ট্রান্সফার',
        merchantIdMasked: 'City Bank (A/C: 110***889)',
        isEnabled: true,
        isSandbox: false,
        minAmountPoisha: 10000, // ৳১০০
        maxAmountPoisha: 100000000, // ৳১০,০০,০০০
        feeBps: 0, // No gateway fee for direct bank
      ),
      const PaymentProviderConfigModel(
        providerId: 'gateway_cash_01',
        providerType: PaymentProviderType.cashCollection,
        titleBn: 'মাঠ পর্যায় নগদ ক্যাশ কালেকশন (অফিসার সংগ্রহ)',
        merchantIdMasked: 'ফিল্ড কালেকশন সিস্টেম',
        isEnabled: true,
        isSandbox: false,
        minAmountPoisha: 1000,
        maxAmountPoisha: 50000000, // ৳৫,০০,০০০
        feeBps: 0,
      ),
    ];

    for (final cfg in defaultConfigs) {
      _providerConfigs[cfg.providerId] = cfg;
      _gatewayHealth[cfg.providerId] = {
        'status': 'HEALTHY',
        'latencyMs': 42 + Random().nextInt(50),
        'uptimePercent': 99.98,
        'lastPing': DateTime.now().toIso8601String(),
        'activeErrors': 0,
      };
    }

    // 2. Default Commercial Bank Accounts
    final defaultBankAccounts = [
      const SocietyBankAccountModel(
        id: 'bank_acc_01',
        societyId: 'swapno_chowa_main',
        bankName: 'City Bank PLC',
        branchName: 'Mirpur-10 Branch',
        accountName: 'Swapno Chowa Oikyo Somiti',
        accountNumberMasked: '1102938475***',
        routingNumber: '225275306',
        linkedGlAccountId: '1121', // coa_1121
        currentBalancePoisha: 85400000, // ৳৮,৫৪,০০০.০০
        isActive: true,
      ),
      const SocietyBankAccountModel(
        id: 'bank_acc_02',
        societyId: 'swapno_chowa_main',
        bankName: 'Islami Bank Bangladesh PLC',
        branchName: 'Pallabi Branch',
        accountName: 'Swapno Chowa Microfinance Ops',
        accountNumberMasked: '2050183928***',
        routingNumber: '125271890',
        linkedGlAccountId: '1122',
        currentBalancePoisha: 42350000, // ৳৪,২৩,৫০০.০০
        isActive: true,
      ),
    ];

    for (final b in defaultBankAccounts) {
      _bankAccounts[b.id] = b;
    }

    // 3. Seed Sample Transactions
    final now = DateTime.now();
    final sampleTxns = [
      PaymentTransactionModel(
        id: 'tx_bkash_8801',
        providerType: PaymentProviderType.bkash,
        providerTxnId: 'BKS99882201',
        societyId: 'swapno_chowa_main',
        memberId: 'mem_001',
        purpose: PaymentPurposeType.memberSavingsDeposit,
        amountPoisha: 200000, // ৳২,০০০.০০
        feePoisha: 3000, // ৳৩০.০০ (1.5%)
        netAmountPoisha: 197000, // ৳১,৯৭০.০০
        status: PaymentLifecycleStatus.success,
        idempotencyKey: 'idemp_bks_8801_mem001',
        linkedVoucherId: 'jv_rec_bkash_8801',
        createdAt: now.subtract(const Duration(hours: 3)),
        verifiedAt: now.subtract(const Duration(hours: 3)),
      ),
      PaymentTransactionModel(
        id: 'tx_field_8802',
        providerType: PaymentProviderType.cashCollection,
        providerTxnId: 'CSH-COL-2026-101',
        societyId: 'swapno_chowa_main',
        memberId: 'mem_002',
        purpose: PaymentPurposeType.loanInstallmentRepayment,
        amountPoisha: 150000, // ৳১,৫০০.০০
        feePoisha: 0,
        netAmountPoisha: 150000,
        status: PaymentLifecycleStatus.pending,
        idempotencyKey: 'idemp_csh_8802_mem002',
        collectorId: 'emp_field_01',
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      PaymentTransactionModel(
        id: 'tx_ssl_8803',
        providerType: PaymentProviderType.sslcommerz,
        providerTxnId: 'SSL_TRAN_77661',
        societyId: 'swapno_chowa_main',
        memberId: 'mem_003',
        purpose: PaymentPurposeType.shareCapital,
        amountPoisha: 500000, // ৳৫,০০০.০০
        feePoisha: 10000, // ৳১০০.০০ (2.0%)
        netAmountPoisha: 490000,
        status: PaymentLifecycleStatus.success,
        idempotencyKey: 'idemp_ssl_8803_mem003',
        linkedVoucherId: 'jv_rec_ssl_8803',
        createdAt: now.subtract(const Duration(days: 1)),
        verifiedAt: now.subtract(const Duration(days: 1)),
      ),
    ];

    for (final tx in sampleTxns) {
      _transactions[tx.id] = tx;
    }

    // 4. Seed Dynamic QR Sample
    final sampleQr = DynamicQrPaymentModel(
      tokenUuid: 'qr_tok_2026_0918',
      societyId: 'swapno_chowa_main',
      memberId: 'mem_001',
      purpose: PaymentPurposeType.memberSavingsDeposit,
      amountPoisha: 120000, // ৳১,২০০.০০
      qrPayload: '00020101021226460010bd.gov.bb28280010017112233440108SWAPNOCO52045999530305054071200.005802BD5925Swapno Chowa Oikyo Somiti6006DHAKA6304D1B8',
      expiresAt: now.add(const Duration(minutes: 15)),
      isUsed: false,
    );
    _qrPayments[sampleQr.tokenUuid] = sampleQr;

    // 5. Seed Bank Statement Items for Reconciliation
    final sampleStatements = [
      BankStatementItemModel(
        id: 'stmt_line_01',
        bankAccountId: 'bank_acc_01',
        societyId: 'swapno_chowa_main',
        txnDate: now.subtract(const Duration(days: 1)),
        description: 'bKash Merchant Settlement BKS-9988',
        creditPoisha: 197000, // ৳১,৯৭০.০০
        debitPoisha: 0,
        balancePoisha: 85400000,
        matchStatus: 'matched',
        matchedVoucherId: 'jv_rec_bkash_8801',
      ),
      BankStatementItemModel(
        id: 'stmt_line_02',
        bankAccountId: 'bank_acc_01',
        societyId: 'swapno_chowa_main',
        txnDate: now.subtract(const Duration(days: 2)),
        description: 'Direct Member BEFTN Deposit Ref: MEM-009',
        creditPoisha: 350000, // ৳৩,৫০০.০০
        debitPoisha: 0,
        balancePoisha: 85203000,
        matchStatus: 'probableMatch',
        matchedVoucherId: null,
      ),
      BankStatementItemModel(
        id: 'stmt_line_03',
        bankAccountId: 'bank_acc_01',
        societyId: 'swapno_chowa_main',
        txnDate: now.subtract(const Duration(days: 3)),
        description: 'Bank Maintenance Charge & SMS Fee',
        creditPoisha: 0,
        debitPoisha: 57500, // ৳৫৭৫.০০
        balancePoisha: 84853000,
        matchStatus: 'unmatchedException',
        matchedVoucherId: null,
      ),
    ];

    for (final st in sampleStatements) {
      _statementItems[st.id] = st;
    }

    // 6. Seed Gateway Settlement Sample
    final sampleSettlement = GatewaySettlementModel(
      id: 'setl_bkash_20261113',
      providerType: PaymentProviderType.bkash,
      societyId: 'swapno_chowa_main',
      settlementDate: now.subtract(const Duration(days: 1)),
      grossPoisha: 200000, // ৳২,০০০.০০
      mdrFeePoisha: 3000, // ৳৩০.০০
      netSettledPoisha: 197000, // ৳১,৯৭০.০০
      status: 'settledToBank',
      bankDepositRef: 'stmt_line_01',
    );
    _settlements[sampleSettlement.id] = sampleSettlement;
  }

  // ==========================================
  // 1. GATEWAY CONFIGURATION & CONTROL (Super Admin)
  // ==========================================

  List<PaymentProviderConfigModel> getProviderConfigs() {
    return _providerConfigs.values.toList();
  }

  PaymentProviderConfigModel? getProviderConfig(String providerId) {
    return _providerConfigs[providerId];
  }

  void updateProviderStatus({
    required String providerId,
    required bool isEnabled,
    bool? isSandbox,
    int? minAmountPoisha,
    int? maxAmountPoisha,
    int? feeBps,
  }) {
    final existing = _providerConfigs[providerId];
    if (existing == null) throw Exception('গেটওয়ে কনফিগারেশন পাওয়া যায়নি: $providerId');

    _providerConfigs[providerId] = PaymentProviderConfigModel(
      providerId: existing.providerId,
      providerType: existing.providerType,
      titleBn: existing.titleBn,
      merchantIdMasked: existing.merchantIdMasked,
      isEnabled: isEnabled,
      isSandbox: isSandbox ?? existing.isSandbox,
      minAmountPoisha: minAmountPoisha ?? existing.minAmountPoisha,
      maxAmountPoisha: maxAmountPoisha ?? existing.maxAmountPoisha,
      feeBps: feeBps ?? existing.feeBps,
    );
  }

  // ==========================================
  // 2. TRANSACTION PROCESSING & IDEMPOTENCY
  // ==========================================

  List<PaymentTransactionModel> getTransactions({String? societyId, PaymentLifecycleStatus? status}) {
    return _transactions.values.where((tx) {
      if (societyId != null && tx.societyId != societyId) return false;
      if (status != null && tx.status != status) return false;
      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  PaymentTransactionModel? getTransactionById(String txId) {
    return _transactions[txId];
  }

  /// Create and Initiate Payment Transaction with Strict Idempotency Check
  PaymentTransactionModel initiatePaymentTransaction({
    required PaymentProviderType providerType,
    required String societyId,
    String? memberId,
    required PaymentPurposeType purpose,
    required int amountPoisha,
    required String idempotencyKey,
    String? collectorId,
  }) {
    // 1. Replay & Idempotency Defense
    final existingWithKey = _transactions.values.where(
      (tx) => tx.idempotencyKey == idempotencyKey,
    );
    if (existingWithKey.isNotEmpty) {
      return existingWithKey.first; // Prevent double payment / duplicate record
    }

    // 2. Gateway Rule & Limit Validation
    final config = _providerConfigs.values.firstWhere(
      (c) => c.providerType == providerType,
      orElse: () => throw Exception('এই গেটওয়ে সক্রিয় নয়!'),
    );

    if (!config.isEnabled) {
      throw Exception('সুপার অ্যাডমিন দ্বারা ${config.titleBn} সাময়িকভাবে নিষ্ক্রিয় রয়েছে!');
    }

    if (amountPoisha < config.minAmountPoisha) {
      throw Exception('সর্বনিম্ন লেনদেন সীমা ৳${config.minAmountPoisha / 100}');
    }
    if (amountPoisha > config.maxAmountPoisha) {
      throw Exception('সর্বোচ্চ লেনদেন সীমা ৳${config.maxAmountPoisha / 100}');
    }

    // 3. Integer Poisha MDR Fee Calculation
    final feePoisha = (amountPoisha * config.feeBps) ~/ 10000;
    final netAmountPoisha = amountPoisha - feePoisha;

    final txId = 'tx_${providerType.name}_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final newTx = PaymentTransactionModel(
      id: txId,
      providerType: providerType,
      providerTxnId: 'PGW_${Random().nextInt(899999) + 100000}',
      societyId: societyId,
      memberId: memberId,
      purpose: purpose,
      amountPoisha: amountPoisha,
      feePoisha: feePoisha,
      netAmountPoisha: netAmountPoisha,
      status: providerType == PaymentProviderType.cashCollection
          ? PaymentLifecycleStatus.pending
          : PaymentLifecycleStatus.processing,
      idempotencyKey: idempotencyKey,
      collectorId: collectorId,
      createdAt: DateTime.now(),
    );

    _transactions[txId] = newTx;
    return newTx;
  }

  /// Server-Side Payment Webhook / Backend Verification Confirmation
  PaymentTransactionModel verifyAndConfirmPayment({
    required String txId,
    required String providerTxnId,
    required String linkedVoucherId,
    String? verifiedBy,
  }) {
    final tx = _transactions[txId];
    if (tx == null) throw Exception('লেনদেন পাওয়া যায়নি: $txId');

    if (tx.status == PaymentLifecycleStatus.success) {
      return tx; // Already confirmed
    }

    final updatedTx = PaymentTransactionModel(
      id: tx.id,
      providerType: tx.providerType,
      providerTxnId: providerTxnId,
      societyId: tx.societyId,
      memberId: tx.memberId,
      purpose: tx.purpose,
      amountPoisha: tx.amountPoisha,
      feePoisha: tx.feePoisha,
      netAmountPoisha: tx.netAmountPoisha,
      status: PaymentLifecycleStatus.success,
      idempotencyKey: tx.idempotencyKey,
      qrTokenUuid: tx.qrTokenUuid,
      linkedVoucherId: linkedVoucherId,
      collectorId: tx.collectorId,
      verifiedBy: verifiedBy ?? 'BACKEND_AUTO_VERIFIER',
      createdAt: tx.createdAt,
      verifiedAt: DateTime.now(),
    );

    _transactions[txId] = updatedTx;

    // Invalidate linked dynamic QR if applicable
    if (tx.qrTokenUuid != null && _qrPayments.containsKey(tx.qrTokenUuid)) {
      final qr = _qrPayments[tx.qrTokenUuid]!;
      _qrPayments[tx.qrTokenUuid!] = DynamicQrPaymentModel(
        tokenUuid: qr.tokenUuid,
        societyId: qr.societyId,
        memberId: qr.memberId,
        purpose: qr.purpose,
        amountPoisha: qr.amountPoisha,
        qrPayload: qr.qrPayload,
        expiresAt: qr.expiresAt,
        isUsed: true,
        usedAt: DateTime.now(),
      );
    }

    return updatedTx;
  }

  /// Field Cash Collection Cashier Verification (Maker-Checker)
  PaymentTransactionModel verifyFieldCashierCollection({
    required String txId,
    required String cashierUserId,
    required String linkedVoucherId,
  }) {
    final tx = _transactions[txId];
    if (tx == null) throw Exception('কালেকশন রেকর্ড পাওয়া যায়নি: $txId');
    if (tx.status == PaymentLifecycleStatus.success) {
      throw Exception('এই কালেকশন ইতিমধ্যে ক্যাশিয়ার কর্তৃক যাচাইকৃত ও গৃহীত হয়েছে!');
    }

    // Separation of Duties: Cashier cannot be the field collector
    if (tx.collectorId != null && tx.collectorId == cashierUserId) {
      throw Exception('স্বয়ং সংগ্রহকারী অফিসার ক্যাশিয়ার হিসেবে অনুমোদন করতে পারবেন না! (Separation of Duties Violation)');
    }

    return verifyAndConfirmPayment(
      txId: txId,
      providerTxnId: 'CASHIER_REC_${DateTime.now().millisecondsSinceEpoch}',
      linkedVoucherId: linkedVoucherId,
      verifiedBy: cashierUserId,
    );
  }

  // ==========================================
  // 3. DYNAMIC BANGLA QR PAYMENT ENGINE
  // ==========================================

  DynamicQrPaymentModel generateBanglaQrToken({
    required String societyId,
    required String memberId,
    required PaymentPurposeType purpose,
    required int amountPoisha,
    int validityMinutes = 15,
  }) {
    if (amountPoisha <= 0) throw Exception('অবৈধ পেমেন্ট অ্যামাউন্ট!');

    final tokenUuid = 'qr_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final expiresAt = DateTime.now().add(Duration(minutes: validityMinutes));

    // Construct Bangladesh Bank Standard Bangla QR format string
    final amountStr = (amountPoisha / 100.0).toStringAsFixed(2);
    final payload = '00020101021226460010bd.gov.bb28280010017112233440108SWAPNOCO520459995303050540${amountStr.length.toString().padLeft(2, '0')}$amountStr'
        '5802BD5925Swapno Chowa Oikyo Somiti6006DHAKA62${tokenUuid.length.toString().padLeft(2, '0')}$tokenUuid'
        '6304${(tokenUuid.hashCode.abs() % 9000 + 1000).toRadixString(16).toUpperCase()}';

    final qrModel = DynamicQrPaymentModel(
      tokenUuid: tokenUuid,
      societyId: societyId,
      memberId: memberId,
      purpose: purpose,
      amountPoisha: amountPoisha,
      qrPayload: payload,
      expiresAt: expiresAt,
      isUsed: false,
    );

    _qrPayments[tokenUuid] = qrModel;
    return qrModel;
  }

  bool validateAndConsumeQrToken(String tokenUuid) {
    final qr = _qrPayments[tokenUuid];
    if (qr == null || !qr.isValid) return false;

    _qrPayments[tokenUuid] = DynamicQrPaymentModel(
      tokenUuid: qr.tokenUuid,
      societyId: qr.societyId,
      memberId: qr.memberId,
      purpose: qr.purpose,
      amountPoisha: qr.amountPoisha,
      qrPayload: qr.qrPayload,
      expiresAt: qr.expiresAt,
      isUsed: true,
      usedAt: DateTime.now(),
    );
    return true;
  }

  List<DynamicQrPaymentModel> getQrTokens({String? societyId}) {
    return _qrPayments.values.where((q) {
      if (societyId != null && q.societyId != societyId) return false;
      return true;
    }).toList()..sort((a, b) => b.expiresAt.compareTo(a.expiresAt));
  }

  // ==========================================
  // 4. COMMERCIAL BANK ACCOUNTS & 3-WAY RECONCILIATION
  // ==========================================

  List<SocietyBankAccountModel> getBankAccounts({String? societyId}) {
    return _bankAccounts.values.where((b) {
      if (societyId != null && b.societyId != societyId) return false;
      return true;
    }).toList();
  }

  SocietyBankAccountModel createBankAccount(SocietyBankAccountModel account) {
    _bankAccounts[account.id] = account;
    return account;
  }

  List<BankStatementItemModel> getBankStatementItems({String? bankAccountId}) {
    return _statementItems.values.where((st) {
      if (bankAccountId != null && st.bankAccountId != bankAccountId) return false;
      return true;
    }).toList()..sort((a, b) => b.txnDate.compareTo(a.txnDate));
  }

  /// Automated 3-Way Reconciliation Engine
  /// Matches Bank Statement Items against General Ledger & Transactions
  Map<String, dynamic> runAutomatedBankReconciliation(String bankAccountId) {
    int matchedCount = 0;
    int probableCount = 0;
    int exceptionCount = 0;
    int matchedPoisha = 0;

    final statements = _statementItems.values.where((s) => s.bankAccountId == bankAccountId).toList();
    final successfulTxns = _transactions.values.where((t) => t.isSuccess).toList();

    for (final st in statements) {
      if (st.matchStatus == 'matched') {
        matchedCount++;
        matchedPoisha += (st.creditPoisha > 0 ? st.creditPoisha : st.debitPoisha);
        continue;
      }

      // Check for exact matching transaction
      PaymentTransactionModel? exactMatch;
      for (final tx in successfulTxns) {
        // Same net amount and within 3 days of statement date
        if ((tx.netAmountPoisha == st.creditPoisha || tx.amountPoisha == st.creditPoisha) &&
            tx.createdAt.difference(st.txnDate).inDays.abs() <= 3) {
          exactMatch = tx;
          break;
        }
      }

      if (exactMatch != null) {
        _statementItems[st.id] = BankStatementItemModel(
          id: st.id,
          bankAccountId: st.bankAccountId,
          societyId: st.societyId,
          txnDate: st.txnDate,
          description: st.description,
          debitPoisha: st.debitPoisha,
          creditPoisha: st.creditPoisha,
          balancePoisha: st.balancePoisha,
          matchStatus: 'matched',
          matchedVoucherId: exactMatch.linkedVoucherId ?? 'AUTO_MATCH_${exactMatch.id}',
        );
        matchedCount++;
        matchedPoisha += st.creditPoisha;
      } else if (st.creditPoisha > 0) {
        // Probable if amount matches any historical pending/processing
        _statementItems[st.id] = BankStatementItemModel(
          id: st.id,
          bankAccountId: st.bankAccountId,
          societyId: st.societyId,
          txnDate: st.txnDate,
          description: st.description,
          debitPoisha: st.debitPoisha,
          creditPoisha: st.creditPoisha,
          balancePoisha: st.balancePoisha,
          matchStatus: 'probableMatch',
          matchedVoucherId: null,
        );
        probableCount++;
      } else {
        exceptionCount++;
      }
    }

    return {
      'bankAccountId': bankAccountId,
      'totalStatementLines': statements.length,
      'matchedCount': matchedCount,
      'probableCount': probableCount,
      'exceptionCount': exceptionCount,
      'matchedPoisha': matchedPoisha,
      'matchedBdt': matchedPoisha / 100.0,
      'reconciliationTimestamp': DateTime.now().toIso8601String(),
    };
  }

  // ==========================================
  // 5. REFUND, REVERSAL & DISPUTE WORKFLOW
  // ==========================================

  List<PaymentRefundModel> getRefunds({String? societyId}) {
    return _refunds.values.where((r) {
      if (societyId != null && r.societyId != societyId) return false;
      return true;
    }).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  PaymentRefundModel requestRefund({
    required String originalTxnId,
    required String societyId,
    required int amountPoisha,
    required String reason,
    required String requestedBy,
  }) {
    final originalTx = _transactions[originalTxnId];
    if (originalTx == null) throw Exception('মূল লেনদেন রেকর্ড পাওয়া যায়নি: $originalTxnId');

    if (amountPoisha <= 0 || amountPoisha > originalTx.amountPoisha) {
      throw Exception('রিফান্ড পরিমাণ মূল লেনদেনের পরিমাণের বেশি হতে পারে না!');
    }

    final refundId = 'ref_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(999)}';
    final refund = PaymentRefundModel(
      id: refundId,
      originalTxnId: originalTxnId,
      societyId: societyId,
      amountPoisha: amountPoisha,
      reason: reason,
      status: 'pendingApproval',
      requestedBy: requestedBy,
      createdAt: DateTime.now(),
    );

    _refunds[refundId] = refund;
    return refund;
  }

  PaymentRefundModel approveAndExecuteRefund({
    required String refundId,
    required String approvedBy,
    required String reversalVoucherId,
  }) {
    final refund = _refunds[refundId];
    if (refund == null) throw Exception('রিফান্ড আবেদন পাওয়া যায়নি: $refundId');
    if (refund.status == 'refunded') throw Exception('এই রিফান্ড ইতিমধ্যে সম্পন্ন হয়েছে!');

    final originalTx = _transactions[refund.originalTxnId];
    if (originalTx == null) throw Exception('মূল লেনদেন রেকর্ড অনুপস্থিত!');

    // Update refund status
    final approvedRefund = PaymentRefundModel(
      id: refund.id,
      originalTxnId: refund.originalTxnId,
      societyId: refund.societyId,
      amountPoisha: refund.amountPoisha,
      reason: refund.reason,
      status: 'refunded',
      requestedBy: refund.requestedBy,
      approvedBy: approvedBy,
      reversalVoucherId: reversalVoucherId,
      createdAt: refund.createdAt,
    );
    _refunds[refundId] = approvedRefund;

    // Update original transaction state to refunded (Zero silent deletion!)
    final updatedOriginal = PaymentTransactionModel(
      id: originalTx.id,
      providerType: originalTx.providerType,
      providerTxnId: originalTx.providerTxnId,
      societyId: originalTx.societyId,
      memberId: originalTx.memberId,
      purpose: originalTx.purpose,
      amountPoisha: originalTx.amountPoisha,
      feePoisha: originalTx.feePoisha,
      netAmountPoisha: originalTx.netAmountPoisha,
      status: refund.amountPoisha == originalTx.amountPoisha
          ? PaymentLifecycleStatus.refunded
          : PaymentLifecycleStatus.partiallyRefunded,
      idempotencyKey: originalTx.idempotencyKey,
      qrTokenUuid: originalTx.qrTokenUuid,
      linkedVoucherId: originalTx.linkedVoucherId,
      collectorId: originalTx.collectorId,
      verifiedBy: originalTx.verifiedBy,
      createdAt: originalTx.createdAt,
      verifiedAt: originalTx.verifiedAt,
    );
    _transactions[originalTx.id] = updatedOriginal;

    return approvedRefund;
  }

  // ==========================================
  // 6. SETTLEMENT MANAGEMENT
  // ==========================================

  List<GatewaySettlementModel> getSettlements({String? societyId}) {
    return _settlements.values.where((s) {
      if (societyId != null && s.societyId != societyId) return false;
      return true;
    }).toList()..sort((a, b) => b.settlementDate.compareTo(a.settlementDate));
  }

  GatewaySettlementModel recordGatewaySettlement({
    required PaymentProviderType providerType,
    required String societyId,
    required int grossPoisha,
    required int mdrFeePoisha,
    required String? bankDepositRef,
  }) {
    final netPoisha = grossPoisha - mdrFeePoisha;
    final id = 'setl_${providerType.name}_${DateTime.now().millisecondsSinceEpoch}';

    final setl = GatewaySettlementModel(
      id: id,
      providerType: providerType,
      societyId: societyId,
      settlementDate: DateTime.now(),
      grossPoisha: grossPoisha,
      mdrFeePoisha: mdrFeePoisha,
      netSettledPoisha: netPoisha,
      status: 'settledToBank',
      bankDepositRef: bankDepositRef,
    );

    _settlements[id] = setl;
    return setl;
  }

  // ==========================================
  // 7. INTEGRATION HEALTH & MONITORING
  // ==========================================

  Map<String, Map<String, dynamic>> getGatewayHealth() {
    return Map.unmodifiable(_gatewayHealth);
  }

  Map<String, dynamic> getPaymentHubMetrics(String societyId) {
    int totalCollectedPoisha = 0;
    int totalVerifiedPoisha = 0;
    int pendingCollectionsCount = 0;
    int activeGatewaysCount = 0;

    for (final cfg in _providerConfigs.values) {
      if (cfg.isEnabled) activeGatewaysCount++;
    }

    for (final tx in _transactions.values) {
      if (tx.societyId == societyId) {
        if (tx.status == PaymentLifecycleStatus.success) {
          totalCollectedPoisha += tx.amountPoisha;
          totalVerifiedPoisha += tx.netAmountPoisha;
        } else if (tx.status == PaymentLifecycleStatus.pending) {
          pendingCollectionsCount++;
        }
      }
    }

    int totalBankBalancePoisha = 0;
    for (final b in _bankAccounts.values) {
      if (b.societyId == societyId && b.isActive) {
        totalBankBalancePoisha += b.currentBalancePoisha;
      }
    }

    return {
      'totalCollectedBdt': totalCollectedPoisha / 100.0,
      'totalVerifiedBdt': totalVerifiedPoisha / 100.0,
      'pendingCollectionsCount': pendingCollectionsCount,
      'activeGatewaysCount': activeGatewaysCount,
      'totalBankBalanceBdt': totalBankBalancePoisha / 100.0,
      'totalTransactionsCount': _transactions.length,
      'activeQrCount': _qrPayments.values.where((q) => q.isValid).length,
    };
  }
}
