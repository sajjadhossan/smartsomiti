# MAKER-CHECKER SECURITY & CONFLICT-OF-INTEREST GOVERNANCE
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 3 — Enterprise Approval & Workflow Automation Engine  
**Standards:** Basel Committee Operational Risk Standards, Bank-Grade Segregation of Duties  
**Date:** 2026-11-14

---

## 1. Principles of Maker-Checker Architecture

1. **Mandatory Segregation of Duties (SoD)**:
   The operator who drafts or originates a financial request (the **Maker**) is cryptographically and logically prohibited from approving, authorizing, or disbursing that same request (the **Checker**).
2. **Zero Client Trust**:
   Self-approval rejection is enforced at the backend service layer and inside Firestore Security Rules. Hiding an "Approve" button on the UI is not sufficient; direct API submissions from the maker are rejected.
3. **Conflict-of-Interest Detection**:
   If an approver is a guarantor on a loan application, or shares the same mobile/NID as the applicant, the workflow automatically flags a conflict and routes the request to an alternative authorized reviewer.

---

## 2. Technical Enforcement Mechanism

```dart
Future<void> approveStage({
  required String somitiId,
  required String requestId,
  required String actorUid,
  required String actorRole,
  required String comment,
}) async {
  final reqDoc = await _requestsRef(somitiId).doc(requestId).get();
  if (!reqDoc.exists) throw WorkflowException("আবেদনটি পাওয়া যায়নি");

  final request = ApprovalRequestModel.fromSnapshot(reqDoc);

  // 1. Strict Maker-Checker Invariant
  if (request.makerUid == actorUid) {
    throw WorkflowSecurityException(
      "নিরাপত্তা লঙ্ঘন: আপনি নিজের তৈরি করা আবেদন নিজেই অনুমোদন করতে পারবেন না! (Maker cannot approve self-originated request)"
    );
  }

  // 2. Role Privilege Verification
  if (!isRoleAuthorizedForStage(actorRole, request.currentStage.assignedRole)) {
    throw WorkflowSecurityException("অননুমোদিত পদবি: এই স্তরে অনুমোদনের ক্ষমতা আপনার নেই!");
  }

  // 3. Delegation Guard
  if (isDelegatedAction) {
    verifyDelegationValidity(somitiId, actorUid, request.currentStage.assignedRole);
  }

  // Execute stage approval atomically...
}
```

---

## 3. Delegation Security Protocol

1. **Delegation Scope Ceiling**:
   A Society Owner or Manager may delegate approval authority to a deputy while on leave. However, the delegated authority can **NEVER** exceed the original grantor's permissions.
2. **Strict Time-Bound Expiration**:
   Delegations require explicit `startDate` and `endDate`. Once `DateTime.now() > delegation.endDate`, any approval attempt by the delegate fails with `DELEGATION_EXPIRED`.
3. **Audit Provenance**:
   When an approval is executed by a delegate, the audit log records:
   - `actorUid`: The actual physical user who clicked approve.
   - `actingOnBehalfOfUid`: The original grantor.
   - `delegationId`: Reference to the active delegation document.

---

## 4. Immutable Approval Audit Trail

Every workflow action records an unalterable audit log entry:
- `action`: `SUBMIT`, `STAGE_APPROVED`, `FINAL_APPROVED`, `REJECTED`, `CORRECTION_REQUESTED`, `RESUBMITTED`, `ESCALATED`, `DELEGATED`.
- `requestId`, `moduleKey`, `amountInPoisha`.
- `actorUid`, `actorName`, `actorRole`.
- `comment` / `reasonNote`.
- `timestamp`, `ipAddress`, `userAgent`.
