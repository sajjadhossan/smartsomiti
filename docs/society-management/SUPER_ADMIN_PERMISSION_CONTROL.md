# SUPER_ADMIN_PERMISSION_CONTROL.md — Centralized Super Admin Permission Registry for Society Management

## 1. Registered Granular Permissions (Phase 6)
All keys integrated into `lib/models/security_compliance_model.dart`:

| Permission Key | Description | Category |
| :--- | :--- | :--- |
| `crm.leads.view` | View CRM leads and prospects pipeline | CRM |
| `crm.leads.manage` | Create, assign, follow up, and convert leads | CRM |
| `members.lifecycle.manage`| Approve, suspend, reactivate, or resign members | Members |
| `kyc.verification.view` | View submitted KYC identity documents | KYC |
| `kyc.verification.manage` | Approve or reject member KYC submissions | KYC |
| `documents.storage.manage` | Upload, archive, or categorize society documents | Documents |
| `hr.employees.manage` | Manage employee profiles, departments, designations | HR |
| `attendance.records.manage`| Record, correct, and verify staff attendance | HR |
| `leave.requests.manage` | Approve or reject employee leave requests | HR |
| `payroll.processing.manage`| Calculate, review, and disburse monthly payroll | Payroll |
| `inventory.stock.manage` | Inward, outward, adjust, and reconcile stock items | Inventory |
| `assets.register.manage` | Register, assign, maintain, and depreciate assets | Assets |
| `procurement.orders.manage`| Purchase requests, vendor orders, goods receipts | Procurement |
| `operations.tasks.manage` | Assign, prioritize, and track internal tasks | Operations |

## 2. Multi-Tier Resolution
Every permission is evaluated through:
`Mandatory Platform Security -> Super Admin Global Switch -> Society Override -> Subscription Plan Quota -> User Role RBAC`.
