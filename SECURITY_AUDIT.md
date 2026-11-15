# SECURITY AND VULNERABILITY AUDIT
**Project:** Multi-Society Cooperative Management System ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Scope:** Firestore Security Rules, Storage Rules, Client Trust, RBAC, Secret Exposure, and Cross-Tenant Leaks  
**Auditor:** Principal Security Engineer  
**Date:** 2026-11-14

---

## 1. Executive Summary

A comprehensive security audit of `firestore.rules`, `storage.rules`, JavaScript client code, and Dart models was conducted. 

**Overall Security Verdict: HIGH RISK / ACTION REQUIRED**.  
While strong granular helper functions exist in `firestore.rules`, a critical open wildcard rule overrides tenant isolation, allowing any authenticated user from any society to read and write all documents under the root `/somiti` collection.

---

## 2. Critical Security Findings

### VULNERABILITY-01: Cross-Tenant Data Access via Open Wildcard Rule
- **Severity**: **CRITICAL (CVSS 9.1)**
- **File**: `firestore.rules` (Lines 211-214)
- **Vulnerable Code**:
  ```javascript
  // Temporary compatibility fallback for legacy single-society collections
  match /somiti/{document=**} {
    allow read, write: if isAuthenticated();
  }
  ```
- **Impact**: Any authenticated user (including a standard member from Society A) can read, modify, or delete all records, financial ledgers, member PII, and balances across the entire `/somiti` root database using standard Firestore SDK calls or browser DevTools console.
- **Proof of Concept**:
  ```javascript
  // Any logged-in member can execute:
  db.collection("somiti").doc("main").collection("deposits").add({ amount: 9999999 });
  ```
- **Required Fix**: Remove the open wildcard rule immediately and restrict `/somiti/{document=**}` to `isMasterAdmin()`, or migrate the Web SPA to enforce tenant-scoped rules under `match /somitis/{somitiId}/...`.

---

### VULNERABILITY-02: Hardcoded Master Admin Email in Rules & Source Code
- **Severity**: **MEDIUM (CVSS 5.3)**
- **File**: `firestore.rules` (Lines 27-28), `index.html` (Line 13240)
- **Vulnerable Code**:
  ```javascript
  function isMasterAdmin() {
    return isAuthenticated() && 
      (request.auth.token.email == 'hossansajjad1994@gmail.com' || ...);
  }
  ```
- **Impact**: Master admin identity is coupled to a static string in source code and rules. If the user changes their primary email or requires multiple super admins, rules must be re-deployed.
- **Required Fix**: Utilize Firebase Custom Claims (`request.auth.token.role == 'super_admin'`) or verify against a dedicated Firestore collection `/system_admins/{uid}`.

---

### VULNERABILITY-03: Client-Side Feature Control Bypass
- **Severity**: **HIGH (CVSS 7.4)**
- **File**: `index.html` and `firestore.rules`
- **Mechanism**: The 24-module feature flag switchboard in Master Admin toggles UI visibility via `localStorage.getItem("somiti_feature_flags")` and CSS `display: none`.
- **Finding**: When Master Admin disables a module (e.g., "Loans Module" or "Bank Transfer"), the backend Firestore Security Rules **do not** check whether that module is disabled before allowing write operations.
- **Impact**: A malicious user or rogue Society Owner can still send direct Firestore write payloads to disabled modules.
- **Required Fix**: Add a helper rule in `firestore.rules`:
  ```javascript
  function isModuleEnabled(somitiId, moduleKey) {
    return get(/databases/$(database)/documents/somitis/$(somitiId)/settings/features).data[moduleKey] == true;
  }
  ```

---

### VULNERABILITY-04: Lack of Strict File Type & Size Validation in `storage.rules`
- **Severity**: **MEDIUM (CVSS 4.8)**
- **File**: `storage.rules`
- **Finding**: Storage rules permit write access if user is authenticated without enforcing strict 5MB size limits or MIME-type constraints (`image/jpeg`, `image/png`, `application/pdf`) on receipt uploads.
- **Impact**: Malicious users could upload oversized binary payloads or executable files into the society's Firebase Storage bucket, incurring bandwidth costs.
- **Required Fix**: Add `request.resource.size < 5 * 1024 * 1024 && request.resource.contentType.matches('image/.*|application/pdf')` to storage write conditions.

---

## 3. Secret Exposure Audit

- **Firebase API Keys**: `apiKey: "AIzaSy..."` in `index.html` is a public client identifier by Google Firebase design. It is safe to expose in client source code provided Firestore Security Rules and Firebase App Check are strictly enforced.
- **Service Account Secrets**: No private keys (`service-account.json`, private API tokens, or SMTP passwords) were detected in Git tracking or public source files.
- **`.gitignore` Assessment**: `.gitignore` properly ignores `.env`, `*.jks`, `*.keystore`, and Android build directories.

---

## 4. Security Action Plan (Prioritized)

1. **P0 (Immediate)**: Delete lines 211-214 in `firestore.rules` to eliminate cross-tenant wildcard access.
2. **P1**: Enforce module feature flags inside Firestore security rules to prevent API-level feature flag bypass.
3. **P2**: Implement Firebase Custom User Claims for role authorization instead of email string comparison.
4. **P3**: Add file size and MIME-type restrictions in `storage.rules`.
