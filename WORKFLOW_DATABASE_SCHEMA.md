# ENTERPRISE WORKFLOW ENGINE DATABASE SCHEMA
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 3 — Enterprise Approval & Workflow Automation Engine  
**Standards:** Multi-Tenant Isolation, Audit Immutability, Normalized Workflow Graph  
**Date:** 2026-11-14

---

## 1. Multi-Tenant Collection Partitioning

All workflow definitions, active approval instances, delegations, and audit trails reside under the tenant's scoped root: `/somitis/{somitiId}/...`.

```
/somitis/{somitiId}
  ├── /workflow_definitions      (Templates & configured workflow rules per module)
  ├── /approval_requests         (Active & historical approval instances)
  │     └── /stage_history       (Audit log of each individual stage review)
  ├── /approval_delegations      (Temporary delegations with start/end dates)
  ├── /escalation_rules          (SLA deadlines & automatic escalation policies)
  └── /workflow_audit_logs       (Immutable tamper-proof audit events)
```

---

## 2. Collection Schema Specifications

### A. `/somitis/{somitiId}/workflow_definitions/{workflowId}`
Represents a configurable approval workflow template (e.g., "Multi-Tier Micro-Loan Approval Workflow").

| Field Name | Type | Description |
|------------|------|-------------|
| `id` | String | Document ID (e.g., `wf_loan_standard`) |
| `somitiId` | String | Parent Society Identifier |
| `name` | String | Workflow Name (e.g., "সাধারণ ঋণ অনুমোদন কর্মপ্রবাহ") |
| `moduleKey` | String | Module Key (`loan_approval`, `expense_approval`, `savings_withdrawal`) |
| `description` | String | Detailed description of criteria and purpose |
| `triggerEvent` | String | Event triggering this workflow (`loan_application_submitted`) |
| `minAmount` | Number | Minimum monetary threshold in Poisha (or 0 for all) |
| `maxAmount` | Number | Maximum monetary threshold in Poisha (or -1 for unlimited) |
| `stages` | Array<Map> | Ordered list of `ApprovalStageDefinition` |
| `isActive` | Boolean | True if currently enabled for society |
| `enforceMakerChecker` | Boolean | If true, creator cannot approve any stage |
| `allowDelegation` | Boolean | If true, approvers can delegate authority |
| `escalationHours` | Number | Hours before automatic escalation triggers |
| `createdBy` | String | Creator UID |
| `updatedAt` | Timestamp | Last modified timestamp |

---

### B. `/somitis/{somitiId}/approval_requests/{requestId}`
Represents an active or resolved approval request transaction.

| Field Name | Type | Description |
|------------|------|-------------|
| `id` | String | Request Document ID (e.g., `REQ-202611-00045`) |
| `somitiId` | String | Society ID |
| `workflowId` | String | ID of parent workflow definition |
| `moduleKey` | String | Module Key (`loan_approval`, `expense`, etc.) |
| `sourceDocumentId` | String | ID of related entity (`loanAppId`, `expenseId`) |
| `title` | String | Brief title (e.g., "রহিম উদ্দিন - ৫০,০০০ টাকা ঋণ আবেদন") |
| `amountInPoisha` | Number | Monetary amount involved (in Poisha) |
| `makerUid` | String | User who created the request |
| `makerName` | String | Display name of the maker |
| `currentStageIndex`| Number | 0-indexed pointer to active stage in workflow |
| `currentStageName` | String | Active stage name (e.g., "ম্যানেজার যাচাইকরণ") |
| `assignedRole` | String | Role authorized to approve active stage |
| `assignedUserUids` | Array<String> | Specific user UIDs assigned (if applicable) |
| `status` | String | 13-state enum (`DRAFT`, `SUBMITTED`, `PENDING_REVIEW`, `APPROVED`, etc.) |
| `stageHistory` | Array<Map> | Cumulative audit trail of all completed stages |
| `createdAt` | Timestamp | Submission timestamp |
| `updatedAt` | Timestamp | Last state transition timestamp |
| `completedAt` | Timestamp | Final approval or rejection timestamp |

---

### C. Stage History Record Format (Embedded Map)

```json
{
  "stageIndex": 1,
  "stageName": "ম্যানেজার সুপারিশ ও যাচাই",
  "assignedRole": "manager",
  "action": "APPROVED",
  "actorUid": "user_mgr_102",
  "actorName": "মোঃ শাহীন আলম (ম্যানেজার)",
  "comment": "সদস্যের পূর্ববর্তী সঞ্চয় নিয়মিত। ঋণ মঞ্জুর করার সুপারিশ করা হলো।",
  "timestamp": "2026-11-14T12:00:00Z",
  "ipAddress": "103.145.12.8"
}
```

---

### D. `/somitis/{somitiId}/approval_delegations/{delegationId}`

| Field Name | Type | Description |
|------------|------|-------------|
| `id` | String | Delegation ID |
| `somitiId` | String | Society ID |
| `ownerUid` | String | Original approver UID granting delegation |
| `delegateUid` | String | Appointed delegate user UID |
| `delegateName` | String | Appointed delegate display name |
| `scopeModule` | String | Module key or `ALL` |
| `startDate` | Timestamp | Effective start date |
| `endDate` | Timestamp | Automatic expiration date |
| `isActive` | Boolean | Manual active switch |
| `reason` | String | Justification (e.g., "বার্ষিক ছুটি") |

---

## 3. Indexing & Query Architecture

### Required Composite Indexes:
1. `approval_requests`:
   - `status` (ASC) + `assignedRole` (ASC) + `createdAt` (DESC)
   - `makerUid` (ASC) + `createdAt` (DESC)
   - `moduleKey` (ASC) + `status` (ASC) + `createdAt` (DESC)
2. `approval_delegations`:
   - `delegateUid` (ASC) + `isActive` (ASC) + `endDate` (DESC)
