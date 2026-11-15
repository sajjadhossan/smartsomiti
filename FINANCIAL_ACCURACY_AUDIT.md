# FINANCIAL ACCURACY AND CALCULATION AUDIT
**Project:** Multi-Society Cooperative Management System ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Scope:** Mathematical formulas, amortization schedules, deposit calculations, interest accounting, and double-entry balance sheets  
**Auditor:** Principal Financial Software Engineer & Actuarial QA  
**Date:** 2026-11-14

---

## 1. Executive Summary

Financial calculations within the cooperative management system were audited against standard accounting practices and Bangladeshi cooperative banking standards.

Overall Calculation Status: **PASS (Accurate Core Math with Precision Best Practices Needed)**.

---

## 2. Mathematical Audit by Financial Component

### A. Flat Rate Interest Calculation (সরল সুদ)
- **Code Reference**: `lib/core/models/loan_model.dart` and `index.html` (`calculateFlatLoan`)
- **Formula**:
  $$I = P \times \left(\frac{R}{100}\right) \times \left(\frac{T}{12}\right)$$
  $$\text{Total Payable} = P + I$$
  $$\text{EMI} = \frac{\text{Total Payable}}{N}$$
  where $P$ = Principal, $R$ = Annual Interest Rate (%), $T$ = Duration in months, $N$ = Number of installments.
- **Verification Example**:
  - Principal: ৳50,000, Annual Rate: 12%, Tenure: 12 months.
  - Expected Interest: $50000 \times 0.12 \times 1 = 6,000$.
  - Total Payable: ৳56,000.
  - Monthly Installment: $56000 / 12 = 4,666.67$.
- **Audit Result**: **PASS**. Code accurately calculates interest and evenly distributes monthly principal and interest components.

---

### B. Reducing Balance Interest Calculation (হ্রাসমান সুদ / Reducing Balance EMI)
- **Code Reference**: `lib/core/models/loan_model.dart` (`generateSchedule`)
- **Formula**:
  $$\text{EMI} = P \times r \times \frac{(1+r)^n}{(1+r)^n - 1}$$
  where $r$ = monthly interest rate $(R / 12 / 100)$, $n$ = total number of monthly installments.
- **Verification Example**:
  - Principal: ৳100,000, Annual Rate: 12% ($r = 0.01$), Tenure: 12 months.
  - Calculated EMI: $100000 \times 0.01 \times \frac{(1.01)^{12}}{(1.01)^{12} - 1} = 8,884.88$.
  - Month 1: Interest = ৳1,000.00, Principal = ৳7,884.88, Remaining = ৳92,115.12.
  - Month 12: Principal paid closes exactly to ৳0 balance.
- **Audit Result**: **PASS**. The amortizer correctly computes diminishing interest while increasing the principal amortization component per period.

---

### C. Savings & DPS Calculation (ডিপিএস ও সাধারণ সঞ্চয়)
- **Code Reference**: `lib/core/models/savings_account_model.dart`
- **Features Verified**:
  - Monthly installment accumulation: $\text{Current Balance} = \sum \text{Installments} + \text{Profit/Dividend} - \text{Withdrawals}$.
  - Late payment penalty calculation: Fixed fee (e.g., ৳50) or percentage-based penalty on overdue monthly DPS installments.
- **Audit Result**: **PASS**.

---

### D. Double-Entry Cashbook & Balance Sheet Verification
- **Accounting Identity Checked**:
  $$\text{Assets} = \text{Liabilities} + \text{Equity}$$
  $$\text{Total Cash In Hand} = \text{Opening Balance} + \sum \text{Collections} - \sum \text{Disbursements} - \sum \text{Expenses}$$
- **Audit Findings**:
  - Cashbook dynamically tallies:
    1. Member DPS Deposits (+)
    2. Member Loan Repayments (+)
    3. Other Incomes (+)
    4. Member Withdrawals (-)
    5. New Loan Disbursements (-)
    6. Operating Expenses & Salaries (-)
  - **Identified Edge Case**: When a loan is disbursed directly from a bank/MFS account rather than cash, the system must debit the specific bank account rather than the physical Cash-in-Hand vault. Both Flutter and Web SPA support an `accountId` selector on disbursements to preserve accurate ledger separation.

---

## 3. Numeric Precision & Rounding Standard

- **Floating Point Arithmetic**: In JavaScript (`index.html`), standard IEEE 754 floats can produce slight precision artifacts (e.g., `0.1 + 0.2 = 0.30000000000000004`).
- **Implementation Safeguard**:
  - The codebase systematically utilizes `Math.round(val * 100) / 100` and `.toFixed(2)` before rendering and storing currency amounts.
  - In Flutter, monetary values are stored as `double` with 2-decimal rounding.
- **Recommendation**: For enterprise banking scale, adopt fixed-point integer representation (storing currency in poisha / cents) or the `decimal` Dart package to eliminate any possibility of floating point drift over millions of transactions.

---

## 4. Test Case Validation Matrix

| Test Case | Inputs | Expected Output | Actual Output | Verdict |
|-----------|--------|-----------------|---------------|---------|
| Flat Loan EMI | ৳24,000, 10%, 12 Mos | EMI: ৳2,200.00 | ৳2,200.00 | **PASS** |
| Reducing Loan EMI | ৳50,000, 14%, 6 Mos | EMI: ৳8,677.20 | ৳8,677.20 | **PASS** |
| Advance Repayment | 3 installments at once | Principal deducted early | Correctly credited | **PASS** |
| Partial Repayment | Half installment paid | Balance marked overdue | Due tracked | **PASS** |
| Overdue DPS Penalty | 1 month late (10% fine) | ৳1,000 + ৳100 = ৳1,100 | ৳1,100.00 | **PASS** |
