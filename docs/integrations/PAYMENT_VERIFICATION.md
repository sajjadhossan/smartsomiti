# PAYMENT_VERIFICATION.md — Automated Verification & State Machine Engine

## 1. Authoritative 12-State Payment Lifecycle
`CREATED` -> `INITIATED` -> `PENDING` -> `PROCESSING` -> `SUCCESS` -> `FAILED` -> `CANCELLED` -> `EXPIRED` -> `REFUND_PENDING` -> `PARTIALLY_REFUNDED` -> `REFUNDED` -> `DISPUTED`.

## 2. Server-Authoritative Transition Rules
- Only trusted backend webhooks or authorized administrative verification calls can transition a state to `SUCCESS`.
- The received amount in Poisha must strictly match the invoice or collection requirement.
- Underpayments or overpayments are flagged as `DISPUTED` for manual audit.
