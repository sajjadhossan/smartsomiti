# STRATEGIC IMPLEMENTATION PLAN
**Project:** Smart Somiti Cooperative Society Management Platform  
**Target:** Production-Grade Multi-Society Enterprise Architecture  
**Execution Environment:** Google Antigravity  

---

## 1. Architectural Blueprint & Data Flow

The enhanced platform establishes strict multi-tenant isolation, database-driven feature gating, and double-entry financial integrity.

```
+---------------------------------------------------------------------------------+
|                        MASTER ADMIN CONTROL CENTER                             |
|  - Global Feature Registry       - Society Enablement Matrix                    |
|  - System Health & Audit Logs    - Global Module / Sub-Feature Switches         |
+---------------------------------------------------------------------------------+
                                       |
                                       v
+---------------------------------------------------------------------------------+
|                    HIERARCHICAL FEATURE GATING ENGINE                           |
|  Level 1: Global Flag   --> Level 2: Society Flag  --> Level 3: Role Permission |
|  Level 4: User Override --> Level 5: Security Lock                              |
+---------------------------------------------------------------------------------+
                                       |
           +---------------------------+---------------------------+
           |                                                       |
           v                                                       v
+-------------------------------------+ +-------------------------------------+
|       SOCIETY A (Full Banking)      | |      SOCIETY B (Savings Only)       |
| - Savings Products (Daily/Monthly)  | | - Savings Products                  |
| - Loan Applications & Amortization  | | - Loan Module: DISABLED [Hidden]    |
| - Cashbook & Bank Accounts          | | - Cashbook Only                     |
| - Role: Admin, Accountant, Member   | | - Role: Owner, Collector, Member    |
+-------------------------------------+ +-------------------------------------+
```

---

## 2. Phased Implementation Roadmap

### Phase 1: Schema Design, Security Rules & Feature Flag System
- [ ] **1.1 Firestore Schema Expansion:**
  - Define root collections: `societies`, `users`, `society_memberships`, `feature_definitions`, `platform_feature_settings`, `society_feature_settings`, `audit_logs`.
  - Define society sub-collections: `members`, `savings_products`, `savings_accounts`, `savings_transactions`, `loans`, `loan_installments`, `financial_accounts`, `expenses`, `income`, `notices`.
- [ ] **1.2 Server-Side Security Rules (`firestore.rules`):**
  - Implement tenant verification functions: `isSocietyMember(societyId)`, `isSocietyAdmin(societyId)`, `isPlatformMasterAdmin()`.
  - Enforce immutable financial write restrictions (prevent modifying approved historical records).
- [ ] **1.3 Dynamic Feature Flag Service:**
  - Build `FeatureManagementService` supporting dynamic hierarchy evaluation:
    $$\text{canAccess(featureKey, societyId, userRole, userId)}$$
  - Add offline-first memory caching with instant invalidation upon real-time snapshot updates.

---

### Phase 2: Master Admin Control Center & RBAC
- [ ] **2.1 Master Admin Dashboard & Navigation:**
  - Global overview metrics: Total societies, Active subscriptions, Platform transaction volume.
  - Society lifecycle management: Provision, Activate, Deactivate, Archive.
- [ ] **2.2 Hierarchical Feature Management UI:**
  - Master toggles across 24 modules and granular sub-features (Daily/Weekly savings, Flat/Reducing loans, Cashbook, Export formats).
  - Society-specific feature override matrix (e.g., enable Loans for Society A while disabling for Society B).
- [ ] **2.3 Granular RBAC Engine:**
  - 7 standard roles: `Platform Super Admin`, `Society Owner`, `Society Admin`, `Manager`, `Accountant`, `Field Officer`, `General Member`.
  - Permission matrix editor with capability delegation (Owners manage their staff permissions within limits granted by Master Admin).

---

### Phase 3: Loan Management & Financial Accounting Engine
- [ ] **3.1 Loan Management Module:**
  - Loan Application workflow: Draft -> Submitted -> Reviewed -> Approved / Rejected -> Disbursed.
  - Configurable Interest Calculation Engine:
    - **Flat Rate Method:** $I = P \times R \times T$
    - **Reducing Balance (EMI) Method:** $E = \frac{P \times r \times (1+r)^n}{(1+r)^n - 1}$
  - Amortization schedule generator with breakdown of Principal vs. Interest per installment.
  - Partial repayments, Advance repayments, and overdue penalty calculations.
- [ ] **3.2 Enterprise Financial Accounting:**
  - Standardized precision arithmetic using integer minor currency units (cents/paisa).
  - Multi-account tracking: Main Cash Drawer, Bank Accounts, Mobile Financial Services (bKash/Nagad).
  - Automated Double-Entry Ledger and Cashbook reconciliation.
  - Comprehensive P&L and Balance Sheet generation.

---

### Phase 4: Flutter Architecture Refactoring & UI Harmonization
- [x] **4.1 Modular Domain Architecture:**
  - Refactored monolithic `lib/main.dart` into clean feature directories:
    ```
    lib/
      ├── core/          (theme: app_theme.dart, constants: app_colors.dart)
      ├── features/
      │   ├── admin/     (master_admin_screen.dart)
      │   ├── auth/      (login_screen.dart, pending_approval_screen.dart)
      │   ├── society/   (onboarding_screen.dart, somiti_list_screen.dart, create_somiti_screen.dart)
      │   ├── loans/     (loan_management_screen.dart)
      │   ├── accounting/ (accounting_screen.dart)
      │   ├── reports/   (financial_reports_screen.dart)
      │   └── dashboard/ (somiti_main_dashboard.dart)
      └── services/      (Auth, Somiti, Drive, Feature flags, Loan, Accounting, Reporting)
    ```
- [x] **4.2 Responsive Design & Theme System:**
  - Standardized `AppTheme` and `AppColors` for Material 3 light/dark mode support.
  - Slimmed `lib/main.dart` from 2,386 lines down to 85 lines with verified syntax across 33 Dart files.

---

### Phase 5: Cross-Platform Configurations, FCM & Automated Testing
- [ ] **5.1 iOS Project Scaffolding:**
  - Generate complete `ios/` bundle (`Runner.xcodeproj`, `Info.plist`, Podfile) with Google Sign-in URL schemes.
- [ ] **5.2 Push Notifications (FCM):**
  - Integrate `firebase_messaging` for transaction alerts, installment due reminders, and society announcements.
- [ ] **5.3 Test Suite (`test/`):**
  - Unit tests for interest calculations (Flat & Reducing balance accuracy).
  - Unit tests for Feature Gating precedence hierarchy.
  - Widget tests for role-based navigation guards.
  - Integration verification across Android, Web, and CI pipeline.

---

## 3. Immediate Action Items for Phase 1 Start

Upon user confirmation to proceed:
1. Initialize `firestore.rules` and `storage.rules` in root.
2. Create `lib/models/feature_flag_model.dart` and `lib/models/loan_model.dart`.
3. Construct the Master Admin Control Center foundation in `lib/features/admin/`.
