# ENTERPRISE FINANCIAL ANALYTICS & KPI SPECIFICATION

## 1. Accounting Invariant & Integrity Rules
The financial analytics engine sources all data directly from the **Phase 2 Double-Entry General Ledger**. It never calculates financial metrics from raw client-submitted deposit forms or unverified invoices.

### Core Invariants:
1. **Member Savings Deposits are Liabilities**:
   $$\text{Total Savings Deposits} = \sum \text{Credit Balances}(\text{Account 2110} + \text{Account 2120})$$
   Savings deposits are never counted as operating revenue.
2. **Loan Principal Receivables vs. Interest Revenue**:
   $$\text{Loan Principal Outstanding} = \sum \text{Debit Balances}(\text{Account 1141})$$
   $$\text{Interest Earned} = \sum \text{Credit Balances}(\text{Account 4110})$$
   Principal repayments reduce Asset Account 1141; only the markup/service fee is credited to Income Account 4110.
3. **Net Operating Surplus / Deficit**:
   $$\text{Net Operating Surplus} = \sum \text{Revenues (4000)} - \sum \text{Operational Expenses (5000)}$$
4. **Liquidity Ratio**:
   $$\text{Liquidity Ratio} = \frac{\text{Cash in Hand (1110)} + \text{Bank Balances (1121/1122)}}{\text{Demand Savings Liabilities (2110)}} \times 100\%$$
   The benchmark requirement is $\ge 15\%$ for cooperative solvency safety.

## 2. Standard Financial Dashboards & Aggregation Frequencies
- **Daily Cash Position Snapshot**: Cash in drawer, bank deposits, daily loan disbursements, daily installments collected.
- **Monthly Comprehensive P&L**: Operational surplus, staff salaries (Account 5210), office rent (Account 5310), MFS gateway processing fees (Account 5120).
- **Quarterly Balance Sheet Analysis**: Total Assets = Total Liabilities + Member Equity (Account 3110 + 3210 Reserve Fund).
