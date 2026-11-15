# Financial Verification & Reconciliation Testing Guide
## Phase 13 Enterprise Assurance Specifications

---

## 1. Mathematical & Accounting Principles

Cooperative societies in Bangladesh operate under strict financial auditing guidelines set by the Department of Cooperatives (সমবায় অধিদপ্তর). The QA engine independently verifies these rules:

### Principle 1: Integer Poisha Resolution
- All monetary arithmetic operates in 64-bit integers representing Poisha.
- `৳1,250.50` is stored and calculated as `125050` Poisha.
- Floating-point `double` or `float` types are completely prohibited in calculations to avoid rounding drift.

### Principle 2: Double-Entry Equilibrium
- For every financial voucher $V$:
  $$\sum \text{Debits} = \sum \text{Credits}$$
- If an unbalanced transaction is attempted, the database schema transaction must abort and roll back.

### Principle 3: Member Deposits as Liabilities
- Member general savings, fixed-term deposits (FDR), and monthly DPS accounts are **Liabilities (দায়)** to the society, never Income (আয়) or Equity (মূলধন).
- Deposit Journal Entry:
  - **Debit**: Asset Account (`1010` Cash or `1020` Bank)
  - **Credit**: Liability Account (`2010` Member Savings or `2020` DPS Deposits)

### Principle 4: Loan Repayment Bifurcation
- When a loan installment of amount $A$ is collected:
  - Principal portion $P$ credits Asset Account `1100` (Loan Portfolio Receivable), reducing the member's outstanding debt.
  - Interest portion $I$ credits Revenue Account `4010` (Interest Income).
  - Debit Asset Account `1010` (Cash in Hand) with full amount $A = P + I$.
- Treating the principal repayment as income is an audit violation.

---

## 2. Automated Financial Reconciliation Test Suite

The test suite runs an end-to-end reconciliation across 1,000 synthetic transactions:
1. Simulates 300 member admission deposits.
2. Simulates 150 loan disbursements across Micro-credit and SME portfolios.
3. Simulates 450 installment collections with automated principal/interest splits.
4. Simulates 50 expense vouchers and 50 member withdrawals.
5. Verifies that the resulting Trial Balance (রেওয়ামিল) and Balance Sheet (উদ্বৃত্তপত্র) balance to the exact Poisha:
   $$\text{Assets} = \text{Liabilities} + \text{Equity}$$
6. Asserts zero silent overwrites, zero unhandled floating-point remainders, and 100% audit trail generation.
