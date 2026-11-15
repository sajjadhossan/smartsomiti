# PAYROLL_MANAGEMENT.md — Enterprise Payroll & Accounting Integration

## 1. Precision Arithmetic & Formula
All payroll calculations are conducted strictly in integer Poisha (1 BDT = 100 Poisha) to avoid floating-point drift:

$$\text{Gross Salary} = \text{Basic} + \text{House Rent} + \text{Medical} + \text{Conveyance} + \text{Festival Bonus} + \text{Overtime}$$

$$\text{Net Salary} = \text{Gross Salary} - (\text{Provident Fund} + \text{Loan Deduction} + \text{Advance Deduction} + \text{Tax})$$

## 2. Double-Entry Accounting Integration
Approved payroll runs automatically generate balanced Journal Entries in Phase 2 General Ledger:
- **Debit**: `Account 5110 Salaries & Allowances Expense` (Total Gross)
- **Credit**: `Account 2150 Provident Fund Payable` (PF Deduction)
- **Credit**: `Account 1145 Staff Salary Advance` (Advance Recovery)
- **Credit**: `Account 2120 Salaries Payable` or `1110 Cash / 1120 Bank` (Net Disbursed)
