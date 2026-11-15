# BANK_RECONCILIATION.md — Statement Import & Automated 3-Way Reconciliation

## 1. Import Pipeline
Supports bank statement upload in CSV and Excel (`.xlsx`) formats:
1. File uploaded to secure temporary storage.
2. Parsed for: `TxnDate`, `Description / ChequeNo`, `DebitAmount`, `CreditAmount`, `Balance`.
3. Validated against internal General Ledger (`Account 1120 Bank Accounts`).

## 2. Match Classification
- **Matched (100% Exact)**: Cheque number / TrxID and amount match internal journal entry.
- **Probable Match**: Same amount and date within ±2 days; requires cashier confirmation.
- **Unmatched Exception**: Bank charges, direct customer deposits, or dishonored cheques. Requires formal adjustment voucher approval.
