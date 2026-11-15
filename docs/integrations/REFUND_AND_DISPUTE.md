# REFUND_AND_DISPUTE.md — Refund, Reversal & Dispute Management

## 1. Zero Silent Deletion Invariant
Refunds or transaction cancellations **never delete** the original transaction record. An explicit linked refund voucher is generated:
- Original Transaction Status: `REFUNDED` or `PARTIALLY_REFUNDED`.
- Linked Reversal Journal Entry: Reverses initial debit/credit allocations.

## 2. Maker-Checker Approval
Refund requests require Phase 3 Workflow Engine approval. Cashiers or collectors cannot self-approve refunds.
