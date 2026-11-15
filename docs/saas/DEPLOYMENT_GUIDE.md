# DEPLOYMENT_GUIDE.md — SaaS Subscription & Billing Production Deployment

## 1. Prerequisites
- Firebase project initialized with Firestore, Firebase Auth, and Storage.
- SSLCOMMERZ / bKash / Nagad merchant credentials configured in Firebase Secret Manager:
  - `BKASH_APP_KEY`, `BKASH_APP_SECRET`, `BKASH_USERNAME`, `BKASH_PASSWORD`
  - `SSLCOMMERZ_STORE_ID`, `SSLCOMMERZ_STORE_PASSWD`, `SSLCOMMERZ_IS_SANDBOX`
  - `NAGAD_MERCHANT_ID`, `NAGAD_PUBLIC_KEY`, `NAGAD_PRIVATE_KEY`

## 2. Deployment Steps
1. **Firestore Rules**:
   Deploy updated `firestore.rules` containing read/write guards for `/saas_plans`, `/saas_subscriptions`, `/saas_invoices`, `/saas_payments`, and `/saas_coupons`.
   ```bash
   firebase deploy --only firestore:rules
   ```
2. **Cloud Functions**:
   Deploy webhook listeners and renewal crons:
   ```bash
   firebase deploy --only functions:handleBkashWebhook,functions:handleSslWebhook,functions:dailySubscriptionCron
   ```
3. **Database Seed**:
   Seed default plans (Starter, Standard, Premium, Enterprise) using `SaasSubscriptionService.seedDefaultPlans()`.
4. **Client Rollout**:
   Compile Flutter web and mobile artifacts:
   ```bash
   flutter build web --release
   flutter build apk --release
   ```
