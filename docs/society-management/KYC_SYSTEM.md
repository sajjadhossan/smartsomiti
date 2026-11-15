# KYC_SYSTEM.md — Digital KYC & Identity Verification System

## 1. Supported Document Types
- **NID (National Identity Card)**: Smart NID (10 digits) or Old NID (13/17 digits).
- **Passport**: Machine Readable Passport (MRP) or E-Passport.
- **Birth Certificate**: Online verified 17-digit birth registration number.
- **Trade License / Cooperative Registration**: For institutional members.

## 2. Verification Workflow
1. `NOT_SUBMITTED`: Profile created, documents awaiting upload.
2. `SUBMITTED`: Front and back images uploaded to secure Firebase Storage.
3. `UNDER_REVIEW`: Assigned to Field Inspector / Verification Officer.
4. `APPROVED`: Verified against Bangladesh National Database / manual audit.
5. `REJECTED`: Rejected with specific reason (e.g., blurry image, name mismatch).
6. `RESUBMITTED`: Revised document submitted by member.

## 3. Privacy & Anti-Leakage Guards
- Full NID numbers are never logged in plain text or notifications (masked as `*****1234`).
- Storage URLs are tokenized and protected under `storage.rules`. No public read access.
