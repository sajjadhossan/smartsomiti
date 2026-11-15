# PHASE_6_ARCHITECTURE.md — Enterprise Society Management Ecosystem Architecture

## 1. System Vision & Scope
Phase 6 expands the Multi-Society Cooperative Platform into a full-scale Enterprise Society Operations Ecosystem. It integrates:
- **CRM & Relationship Management**: Contact and prospective member pipelines with follow-ups.
- **Member Lifecycle Engine**: 8-state transition model from prospect to active, suspended, or archived.
- **Digital KYC & Identity Vault**: Verification workflows for NID, Passport, and Birth Certificates with strict privacy.
- **Enterprise Document Management**: Multi-category, encrypted storage paths, versioning, and download audit logs.
- **HR & Employee Management**: Organizational hierarchy, departments, designations, and onboarding.
- **Attendance & Leave Engine**: Check-in/check-out, correction approvals, and leave balance tracking.
- **Payroll Management**: Precision Integer Poisha money arithmetic, salary structures, deductions, and automatic journal vouchers mapped to the accounting engine.
- **Inventory Management**: Stock movements (opening, receiving, issue, adjustment), low-stock alerts, and concurrency safety.
- **Asset Management**: Fixed asset registry, depreciation tracking, maintenance logs, and disposal.
- **Procurement & Vendor Management**: Vendors, purchase requests, approval workflow integration, purchase orders, and goods receiving.
- **Operations & Task Management**: Internal operational tasks, assignees, deadlines, and escalations.

```mermaid
flowchart TD
    SA["👑 Platform Super Admin Control Center"] --> MG["Module Gates & Feature Switchboard"]
    MG --> CRM["CRM & Member Lifecycle"]
    MG --> KYC["KYC & Identity Vault"]
    MG --> DOCS["Document Management"]
    MG --> HR["HR, Attendance & Leave"]
    MG --> PAYROLL["Payroll Engine (Integer Poisha)"]
    MG --> INV["Inventory & Stock Movements"]
    MG --> ASSETS["Fixed Asset Registry"]
    MG --> PROC["Procurement & Vendor Mgmt"]
    
    PAYROLL --> GL["Phase 2 Double-Entry Accounting Engine"]
    PROC --> WF["Phase 3 Multi-Level Approval Engine"]
    KYC --> SEC["Phase 4 Security & Compliance Vault"]
    MG --> SAAS["Phase 5 SaaS Entitlement Engine"]
```

## 2. Universal Super Admin Control Center
Every single module, sub-feature, action button, toggle, and CRUD operation has a registered permission key. Super Admin has real-time ON/OFF switchboard overrides both platform-wide and per individual cooperative society.
