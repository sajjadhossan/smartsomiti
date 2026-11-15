# PAYMENT_SECURITY.md — SaaS Subscription Payment Security & Anti-Fraud Architecture

## 1. Security Overview
All financial transactions for SaaS platform subscriptions (bKash, Nagad, SSLCOMMERZ, Bank Wire) must adhere to bank-grade security and zero-trust verification rules.

## 2. Core Security Invariants
1. **Never Trust Client Status**: No client app can declare a subscription "paid". Only trusted Cloud Functions or verified backend webhooks can transition status from `pending_payment` to `active`.
2. **Idempotency Keys**: Every payment verification request must include a deterministic UUID/HMAC idempotency key (`societyId + invoiceNumber + transactionId`). Duplicate execution attempts return cached outcomes without re-crediting or duplicate ledger posting.
3. **Webhook Signature Verification**:
   - bKash: Query payment status via tokenized server-to-server API `executePayment`.
   - Nagad: Verify public-key signature `X-KM-Signature` with Nagad Public Certificate.
   - SSLCOMMERZ: Mandatory IPN server-to-server hash validation (`val_id` verification call before order confirmation).
4. **Amount & Currency Validation**:
   - Backend compares received payment `amountInPoisha` against `invoice.totalInPoisha`.
   - Even 1 Poisha discrepancy flags the transaction as `underpaid` or `overpaid_audit_required`.
   - Enforce currency ISO code `BDT` strictly.
5. **Double Payment & Replay Protection**:
   - Transaction reference (`trxID`) is uniquely indexed in Firestore collection `/saas_payments`.
   - Any reuse of a historical `trxID` aborts immediately with security alert level `ALERT_HIGH`.
