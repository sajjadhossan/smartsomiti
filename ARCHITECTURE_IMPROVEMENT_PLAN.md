# TECHNICAL MODERNIZATION & ARCHITECTURE IMPROVEMENT PLAN
**Project:** Multi-Society Cooperative Management System ("স্বপ্ন ছোঁয়া ঐক্য সমিতি" / `cloud_sync_drive`)  
**Role:** Principal Software Architect & Enterprise SaaS Engineering Lead  
**Date:** 2026-11-14

---

## 1. Principles of Technical Modernization

1. **Preserve What Works**: The current Flutter Clean Architecture and Web SPA are functional, responsive, and well-structured. We modernize iteratively without destructive rewrites.
2. **Zero Bloat Policy**: Every added package or dependency must justify its existence with measurable business or engineering returns.
3. **Enterprise Robustness**: Design for 100,000+ concurrent members, 1,000+ societies, and sub-second query response times across Bangladesh mobile networks.

---

## 2. Layer-by-Layer Architectural Modernization

### A. Flutter Architecture & State Management
- **Current State**: Mix of `StatefulWidget` states, `ValueNotifier`, and direct service calls.
- **Modernization Plan**:
  - Adopt a strict **Repository Pattern with Cached Reactive Streams**:
    `UI Widget` $\longleftrightarrow$ `ChangeNotifier / Cubit` $\longleftrightarrow$ `Repository` $\longleftrightarrow$ `Firestore Data Source`.
  - Maintain offline-first cached state using `hydrated_bloc` or Flutter's native `ValueNotifier` with persistent local disk storage.
  - Keep widgets stateless and compact (< 250 lines per widget file) with separated UI component design.

---

### B. Firebase Backend Architecture
- **Current State**: Client-driven Firestore reads/writes with basic security rules; absence of a backend compute layer.
- **Modernization Plan**:
  - Introduce **Firebase Cloud Functions (2nd Gen / Node.js 20)**:
    1. **Scheduled Workers (Cloud Scheduler)**: Midnight ledger reconciliation and 10th-of-month DPS overdue penalty processing.
    2. **Event-Driven Database Triggers**: Automatically update society aggregated counters (`totalMembers`, `vaultBalance`, `loanOutstanding`) upon transaction creation.
    3. **Callable Functions**: Secure operations requiring elevated privileges (Custom claims assignment, batch salary disbursement).

---

### C. Database Architecture & Multi-Tenant Scaling
- **Subcollection Tenant Partitioning**:
  All society-scoped data strictly resides under `/somitis/{somitiId}/...`.
- **Distributed Counters for Vault Balances**:
  - High-frequency write collections (like daily deposits) can cause write contention on a single society summary document.
  - Implement a **Distributed Sharded Counter** (10 shards per society) for tracking `totalDeposits` and `currentCashInHand`, aggregated every 60 seconds.
- **Index Management**:
  - Deploy `firestore.indexes.json` via CI/CD to eliminate manual Firebase Console index configuration.

---

### D. Financial Transaction Integrity
- **ACID Atomicity Enforcement**:
  - Every financial transaction modifying two or more records (e.g., Deposit = +Member Balance AND +Cash Drawer) **MUST** execute inside `FirebaseFirestore.instance.runTransaction`.
  - Transaction payloads contain a unique `idempotencyKey` (UUIDv4) to prevent duplicate charges caused by accidental double-clicks or mobile network retries.
- **Fixed-Point Financial Math**:
  - Store all monetary values as integer Poisha (৳1.00 = 100 Poisha) to avoid floating point IEEE 754 precision artifacts.

---

### E. Security & Zero-Trust Governance
- **Cryptographic Custom Claims**:
  - Mint signed JWT tokens containing:
    `{ "role": "society_owner", "somitiId": "SMT-001", "permissions": ["loans_write", "cash_read"] }`.
- **Server-Side Module Enforcement**:
  - Rules inspect whether a module is enabled before allowing writes.
- **Storage Protection**:
  - Strict MIME-type checking (`image/jpeg`, `image/png`, `application/pdf`) and size ceiling (< 5MB) on uploads.

---

### F. Performance & Bandwidth Optimization
- **Pagination**: Implement cursor-based pagination (`startAfterDocument`) with a 20-item page size for member registries and transaction ledgers.
- **Asset Compression**:
  - Member photos downsampled client-side to maximum 800x800 resolution before upload, reducing file sizes from 4MB to < 150KB.
- **Query Projection**: Use Firestore `select()` projections to fetch only necessary fields for summary tables.

---

### G. Automated Testing Strategy
- **Unit Tests**:
  - Comprehensive unit testing for financial formulas (Amortization, late fees, DPS dividend splits).
- **Security Rule Tests**:
  - Run `@firebase/rules-unit-testing` against the local Firebase Emulator Suite to verify tenant isolation and role privilege boundaries.
- **Widget & Smoke Tests**:
  - Automated Flutter driver tests verifying user login, member creation, and receipt export flows.

---

### H. Monitoring, Observability & Error Tracking
- **Firebase Crashlytics**: Real-time stack traces for native Android/iOS crashes.
- **Firebase Performance Monitoring**: Automatic network latency tracking on Firestore reads/writes.
- **Audit Log Invariance**: Security events (login failures, permission changes, manual balance adjustments) logged to an immutable `/audit_logs` collection.

---

### I. CI/CD & Automated Release Pipeline
- **GitHub Actions Workflows**:
  - **PR Workflow**: Runs `flutter analyze`, static syntax checks, unit tests, and security rule validations.
  - **Release Workflow**: Builds signed Android App Bundle (AAB), Web PWA bundle, and deploys security rules & Cloud Functions automatically upon merging to `main`.
