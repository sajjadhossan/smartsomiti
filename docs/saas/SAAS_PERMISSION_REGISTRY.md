# SAAS_PERMISSION_REGISTRY.md — Granular RBAC Permissions for SaaS Commercial Engine

## 1. Registered SaaS Permission Keys
Integrated directly into `lib/models/security_compliance_model.dart`:

| Permission Key | Description | Default Roles Allowed |
| :--- | :--- | :--- |
| `saas.plans.view` | View commercial subscription plans and pricing | Super Admin, Society Admin, Auditor |
| `saas.plans.manage` | Create, modify, archive SaaS plans and tier quotas | Super Admin only |
| `saas.subscriptions.view` | View active subscriptions, statuses, and renewal dates | Super Admin, Society Admin |
| `saas.subscriptions.manage`| Upgrade, downgrade, cancel, suspend, or reactivate subscriptions | Super Admin only |
| `saas.invoices.view` | View issued SaaS billing invoices and payment receipts | Super Admin, Society Admin, Cashier |
| `saas.invoices.create` | Manually generate or adjust custom invoices | Super Admin only |
| `saas.payments.verify` | Approve manual bank transfers or reconcile gateway transactions | Super Admin only |
| `saas.discounts.manage` | Create coupons, promotional campaigns, and manual fee waivers | Super Admin only |
| `saas.analytics.view` | View platform-wide SaaS financial metrics (MRR, ARR, Churn, LTV) | Super Admin only |

## 2. Super Admin Switchboard Integration
Any permission can be overridden at the platform level via `GlobalFeatureControl` and per-society via `SocietyFeatureOverride`.
Disabling a permission revokes execution both on the frontend UI and Firestore security rules.
