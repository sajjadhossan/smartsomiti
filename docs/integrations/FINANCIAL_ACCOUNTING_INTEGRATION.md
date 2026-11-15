# FINANCIAL_ACCOUNTING_INTEGRATION.md — Phase 2 General Ledger Integration

## 1. Accounting Segregation
- **Platform SaaS Commercial Layer**: Records subscription fees, billing invoices, and SaaS gateway costs (Accounts 4310 / 1150 / 5410).
- **Tenant Society Cooperative Layer**: Records member deposits, loan disbursements, repayments, and bank balances (Accounts 2110 / 1141 / 4110 / 1120).

## 2. Integer Poisha Decimal Safety
All calculations operate in integer Poisha without float roundoff errors. Balanced debits and credits are enforced at the service level before any voucher is finalized.
