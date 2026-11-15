# Financial Integrity Verification & Accounting Standards
## Phase 12 Production Readiness Review

---

## 1. Non-Negotiable Financial Invariants

In a cooperative financial institution, data accuracy and legal compliance are critical. The accounting engine enforces the following mathematical and architectural invariants:

1. **Integer Poisha Arithmetic**: All monetary fields are stored as 64-bit integers in Poisha (1 BDT = 100 Poisha). Floating-point arithmetic is strictly prohibited in business logic to avoid IEEE 754 precision drift.
2. **Double-Entry Equilibrium**: For every posted transaction, `Sum(Debits) == Sum(Credits)`. A single-entry transaction or an unbalanced journal voucher is blocked and rejected at the database schema level.
3. **Immutable Posted Ledger**: Once a journal voucher transitions to `POSTED`, its database record is locked. Edits and deletions are disallowed. Corrections must be executed via counter-entries (reversal journals) with an explicit audit reason.
4. **Member Deposits as Liabilities**: Member savings, fixed deposits, and DPS funds are legally the liabilities of the cooperative owed to its members. Under no circumstances are they classified as equity or revenue.
5. **Loan Principal vs Interest Separation**: Loan repayments are split into Principal (which reduces the Loan Asset receivable) and Interest (which is credited to Revenue).
6. **Zero Silent Execution**: All high-impact operations (withdrawals over ৳50,000, dividend distributions, fiscal year closures) require explicit dual confirmation and a 3-second UI debounce lockout.

---

## 2. Standard Chart of Accounts Mapping

```
1000 - ASSETS
  1010 - Cash in Hand (Petty Cash)
  1020 - Cash at Bank (Sonali Bank PLC, City Bank PLC)
  1030 - Mobile Financial Services (bKash Merchant, Nagad Merchant)
  1100 - Loan Portfolio (Micro-credit, Small Enterprise, SME)
  1200 - Fixed & Capital Assets (Office Equipment, Furniture)

2000 - LIABILITIES
  2010 - Member General Savings Deposits
  2020 - Member Monthly DPS Deposits
  2030 - Member Fixed Term Deposits (FDR)
  2040 - Accounts Payable & Accrued Expenses

3000 - EQUITY & RESERVES
  3010 - Member Share Capital
  3020 - Statutory Reserve Fund (Cooperative Act 15% statutory requirement)
  3030 - Bad Debt Reserve Fund
  3040 - Retained Earnings

4000 - REVENUE
  4010 - Loan Interest Income
  4020 - Member Admission & Form Fees
  4030 - Passbook & Documentation Fees
  4040 - Penalty & Late Fees

5000 - EXPENSES
  5010 - Member Savings Interest Expense
  5020 - Staff Salaries & Allowances
  5030 - Office Rent & Utilities
  5040 - Printing, Stationary & Postage
  5050 - Bank Charges & SMS Notification Fees
```

---

## 3. End-to-End Accounting Audit Verification

The test suite executes independent automated checks verifying:
- Balance sheet balancing: `Assets == Liabilities + Equity`.
- Income statement reconciliation: `Net Profit == Total Revenue - Total Expenses`.
- Trial balance equality across 1,000 simulated real-world transactions.
- Zero data loss during automated backup restoration drills.
