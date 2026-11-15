# FINANCIAL DATA MIGRATION & ADAPTATION PLAN
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 2 — Advanced Double-Entry Financial Engine  
**Standards:** Zero Downtime, Zero Data Loss, Safe Opening Balance Invariant  
**Date:** 2026-11-14

---

## 1. Existing Data Inventory & Forensic Audit

A forensic scan of the existing database reveals the current state of operational financial data across societies:

1. **Holding Accounts (`financial_accounts`)**:
   - `CASH-MAIN`: Physical cash drawer balance.
   - Commercial Bank accounts and MFS wallets.
2. **Member Savings (`deposits` & `savings_accounts`)**:
   - Total member savings liabilities: $\sum \text{Member DPS Balances} + \sum \text{General Savings}$.
3. **Active Loans (`loans`)**:
   - Outstanding Loan Principal Receivables: $\sum (\text{Loan Principal} - \text{Principal Recovered})$.
4. **Historical Expenses (`expenses`)**:
   - Categorized operating expenditures.

---

## 2. Safe 4-Step Migration Strategy

```mermaid
flowchart TD
    Step1[Step 1: Deploy COA Master Template to /somitis/{id}/chart_of_accounts] --> Step2[Step 2: Aggregate Existing Cash, Loans & Savings Balances]
    Step2 --> Step3[Step 3: Generate Automated Opening Balance Journal Entry JRN-OPENING]
    Step3 --> Step4[Step 4: Reconcile Balancing Equity Account: Assets == Liabilities + Equity]
    Step4 --> Step5[Step 5: Activate Dual-Write Adapter for Live Transactions]
    Step5 --> Step6[Step 6: Verify Zero Discrepancy on Trial Balance & Balance Sheet]
```

---

## 3. The Opening Balance Journal Entry Formula

To bridge existing operational records into the formal General Ledger without corrupting past histories:

$$\text{Total Existing Assets} = \text{Cash in Hand} + \text{Bank Balances} + \text{MFS Balances} + \text{Outstanding Loan Principal}$$
$$\text{Total Existing Liabilities} = \text{Total Member Savings Liabilities} + \text{Accrued Payables}$$
$$\text{Opening Balancing Equity (Retained Surplus)} = \text{Total Assets} - \text{Total Liabilities}$$

### Automated Opening Journal Voucher (`JRN-OPENING`):
- **Debit**: `1110` Main Cash in Hand (Existing cash balance)
- **Debit**: `1120` Bank Accounts (Existing bank balances)
- **Debit**: `1140` Loan Principal Receivable (Existing active loans principal)
- **Credit**: `2110` / `2120` Member Savings Liabilities (Existing total member deposits)
- **Credit**: `3310` Prior Retained Surplus / Capital Reserve (Balancing Difference)

$$\sum \text{Debits} = \sum \text{Credits} \quad (\Delta = 0)$$

---

## 4. Dual-Write Forward Compatibility

To preserve existing screens (`view-deposits`, `view-loans`, `view-expenses`) without breaking ongoing operations:
- When a cashier records a deposit:
  1. The existing record is written to `/somitis/{somitiId}/deposits/{id}` (Preserves existing views).
  2. The financial engine simultaneously posts a double-entry journal entry to `/somitis/{somitiId}/journal_entries` and updates `/somitis/{somitiId}/general_ledger`.
- Both models stay 100% synchronized in real time.

---

## 5. Rollback & Failsafe Plan

- If any anomaly occurs during opening balance generation, the script runs in `dry-run` simulation mode first.
- Legacy records are **read-only** during migration; no existing `deposits` or `loans` documents are modified or deleted.
- Rollback simply involves setting `features.double_entry_accounting = false` in the Super Admin dashboard; legacy screens continue running unaffected.
