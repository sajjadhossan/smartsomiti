# DATABASE_SCHEMA.md — Phase 6 Firestore Collections & Index Schemas

## 1. Multi-Tenant Collections (Sub-collections under `/somitis/{somitiId}/`)
- `crm_leads`: `leadId`, `fullName`, `phone`, `email`, `status`, `assignedTo`, `notes`, `createdAt`.
- `kyc_records`: `kycId`, `memberId`, `docType`, `docNumberMasked`, `frontUrl`, `backUrl`, `status`, `verifiedBy`.
- `society_documents`: `docId`, `category`, `title`, `storagePath`, `fileSize`, `mimeType`, `uploadedBy`.
- `hr_employees`: `employeeId`, `fullName`, `designation`, `department`, `salaryStructure`, `status`.
- `attendance_records`: `recordId`, `employeeId`, `date`, `checkIn`, `checkOut`, `status`.
- `leave_applications`: `leaveId`, `employeeId`, `leaveType`, `startDate`, `endDate`, `status`, `approvedBy`.
- `payroll_runs`: `runId`, `periodMonth`, `totalGrossPoisha`, `totalDeductionsPoisha`, `totalNetPoisha`, `status`, `voucherId`.
- `inventory_items`: `itemId`, `name`, `sku`, `category`, `currentStock`, `reorderLevel`, `unitCostPoisha`.
- `inventory_movements`: `movementId`, `itemId`, `movementType`, `quantity`, `actorId`, `timestamp`.
- `asset_register`: `assetId`, `name`, `tag`, `category`, `purchaseDate`, `costPoisha`, `assignedEmployeeId`, `status`.
- `vendors`: `vendorId`, `name`, `contactPerson`, `phone`, `email`, `rating`.
- `purchase_requests`: `requestId`, `vendorId`, `items`, `totalEstimatedPoisha`, `status`, `approvedBy`.
- `operations_tasks`: `taskId`, `title`, `assignedTo`, `priority`, `dueDate`, `status`.
