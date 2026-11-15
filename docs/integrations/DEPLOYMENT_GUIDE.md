# DEPLOYMENT_GUIDE.md — Payment Gateway & Banking Production Deployment

## 1. Secret Manager Configuration
Configure the following secrets in Google Cloud Secret Manager:
- `BKASH_APP_KEY`, `BKASH_APP_SECRET`, `BKASH_USERNAME`, `BKASH_PASSWORD`
- `NAGAD_MERCHANT_ID`, `NAGAD_PUBLIC_KEY`, `NAGAD_PRIVATE_KEY`
- `SSLCOMMERZ_STORE_ID`, `SSLCOMMERZ_STORE_PASSWORD`, `SSLCOMMERZ_IS_SANDBOX`

## 2. Deployment Steps
1. **Firestore Rules**: Deploy updated `firestore.rules` for payment collections.
2. **Cloud Functions**: Deploy payment listeners, webhook handlers, and reconciliation crons.
3. **Database Seed**: Seed default payment gateways and bank account types.
4. **Compile Client Apps**: Web, Android, iOS.
