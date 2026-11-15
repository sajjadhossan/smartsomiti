# SUPER_ADMIN_PERMISSION_CONTROL.md — Centralized Super Admin Control Center for Payments & Banking

## 1. Registered Granular Permissions (Phase 7)
Integrated directly into `lib/models/security_compliance_model.dart`:

| Permission Key | Description | Category |
| :--- | :--- | :--- |
| `payments.gateway.manage` | Activate, deactivate, configure bKash, Nagad, SSLCOMMERZ | Gateways |
| `payments.transactions.view` | View real-time transactions, attempts, and receipts | Payments |
| `payments.transactions.verify`| Approve or manually reconcile incoming payments | Payments |
| `payments.refund.manage` | Request, review, and execute transaction refunds | Payments |
| `banking.accounts.manage` | Add, modify, or archive society bank accounts | Banking |
| `banking.reconcile.manage` | Upload bank statements and execute 3-way reconciliation | Banking |
| `qr.payments.manage` | Generate dynamic Bangla QR and configure static passbook QR | QR Payments |
| `collections.field.manage` | Assign field officers, routes, and verify field cash collections | Collections |
| `settlements.gateway.manage` | View, verify, and reconcile gateway settlement reports | Settlements |

## 2. Universal Control Hierarchy
`Platform Security Boundary -> Super Admin Switchboard -> Society Override -> Subscription Plan Feature Gate -> User Role RBAC`.
