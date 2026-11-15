# SSLCOMMERZ_INTEGRATION.md — SSLCOMMERZ Hosted Payment Gateway Integration

## 1. Flow Overview
1. Client initiates checkout -> Server calls `POST /gwprocess/v4/api.php` with `store_id`, `store_passwd`, `total_amount`, `currency=BDT`, `tran_id`.
2. Gateway returns `GatewayPageURL` -> User completes payment via card, MFS, or internet banking.
3. User redirected to `success_url` / `fail_url`.
4. **Mandatory Backend Validation**: Server receives IPN (Instant Payment Notification) and queries `validator/api/validationserverAPI.php?val_id={VAL_ID}&store_id={STORE_ID}&store_passwd={PASSWD}`.
5. If `status == 'VALID' || status == 'VALIDATED'`, verify exact amount in Poisha and post to General Ledger.
