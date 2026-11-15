# SECURITY.md — Payment Security, Tokenization & Anti-Fraud Architecture

## 1. Zero Secrets in Client Applications
- Flutter mobile and web code contains zero provider API keys, secrets, or certificates.
- All outbound requests to bKash, Nagad, and SSLCOMMERZ are executed via secure server-to-server Cloud Functions with credentials stored in Google Cloud Secret Manager.

## 2. Idempotency & Replay Defense
- Each payment request requires a deterministic idempotency key (`societyId + transactionRef + invoiceNumber`).
- Replayed webhooks or duplicate user clicks immediately return cached state without triggering multiple ledger transactions.

## 3. Webhook Authentication
- SSLCOMMERZ IPN: Validated via server-side `validator/api/validationserverAPI.php`.
- Nagad Webhook: Asymmetric RSA-2048 public key signature validation (`X-KM-Signature`).
- bKash Webhook: Server-to-server `queryPayment` API re-verification.
