# DOUBLE-ENTRY ACCOUNTING RULES & OPERATIONAL TRANSACTION MAPPINGS
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 2 — Advanced Double-Entry Financial Engine  
**Standards:** Double-Entry Principle, Maker-Checker Verification, Fixed-Point Math  
**Date:** 2026-11-14

---

## 1. The Fundamental Accounting Invariant

Every transaction processed by the Financial Engine MUST strictly adhere to:

$$\sum \text{DEBITS} = \sum \text{CREDITS}$$
$$\text{ASSETS} = \text{LIABILITIES} + \text{EQUITY}$$

> [!CAUTION]
> **Zero-Tolerance Unbalanced Transaction Rejection**:  
> Any journal entry where `totalDebit != totalCredit` is rejected at both the client validator and server-side Cloud Function trigger. Transactions with even a 1 poisha discrepancy are aborted with an audit rejection log.

---

## 2. Standard Operational Transaction Mappings (স্বয়ংক্রিয় জাবেদা ম্যাপিং)

When operational events occur in the existing modules (Members, Savings, Loans, Expenses), the engine generates automated, atomic Journal Entries.

### A. Member Savings Deposit (সদস্য সঞ্চয় জমা)
*A member deposits ৳1,000 cash into their Monthly DPS account.*
- **Debit**: `1110` Main Cash in Hand / Vault (+Asset) $\rightarrow$ ৳1,000.00
- **Credit**: `2120` Member DPS Savings Liability (+Liability) $\rightarrow$ ৳1,000.00
*(Note: Assets increase, Society Liabilities increase. Society Revenue is ৳0.00).*

---

### B. Member Savings Withdrawal (সদস্য সঞ্চয় উত্তোলন)
*A member withdraws ৳500 from their general daily savings account in cash.*
- **Debit**: `2110` General Daily Savings Liability (-Liability) $\rightarrow$ ৳500.00
- **Credit**: `1110` Main Cash in Hand / Vault (-Asset) $\rightarrow$ ৳500.00
*(Note: Society liability is extinguished, Cash decreases. Revenue is unaffected).*

---

### C. Loan Disbursement (ঋণ বিতরণ)
*A loan of ৳50,000 is approved and disbursed to Member Rahim from City Bank account with a ৳500 documentation fee deducted upfront.*
- **Debit**: `1141` Micro-Loans Principal Receivable (+Asset) $\rightarrow$ ৳50,000.00
- **Credit**: `1121` City Bank PLC Current Account (-Asset) $\rightarrow$ ৳49,500.00
- **Credit**: `4120` Loan Processing & Form Fees (+Revenue) $\rightarrow$ ৳500.00
*(Note: $\sum \text{Debits} (50,000) = \sum \text{Credits} (49,500 + 500) = 50,000$. Accurate split accounting).*

---

### D. Loan Installment Repayment (ঋণের কিস্তি আদায় - ত্রি-স্তর বিভাজন)
*Member Rahim pays a monthly installment of ৳4,800 in cash, comprising ৳4,000 Principal, ৳700 Interest, and ৳100 Overdue Late Fee.*
- **Debit**: `1110` Main Cash in Hand (+Asset) $\rightarrow$ ৳4,800.00
- **Credit**: `1141` Micro-Loans Principal Receivable (-Asset) $\rightarrow$ ৳4,000.00
- **Credit**: `4110` Loan Interest Income (+Revenue) $\rightarrow$ ৳700.00
- **Credit**: `4130` Overdue Installment Late Penalties (+Revenue) $\rightarrow$ ৳100.00
*(Note: $\sum \text{Debits} (4,800) = \sum \text{Credits} (4,000 + 700 + 100) = 4,800$. Loan principal collection reduces receivables, while interest and fines are credited as operational income).*

---

### E. Operating Expense Payment (অফিস খরচ প্রদান)
*Society pays ৳6,000 office rent via bKash Merchant Wallet.*
- **Debit**: `5310` Office Rent Expense (+Expense) $\rightarrow$ ৳6,000.00
- **Credit**: `1131` bKash Merchant Wallet (-Asset) $\rightarrow$ ৳6,000.00

---

### F. Fund Transfer Between Accounts (ক্যাশ ও ব্যাংকে তহবিল স্থানান্তর)
*Cashier deposits ৳25,000 surplus physical cash into the City Bank account.*
- **Debit**: `1121` City Bank PLC Account (+Asset) $\rightarrow$ ৳25,000.00
- **Credit**: `1110` Main Cash in Hand / Vault (-Asset) $\rightarrow$ ৳25,000.00
*(Note: Internal asset transfer; zero effect on society P&L or liabilities).*

---

### G. Fiscal Year-End Surplus Allocation (বছরান্তে নিট লাভ বণ্টন)
*Society closes the fiscal year with ৳100,000 Net Surplus. Per Bangladesh Cooperative Societies Act, 15% is transferred to Statutory Reserve, 3% to CDF, and remaining to Retained Earnings.*
- **Debit**: `3320` Current Year Net Surplus (-Surplus) $\rightarrow$ ৳100,000.00
- **Credit**: `3210` Statutory Reserve Fund (15%) $\rightarrow$ ৳15,000.00
- **Credit**: `3220` Cooperative Development Fund (3%) $\rightarrow$ ৳3,000.00
- **Credit**: `3310` Prior Years' Retained Surplus (82%) $\rightarrow$ ৳82,000.00

---

## 3. Strict Immutability & Reversal Architecture

1. **No Direct `DELETE` or `UPDATE` on Posted Journals**:
   - Once a journal entry is marked `status: 'posted'`, Firestore security rules strictly block `allow update, delete: if false;`.
2. **Reversal Transaction Mechanics (সংশোধনী বা রিভার্সাল এন্ট্রি)**:
   - To correct an error in a posted journal, the authorized accountant must create a **Reversing Journal Entry** with an explicit audit note:
     - New Journal `REV-2026-0042` is linked to original `JRN-2026-0015`.
     - Automatically mirrors all debits as credits and credits as debits.
     - The original journal remains permanent in the General Ledger for audit inspection.
3. **Maker-Checker Security Control**:
   - Operator A (Maker/Cashier) drafts a manual journal entry.
   - Operator B (Checker/Accountant or Society Owner) verifies and approves it.
   - A user is cryptographically prevented from approving their own drafted entries.
