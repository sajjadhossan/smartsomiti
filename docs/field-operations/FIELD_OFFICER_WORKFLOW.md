# FIELD OFFICER WORKFLOW & MOBILE OPERATIONS SPECIFICATION

## 1. Field Operations Lifecycle
The field officer's daily routine follows a standardized 4-stage operational lifecycle:

```mermaid
graph LR
    Morning[1. Morning Branch Departure] --> Field[2. Field Route & Door-to-Door Collection]
    Field --> Evening[3. Return to Branch & Cash Submission]
    Evening --> Reconciliation[4. Cashier Verification & JV Posting]
```

### Stage 1: Morning Branch Departure (Online)
- Officer logs in at branch Wi-Fi.
- Synchronizes assigned daily collection list and approved member balances.
- Branch Cashier approves opening float/cash change if needed.

### Stage 2: Field Route Operations (Offline/Intermittent)
- Navigates collection route via GPS target points.
- Door-to-door visit: scans member QR passbook or selects member name.
- Accepts cash for savings deposit, installment repayment, or admission fee.
- Enters amount, confirms with member, generates provisional receipt (`PROV-REC-XXXX`).
- Saves operation in persistent local sync queue.

### Stage 3: Return to Branch & Cash Handover (Online)
- Connects device to branch network.
- Synchronization engine uploads all pending operations.
- Officer counts physical cash collected and presents cash reconciliation report to branch cashier.

### Stage 4: Cashier Maker-Checker Finalization
- Cashier counts physical currency, verifies against synchronized batch.
- Cashier approves batch; system posts double-entry journal (`Account 1110 Cash Dr, Account 2110 / 1141 Cr`).
- Member receives confirmation SMS and final digital receipt status.
