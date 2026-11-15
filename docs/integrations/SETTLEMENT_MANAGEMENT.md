# SETTLEMENT_MANAGEMENT.md — Payment Gateway Settlement & Settlement Reports

## 1. Gateway Settlement Cycle
Payment gateway receipts do not instantly arrive in the society bank account:
- bKash: $T+1$ banking day settlement.
- Nagad: $T+1$ banking day settlement.
- SSLCOMMERZ: $T+2$ or $T+3$ banking days settlement.

## 2. Settlement Reconciliation
The system tracks `Pending Settlement` (in transit with gateway) vs `Settled to Bank` (credited to society bank account net of MDR fees).
- MDR Fee (e.g. 1.5% - 2.5%) is debited to `Account 5410 Payment Gateway Processing Fees`.
