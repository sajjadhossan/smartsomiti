# DATABASE AND DATA MODEL AUDIT
**Project:** Multi-Society Cooperative Management System ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Scope:** Firestore Schemas, Multi-Tenant Partitioning, Indexes, and Integrity Constraints  
**Auditor:** Database Architect  
**Date:** 2026-11-14

---

## 1. Executive Summary

The database architecture is built on Cloud Firestore NoSQL document storage. The schema design models multi-tenant isolation through subcollection hierarchies in the Flutter implementation, alongside legacy flat documents in the Web Single Page Application.

Overall Database Evaluation: **PARTIAL (Sound Subcollection Schema with Indexing and Normalization Needs)**.

---

## 2. Multi-Tenant Schema Design

### Canonical Flutter Subcollection Schema (`somitis/{somitiId}/...`):

```
/somitis (collection)
  └── {somitiId} (document: name, regNo, status, subscription, createdBy, createdAt)
        ├── /members (subcollection: name, phone, nid, status, joinDate, shareCount)
        ├── /savings_accounts (subcollection: memberId, accountType, balance, monthlyDps)
        ├── /savings_transactions (subcollection: accountId, amount, type, date, cashierId)
        ├── /loans (subcollection: memberId, principal, interestRate, totalPayable, outstandingBalance)
        ├── /loan_installments (subcollection: loanId, installmentNo, dueDate, amount, status)
        ├── /expenses (subcollection: category, amount, description, approvedBy, date)
        ├── /cashbook (subcollection: type, amount, balanceAfter, voucherNo, date)
        ├── /employees (subcollection: name, designation, salary, joinDate)
        └── /settings (subcollection: featureFlags, smsConfig, currency)
```

### Web SPA Current Schema (`somiti/main/...`):
- `somiti/main/members`
- `somiti/main/deposits`
- `somiti/main/expenses`
- `somiti/main/loans`

---

## 3. Data Integrity & Normalization Audit

1. **Member - Account Association**:
   - Every savings and loan account explicitly stores `memberId` and denormalized `memberName` for fast query performance.
   - Foreign key integrity is maintained programmatically by repositories before write actions.
2. **Denormalization Trade-offs**:
   - `memberName` and `phone` are replicated inside transaction records. This minimizes read costs (1 read per transaction display instead of 2).
   - If a member updates their phone number, historical transaction records retain the original phone number at time of transaction (correct for financial audit trails).
3. **Soft-Delete vs Hard-Delete**:
   - Member deletions in `lib/core/models/member_model.dart` and `index.html` set `status: 'inactive'` or `isDeleted: true`.
   - Financial ledger entries are strictly immutable (no delete button exists in cashbook or deposits).

---

## 4. Indexing & Query Performance

Firestore requires composite indexes for complex queries containing multiple equality and inequality/sorting filters.

### Required Composite Indexes:
1. `somitis/{somitiId}/savings_transactions`:
   - `accountId` (ASC) + `date` (DESC)
   - `type` (ASC) + `date` (DESC)
2. `somitis/{somitiId}/loan_installments`:
   - `loanId` (ASC) + `status` (ASC) + `dueDate` (ASC)
3. `somitis/{somitiId}/members`:
   - `status` (ASC) + `joinDate` (DESC)
4. `somitis/{somitiId}/cashbook`:
   - `date` (DESC) + `type` (ASC)

*Status*: Single-field indexes are active by default in Firestore. Composite index file (`firestore.indexes.json`) should be checked into repository for automated Firebase CLI deployment.

---

## 5. Scalability & Quota Analysis

- **Document Size Limit**: Maximum Firestore document size is 1 MiB. None of the document schemas store unbounded arrays (e.g., installments are stored as individual documents in a subcollection, not an array within the loan document).
- **Write Rate Limit**: Single document write limit is 1 write/second. Society-level aggregated counters (`totalSavingsBalance`) use distributed counters or transactional updates, preventing document lock contention.
- **Tenant Isolation**: By scoping each society's records inside `/somitis/{somitiId}`, read operations for one society never scan documents belonging to another society.

---

## 6. Database Defect Findings

| ID | Issue | Risk | Remedy |
|----|-------|------|--------|
| DB-01 | Web SPA references `somiti/main` instead of dynamic `somitiId` | Multi-tenancy collision if multiple societies connect to Web SPA | Inject dynamic `currentSomitiId` into Web SPA query roots |
| DB-02 | `firestore.indexes.json` missing from project root | Manual index creation needed in Firebase Console | Create `firestore.indexes.json` with required composite indexes |
| DB-03 | Some auxiliary tables stored in browser `localStorage` in Web SPA | Loss of local data if browser cache cleared | Migrate `localStorage` persistence fully to Firestore collections |
