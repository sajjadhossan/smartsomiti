# LOCAL DATABASE DESIGN & OFFLINE SCHEMAS

## 1. Storage Schema Design
The offline storage engine maintains structured tables/stores for low-overhead querying:

### 1. `offline_members_cache`:
- `memberId` (PK, String)
- `societyId` (String)
- `assignedOfficerId` (String)
- `fullName` (String)
- `phone` (String)
- `savingsBalancePoisha` (Integer)
- `activeLoanAccount` (String?)
- `installmentDuePoisha` (Integer)
- `lastSyncedAt` (DateTime)

### 2. `offline_sync_queue`:
- `operationId` (PK, String)
- `societyId` (String)
- `userId` (String)
- `operationType` (String)
- `payloadJson` (Text)
- `status` (String: `PENDING`, `SYNCED`, `FAILED`, `CONFLICT`, `REQUIRES_REVIEW`)
- `retryCount` (Integer)
- `createdAt` (DateTime)
- `syncedAt` (DateTime?)

### 3. `offline_provisional_receipts`:
- `receiptNumber` (PK, String)
- `operationId` (String)
- `memberId` (String)
- `amountPoisha` (Integer)
- `purpose` (String)
- `printedAt` (DateTime)
- `isServerConfirmed` (Boolean, default: false)
