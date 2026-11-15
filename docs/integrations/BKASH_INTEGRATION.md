# BKASH_INTEGRATION.md — bKash Tokenized Merchant API Integration

## 1. Credentials & Environments
- **Sandbox**: `https://tokenized.sandbox.bka.sh/v1.2.0-beta`
- **Production**: `https://tokenized.pay.bka.sh/v1.2.0-beta`
- **Secrets Managed via Secret Manager**: `app_key`, `app_secret`, `username`, `password`. Never in client app!

## 2. Tokenized API Lifecycle
1. `grantToken`: Generates `id_token` valid for 3600 seconds.
2. `createPayment`: Generates `paymentID` and returns `bkashURL` for webview/checkout.
3. `executePayment`: Backend executes payment server-to-server.
4. `queryPayment`: Re-queries `trxID` in case of network drops or timeout.
5. `refundPayment`: Initiates full or partial refund using original `paymentID` and `trxID`.
