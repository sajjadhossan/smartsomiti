# DOCUMENT_MANAGEMENT.md — Enterprise Document Management System (EDMS)

## 1. Document Categories
- `member_kyc`: Member identity cards, photographs, specimen signature cards.
- `loans_guarantor`: Loan application forms, stamp deeds, guarantor collateral documents.
- `society_legal`: Cooperative bylaws, registration certificates, AGM/EGM resolutions.
- `hr_payroll`: Employment contracts, appointment letters, salary slips.
- `procurement_assets`: Vendor invoices, purchase orders, asset warranty cards.

## 2. Storage Architecture & Multi-Tenant Paths
All files are strictly organized inside society tenant isolation folders:
`somiti_documents/{societyId}/{category}/{documentId}_{filename}`

## 3. Metadata & Access Control
- Every document upload records: `uploadedBy`, `societyId`, `fileSize`, `mimeType`, `sha256Checksum`, and `tags`.
- Every download event produces a read-audit entry in `document_access_logs`.
