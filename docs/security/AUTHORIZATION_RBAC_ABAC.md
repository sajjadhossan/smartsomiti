# PHASE 4: ADVANCED RBAC & ABAC AUTHORIZATION ARCHITECTURE

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Role-Based (RBAC) & Attribute-Based (ABAC) Access Control  

---

## 1. Hybrid RBAC & ABAC Design Pattern

The platform combines standard role presets (RBAC) with contextual attributes (ABAC) for fine-grained authorization.

### Standard Role Presets (RBAC):
1. **Platform Super Admin (`superAdmin`)**:
   - Universal platform sovereignty, cross-society oversight, security switchboard control.
2. **Society Owner / President (`societyOwner`)**:
   - Complete governance over own society, final financial approval, employee management.
3. **Society Admin (`societyAdmin`)**:
   - Operational administration within assigned society.
4. **Manager (`manager`)**:
   - Daily operations, loan verification, expense review, member onboarding.
5. **Accountant / Cashier (`accountant`)**:
   - Cash drawer recording, voucher creation, savings collection, bank reconciliation.
6. **Field Officer (`fieldOfficer`)**:
   - Field deposit collection, loan application submission, member passbook verification.
7. **General Member (`member`)**:
   - Read-only access to own passbook, savings statements, loan schedules.

### Contextual Attributes (ABAC):
- **Tenant Scope (`somitiId`)**: All reads and writes are bounded to the user's active society.
- **Resource Ownership (`ownerUid == auth.uid`)**: Members can only access their personal ledger records.
- **Disbursement Threshold (`amount <= maxApprovalLimit`)**: Restricts individual managers from approving loans above their threshold.
- **Maker-Checker Disqualification (`makerUid != actorUid`)**: Self-approval strictly forbidden.
- **Time/Session Validity (`session.isRevoked == false && session.expiresAt > now`)**: Authorization immediately revoked if session terminated.
