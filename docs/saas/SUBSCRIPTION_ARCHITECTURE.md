# PHASE 5: ENTERPRISE SaaS SUBSCRIPTION ARCHITECTURE & SPECIFICATION

**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি" / `cloud_sync_drive`)  
**Architecture Domain:** Commercial Management, Multi-Tenant Subscription & Billing Engine  
**Version:** 5.0.0-enterprise-saas  
**Date:** 2026-11-14  

---

## 1. High-Level Commercial Architecture

```mermaid
flowchart TD
    subgraph "Platform Super Admin Governance"
        Admin[Master Admin Commercial Switchboard] --> PlanMgr[Subscription Plan Manager]
        Admin --> EntitleMgr[Dynamic Entitlements Engine]
        Admin --> RevAnalytics[MRR & Revenue Analytics Engine]
    end

    subgraph "Multi-Tenant Society Subscriptions"
        SocietyA[Society A: Basic Plan]
        SocietyB[Society B: Standard Plan]
        SocietyC[Society C: Enterprise Plan]
    end

    PlanMgr -->|Plan Entitlements| EntitleMgr
    EntitleMgr -->|Scoped Access| SocietyA
    EntitleMgr -->|Scoped Access| SocietyB
    EntitleMgr -->|Scoped Access| SocietyC

    subgraph "Commercial Billing & Invoicing Engine"
        BillingEngine[Automated Billing Scheduler (Asia/Dhaka)] --> InvGen[Invoice Generator (INV-202611-XXXXX)]
        InvGen --> PaymentRouter[Payment Gateway Router]
        PaymentRouter -->|Online PGW| MFS[bKash / Nagad / SSLCOMMERZ]
        PaymentRouter -->|Offline / Manual| Bank[Bank Transfer & Verification]
        MFS -->|Server Webhook & Verification| CallbackHandler[Idempotent Verification Worker]
        Bank -->|Admin Checker Verification| CallbackHandler
    end

    CallbackHandler -->|Update Status & Extends Expiry| SubLifecycle[Subscription Lifecycle FSM]
    SubLifecycle --> SocietyA
    SubLifecycle --> SocietyB
    SubLifecycle --> SocietyC

    CallbackHandler -->|Separate Ledger Entry| SaaSAccounts[Platform Commercial Revenue Ledger (COA 4310)]
```

---

## 2. Core Architectural Pillars

1. **Strict Accounting Separation**:
   - **Platform SaaS Commercial Revenue**: Recorded in dedicated platform chart of accounts (Account `4310: SaaS Subscription Revenue`, `1150: Commercial Accounts Receivable`, `5410: Payment Gateway Commission Fees`).
   - **Society Cooperative Funds**: Society member savings (Account `2110`), loan principal (Account `1141`), and cash drawer (`1110`) are **strictly isolated** and 100% immune from subscription billing mutations.
2. **Integer Minor Unit Currency Arithmetic**:
   - All monetary amounts are computed and persisted in integer Poisha (1 BDT = 100 Poisha) to prevent IEEE-754 binary floating-point drift.
3. **Bangladeshi Localization & Operations**:
   - Default business timezone: `Asia/Dhaka` (UTC+6).
   - Default legal currency: Bangladeshi Taka (`BDT`, `৳`).
   - Payment channels: bKash Merchant API, Nagad Gateway, City Bank PLC corporate accounts, and SSLCOMMERZ.
4. **Absolute Super Admin Sovereignty**:
   - The Platform Super Admin governs plan tiers, trial policies, coupons, grace periods, and payment gateways without needing source code redeployments.
