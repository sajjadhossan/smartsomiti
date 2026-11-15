# BANK_INTEGRATION.md — Commercial Bank Integration & Account Governance

## 1. Supported Account Types
- Society Operational Current Accounts (e.g. City Bank PLC, BRAC Bank, Dutch-Bangla Bank).
- Special Savings Deposit Accounts (SND) with interest capitalization.
- Dedicated Loan Disbursement and Recovery Collection Accounts.

## 2. Bank Record Schema
- `bankName`: Official bank name and branch routing number.
- `accountNumberMasked`: Displayed with leading masking (e.g. `******8921`).
- `linkedGlAccountId`: Direct link to General Ledger (e.g. `1120 City Bank PLC A/C #1102`).
- `signatories`: Authorized executive committee members with maker-checker controls.
