# PHASE 4: FIRESTORE, STORAGE & CLOUD FUNCTIONS SECURITY HARDENING

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Hardened Firestore Rules, Storage Rules, and Cloud Functions Identity Verification  

---

## 1. Hardened Firestore Rules Architecture
- **Rules Version 2**: Tenant isolation strictly verified through hierarchical path matching `/somitis/{somitiId}/...`.
- **Protected Security Collections**:
  - `/security_permissions/{id}`: Read by authenticated users; Write strictly restricted to `isPlatformMasterAdmin()`.
  - `/security_policies/{id}`: Read by authenticated users; Write restricted to `isPlatformMasterAdmin()`.
  - `/security_sessions/{id}`: Read/Write by session owner or Master Admin; updates to `isRevoked` restricted to Admins.
  - `/security_alerts/{id}`: Read by Admins; Create by authenticated system; Update/Delete strictly forbidden (`allow update, delete: if false`).
  - `/security_audit_logs/{id}`: Append-only (`allow update, delete: if false`).

---

## 2. Hardened Firebase Storage Rules
- Storage bucket scoped under:
  `/somitis/{somitiId}/members/{memberId}/{allPaths=**}`
  `/somitis/{somitiId}/receipts/{allPaths=**}`
  `/somitis/{somitiId}/branding/{allPaths=**}`
- **Security Constraints**:
  - Max file size $\le 5\text{MB}$.
  - Allowed content types: `image/jpeg`, `image/png`, `image/webp`, `application/pdf`.
  - Unauthenticated access completely denied (`request.auth != null`).
  - Cross-tenant file access blocked.

---

## 3. Cloud Functions Identity Verification
- All serverless functions must verify:
  1. `context.auth != null`.
  2. Idempotency key present in header to prevent duplicate disbursement or transfer.
  3. Server-side validation of requester role before committing financial state changes.
