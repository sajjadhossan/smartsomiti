# Super Admin Universal Platform-Wide Permission & Control Center
## Phase 12 Architecture & Enforcement Specification

---

## 1. Universal Control Requirement & Philosophy

In the Multi-Society Cooperative SaaS Platform, the Platform Super Admin / Master Admin possesses centralized, authoritative, and real-time control over every business feature, interface element, administrative capability, and technical operation.

**Core Principles**:
1. **Zero Uncontrolled Features**: No module, button, route, or background job may exist without an authoritative toggle in the Universal Control Center.
2. **Defense-in-Depth**: Interface hiding is purely a UX affordance. True authorization is evaluated and enforced by the backend permission engine and Firestore Security Rules.
3. **Mandatory Security Invariants**: Business controls may be toggled ON or OFF, but essential security invariants (Authentication, Tenant Isolation, Financial Double-Entry Equality, Immutable Audit Trail) **can never be disabled by any user or administrator**.

---

## 2. The 14 Control Scopes Hierarchy

When evaluating whether an actor can perform an operation, the authorization engine evaluates the request across 14 hierarchical scopes:

```
[1. Mandatory Security Invariants] (Immutable: Auth, Tenant Isolation, Accounting Integrity)
       ↓
[2. Global Platform Level] (Master Admin platform-wide kill switch)
       ↓
[3. Environment Level] (Production vs Staging vs Development flags)
       ↓
[4. Society / Tenant Level] (Society-specific active status & settings)
       ↓
[5. Subscription Plan Level] (Starter, Growth, Enterprise feature entitlements)
       ↓
[6. Module Level] (e.g., accounting, loans, field_ops, ai_analytics)
       ↓
[7. Sub-Feature Level] (e.g., loan_rescheduling, ai_fraud_detection)
       ↓
[8. Page / Screen Level] (Route authorization)
       ↓
[9. Navigation / Menu Level] (Sidebar and quick-action visibility)
       ↓
[10. Button / Action Level] (Specific interactive trigger)
       ↓
[11. API / Backend Operation Level] (Cloud Function & endpoint authorization)
       ↓
[12. Role Level] (Super Admin, Society Owner, Admin, Manager, Accountant, Member)
       ↓
[13. Individual User Level] (User-specific custom grants / restrictions)
       ↓
[14. Device / Session Level] (Biometric lock, trusted hardware ID)
```

> **Evaluation Rule**: A lower-level permission grant can **never** override a higher-level denial. If a module is disabled at the Global or Society level, individual user grants have zero effect.

---

## 3. The 21 Platform Control Center Sections

The Universal Control Center contains 21 distinct management sections:

| # | Control Section | Key Capabilities | Default |
| :-: | :--- | :--- | :-: |
| **1** | **Global Module Management** | Universal master switches for each Phase 1–11 module | `ENABLED` |
| **2** | **Society Module Management** | Per-society module enablement & custom society features | `ENABLED` |
| **3** | **Subscription Feature Management** | Tier-based feature gates (Starter, Growth, Enterprise) | `ENFORCED` |
| **4** | **Feature Flag Management** | Dynamic runtime feature flags and beta feature rollout | `ACTIVE` |
| **5** | **Sub-Feature Management** | Granular feature toggles (e.g., loan penalty waiver) | `CONFIGURABLE` |
| **6** | **Universal Permission Registry** | Registry of all 120+ permissions across the platform | `AUTHORITATIVE` |
| **7** | **Role Permission Management** | Role-to-permission mapping with maker-checker checks | `MAPPED` |
| **8** | **Individual User Permission Management** | User-specific permission overrides and audit history | `PER-USER` |
| **9** | **API Permission Management** | Endpoint-level rate limiting and authorization barriers | `GUARDED` |
| **10** | **Button & Action Permissions** | Interactive UI action gating backed by backend checks | `INTEGRATED` |
| **11** | **Navigation Management** | Sidebar, bottom navigation, and quick menu configuration | `ADAPTIVE` |
| **12** | **Dashboard Widget Management** | Widget ordering, role-visibility, and core widget locking | `MANAGED` |
| **13** | **Integration Management** | SSLCOMMERZ, bKash, Nagad, SMS, and Bank API status | `SANDBOX/LIVE` |
| **14** | **Financial Operation Permissions** | High-impact transaction limits, approval thresholds | `STRICT` |
| **15** | **AI Feature Management** | AI assistant, forecasting models, and token quotas | `GUARDED` |
| **16** | **Offline Feature Management** | Mobile sync windows, offline cache retention limits | `SYNC_ENABLED` |
| **17** | **Monitoring Configuration** | Error tracking, P95 alert thresholds, health ping rates | `ACTIVE` |
| **18** | **Backup & Restore Controls** | Backup schedule, PITR drill triggers, manual backups | `AUTOMATED` |
| **19** | **Deployment Permissions** | CI/CD deployment triggers, rollback authorization | `ADMIN_ONLY` |
| **20** | **Security Configuration** | Session timeout, PIN length, failed login lockout | `ENFORCED` |
| **21** | **Global Audit Logs** | Immutable, queryable log of all admin configuration changes | `IMMUTABLE` |

---

## 4. Configuration Persistence & Audit Enforcement

Every state change made in the Universal Control Center records:
1. `settingKey`: Unique string identifier (e.g. `module.ai_analytics.enabled`).
2. `scope`: One of the 14 defined scopes.
3. `targetId`: `platform`, `societyId`, `roleId`, or `userId`.
4. `previousValue`: The exact value before mutation.
5. `newValue`: The updated value.
6. `updatedBy`: User UID of the acting Super Admin.
7. `timestamp`: ISO-8601 UTC timestamp.
8. `auditHash`: HMAC-SHA256 checksum ensuring tamper-proof history.
