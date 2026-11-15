# GENERAL LEDGER (GL) ARCHITECTURE & DATA DESIGN
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 2 — Advanced Double-Entry Financial Engine  
**Date:** 2026-11-14

---

## 1. General Ledger Principles & Invariance

The **General Ledger (খতিয়ান বই)** is the single source of financial truth for the cooperative.
- Every ledger line is directly tied to a verified, posted Journal Entry.
- **Zero Orphaned Lines**: A ledger entry cannot exist without a parent `journalId` and corresponding `voucherNo`.
- **Derived Running Balance**: While the total account balance is cached on `chart_of_accounts/{id}` for fast dashboard rendering, historical running balances are calculated deterministically in query sequences.

---

## 2. General Ledger Document Schema (`/somitis/{somitiId}/general_ledger/{glId}`)

```dart
class GeneralLedgerEntryModel {
  final String id;
  final String somitiId;
  final String journalId;           // Reference to posted journal entry
  final String journalNumber;       // e.g. "JRN-202611-00012"
  final DateTime entryDate;         // Transaction effective date
  final String accountingPeriodId;  // Period ID
  final String accountId;           // COA document ID
  final String accountCode;         // e.g. "1110"
  final String accountName;         // e.g. "প্রধান ক্যাশ ড্রয়ার"
  final AccountCategory category;   // asset, liability, equity, income, expense
  final int debitInPoisha;          // Debit amount
  final int creditInPoisha;         // Credit amount
  final int runningBalanceInPoisha; // Cumulative balance after this entry
  final String description;         // Description / narration
  final String? referenceNo;        // Source voucher / receipt / memo no
  final String createdByUid;
  final DateTime postedAt;
}
```

---

## 3. Querying & Indexing Architecture

To support instantaneous ledger lookups across thousands of transactions with zero lag:

### A. Required Firestore Composite Indexes:
```json
{
  "collectionGroup": "general_ledger",
  "queryScope": "COLLECTION",
  "fields": [
    { "fieldPath": "accountId", "order": "ASCENDING" },
    { "fieldPath": "entryDate", "order": "ASCENDING" }
  ]
}
```

### B. High-Performance Ledger Query Engine:
- **Date-Range Filtering**:
  ```dart
  _firestore
      .collection('somitis')
      .doc(somitiId)
      .collection('general_ledger')
      .where('accountId', isEqualTo: selectedAccountId)
      .where('entryDate', isGreaterThanOrEqualTo: startDate)
      .where('entryDate', isLessThanOrEqualTo: endDate)
      .orderBy('entryDate', descending: false)
      .limit(pageSize);
  ```
- **Opening Balance Aggregation**:
  To display the exact Opening Balance for any custom date range, the engine queries the cumulative balance immediately prior to `startDate`:
  `where('accountId', '==', id).where('entryDate', '<', startDate).orderBy('entryDate', 'desc').limit(1)`.

---

## 4. Ledger Export & Audit Trail

- **Export Formats**: PDF official ledger pad (A4 formatted with official stamps), Excel (.xlsx), and CSV.
- **Audit Linking**: Clicking on any ledger entry opens an interactive modal displaying the complete multi-line Journal Entry, source voucher, maker-checker signatures, and immutable timestamp.
