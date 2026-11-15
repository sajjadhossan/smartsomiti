# ENTERPRISE FINANCIAL REPORTING ENGINE
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 2 — Advanced Double-Entry Financial Engine  
**Date:** 2026-11-14

---

## 1. Principles of Financial Reporting

1. **Zero Hardcoded Figures**: Every single figure displayed on the Balance Sheet, Profit & Loss, Trial Balance, or Cash Flow Statement is derived strictly from verified, posted entries in the General Ledger.
2. **Mathematical Invariant Verification**: Reports calculate both sides independently and display an audit validation badge:
   - Trial Balance: `Total Debits == Total Credits` ($\Delta = 0$).
   - Balance Sheet: `Assets == Liabilities + Equity` ($\Delta = 0$).
3. **Regulatory Separation**:
   - Member savings deposits are strictly categorized under **Liabilities**, never as Revenue.
   - Loan principal recovery reduces **Assets (Loans Receivable)**, never categorized as Interest Income.

---

## 2. Report Specifications & Mathematical Formulas

### A. Trial Balance (রেওয়ামিল)
- **Purpose**: Verifies the mathematical accuracy of the double-entry posting engine for any selected date range.
- **Formula**:
  $$\sum \text{Debit Balances} = \sum \text{Credit Balances}$$
- **Data Structure**:
  ```dart
  class TrialBalanceReport {
    final DateTime asOfDate;
    final List<TrialBalanceLine> lines;
    final int totalDebitInPoisha;
    final int totalCreditInPoisha;
    final int differenceInPoisha; // Must be 0
    final bool isBalanced;        // difference == 0
  }
  ```

---

### B. Balance Sheet (আর্থিক উদ্বৃত্তপত্র)
- **Purpose**: Displays the complete financial position of the cooperative society as of a specific date.
- **Equation**:
  $$\text{TOTAL ASSETS} = \text{TOTAL LIABILITIES} + \text{TOTAL EQUITY}$$
- **Structure**:
  1. **ASSETS (মোট পরিসম্পদ)**:
     - Cash in Hand (`1110`)
     - Bank Balances (`1120`)
     - MFS Wallets (`1130`)
     - Loan Principal Outstanding (`1140`)
     - Fixed Assets net of Depreciation (`1200` - `1290`)
  2. **LIABILITIES (মোট দায়)**:
     - Member General Savings Deposits (`2110`)
     - Member DPS Savings Deposits (`2120`)
     - Accrued Expenses & Payables (`2200`)
  3. **EQUITY & RESERVES (মালিকানা স্বত্ব ও রিজার্ভ)**:
     - Member Paid-up Share Capital (`3110`)
     - Statutory Reserve Fund (`3210`)
     - Cooperative Development Fund (`3220`)
     - Retained Net Surplus from Current & Prior Periods (`3300`)

---

### C. Profit & Loss Statement (লাভ-ক্ষতি ও পরিচালন উদ্বৃত্ত বিবরণী)
- **Purpose**: Computes net operational surplus or deficit for a defined period (Monthly, Quarterly, Annual).
- **Equation**:
  $$\text{NET SURPLUS} = \text{OPERATIONAL REVENUE} - \text{OPERATIONAL EXPENSES}$$
- **Breakdown**:
  - **OPERATIONAL REVENUE (+)**:
    - Loan Interest Income (`4110`)
    - Loan Processing Fees (`4120`)
    - Overdue Late Penalties (`4130`, `4140`)
    - Member Admission & Passbook Fees (`4210`, `4220`)
  - **OPERATIONAL EXPENSES (-)**:
    - Staff Salaries & Commission (`5210`, `5220`)
    - Office Rent & Utilities (`5310`, `5320`)
    - Printing, Stationery & Supplies (`5330`)
    - Cloud, Software & SMS Gateway Fees (`5350`)
    - Bank & Transaction Charges (`5120`)
    - Asset Depreciation (`5380`)

---

### D. Cash Flow Statement (নগদ প্রবাহ বিবরণী)
- **Categories**:
  1. **Cash Flow from Operating Activities**:
     - Loan interest collected (+)
     - Penalties and fees received (+)
     - Office rent, salaries, utilities paid (-)
  2. **Cash Flow from Investing Activities**:
     - Loan principal disbursed to members (-)
     - Loan principal recovered from members (+)
     - Purchase of office equipment/vault (-)
  3. **Cash Flow from Financing Activities**:
     - Member savings deposits collected (+)
     - Member savings withdrawals paid (-)
     - Share capital issued (+)
  4. **Net Cash Reconciliation**:
     $$\text{Closing Cash} = \text{Opening Cash} + \text{Net Operating} + \text{Net Investing} + \text{Net Financing}$$
     *(Matches physical Cash in Hand + Bank + MFS accounts exactly).*
