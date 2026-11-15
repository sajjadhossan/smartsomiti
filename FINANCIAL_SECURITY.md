# FINANCIAL SECURITY, ATOMICITY & PERMISSION GOVERNANCE
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 2 — Advanced Double-Entry Financial Engine  
**Standards:** Bank-Grade Security, Zero-Trust Architecture, Cryptographic Permissions  
**Date:** 2026-11-14

---

## 1. Mathematical & Precision Security

### Strict Fixed-Point Poisha Representation
- To eliminate floating-point IEEE 754 precision drift (e.g. `0.1 + 0.2 = 0.30000000000000004`), ALL monetary amounts in models, database documents, and calculations are stored as **integer minor currency units (Poisha)**:
  $$\text{1 Taka (৳)} = 100\text{ Poisha}$$
- **Example**:
  - ৳5,450.75 is stored as `545075`.
  - Display converters format to UI: `(amountInPoisha / 100).toStringAsFixed(2)`.
  - Zero rounding discrepancy over millions of compound transactions.

---

## 2. Transaction Atomicity & Idempotency

### A. All-or-Nothing ACID Commit
- Any financial transaction that affects multiple ledgers (e.g., Loan Repayment affecting Cash Drawer, Loan Principal Receivable, and Interest Income) **MUST** execute within an atomic Firestore Transaction:
  ```dart
  await _firestore.runTransaction((tx) async {
    // 1. Verify idempotency
    // 2. Read all affected accounts
    // 3. Compute new balances
    // 4. Write Journal Entry
    // 5. Write General Ledger Lines
    // 6. Update Account Balances
  });
  ```
- If any write fails or a network dropout occurs mid-flight, the entire operation is automatically rolled back.

### B. Idempotency Key Defense
- Every financial submission carries a client-generated UUIDv4 `idempotencyKey`.
- If an operator accidentally double-taps "Submit Voucher" or their 4G connection retries, the server identifies the duplicate key, returns the existing receipt, and prevents duplicate financial charges.

---

## 3. Master Admin Total Control & Permission Governance

### A. Granular Button & Action Matrix
The Super Admin Control Center manages permissions for every financial action:

| Module / Action | Key in Master Admin Switchboard | Permitted Default Roles | Super Admin Override |
|-----------------|---------------------------------|-------------------------|----------------------|
| **Financial Accounting Module** | `mod_financial_accounting` | Owner, Accountant | Global & Society Toggle |
| **Double-Entry Journal** | `feat_journal_entries` | Owner, Accountant | Global & Society Toggle |
| **Create Journal Entry (Draft)**| `act_journal_create` | Accountant, Cashier | Granular Button Switch |
| **Approve & Post Journal Entry**| `act_journal_post` | Owner, Chief Accountant | Maker-Checker Enforced |
| **Reverse Posted Transaction** | `act_journal_reverse` | Owner, Super Admin | Strict Audit Reason |
| **View General Ledger** | `act_ledger_view` | Owner, Manager, Acct | Toggle per Role |
| **Export Financial Statements** | `act_reports_export` | Owner, Accountant | Toggle per Role |
| **Bank Reconciliation** | `act_bank_reconcile` | Owner, Accountant | Toggle per Society |
| **Financial Period Closing** | `act_period_close` | Owner, Super Admin | Master Admin Override |
| **Reopen Closed Period** | `act_period_reopen` | Super Admin Only | Mandatory Justification |

---

## 4. Firestore Security Rules Enforcement

Permissions are strictly enforced at the database layer. Hiding a UI button is accompanied by rule rejections:

```javascript
// Strict enforcement for Journal Entries
match /somitis/{somitiId}/journal_entries/{journalId} {
  allow read: if isSocietyMember(somitiId);
  allow create: if isSocietyAdmin(somitiId) && 
                   isFeatureActive(somitiId, 'financial_accounting') &&
                   isActionPermitted(somitiId, 'act_journal_create');
  
  // Posted entries are strictly immutable
  allow update: if isSocietyAdmin(somitiId) && 
                   resource.data.status != 'posted' &&
                   request.resource.data.status == 'posted';
                   
  allow delete: if isSocietyAdmin(somitiId) && resource.data.status == 'draft';
}

// Strict enforcement for General Ledger (Append-Only)
match /somitis/{somitiId}/general_ledger/{glId} {
  allow read: if isSocietyMember(somitiId);
  allow create: if isSocietyAdmin(somitiId);
  allow update, delete: if false; // 100% Immutable
}
```

---

## 5. Inviolable Historical Data Preservation

- **Zero Deletion Guarantee**: Disabling a financial module (e.g. turning off "Double-Entry Accounting" or "Bank Reconciliation") in the Super Admin dashboard **NEVER** deletes, modifies, or archives historical data documents.
- The rule layer merely rejects new mutations:
  `allow write: if isFeatureActive(...)`.
- Historical audit trails, balance sheets, and journal ledgers remain intact for lifetime compliance audits.
