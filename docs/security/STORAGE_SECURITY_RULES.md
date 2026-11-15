# PHASE 4: STORAGE & CLOUD FUNCTIONS SECURITY SPECIFICATION

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Storage Security Rules & Serverless Execution Security  

---

## 1. Storage Rules Blueprint (`storage.rules`)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isValidImageOrPdf() {
      return request.resource.contentType.matches('image/(jpeg|png|webp)') ||
             request.resource.contentType == 'application/pdf';
    }
    
    function isUnderMaxSize() {
      return request.resource.size <= 5 * 1024 * 1024; // 5 MB Limit
    }

    // Tenant-isolated Member Documents (KYC, Photos, NID)
    match /somitis/{somitiId}/members/{memberId}/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isValidImageOrPdf() && isUnderMaxSize();
    }

    // Society Letterhead & Branding
    match /somitis/{somitiId}/branding/{fileName} {
      allow read: if true; // Publicly accessible for member receipt verification
      allow write: if isAuthenticated() && isValidImageOrPdf() && isUnderMaxSize();
    }

    // Financial Vouchers & Audit Receipts
    match /somitis/{somitiId}/vouchers/{fileName} {
      allow read: if isAuthenticated();
      allow write: if isAuthenticated() && isValidImageOrPdf() && isUnderMaxSize();
    }
  }
}
```

---

## 2. Cloud Functions Invariants
- Functions must run on Node.js 20 runtime with least-privilege IAM service account.
- Must reject any mutation containing non-whitelisted parameters.
- Idempotent execution via Firestore transaction write deduplication.
