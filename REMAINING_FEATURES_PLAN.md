# REMAINING FEATURES IMPLEMENTATION PLAN
**Project:** Multi-Society Cooperative Management System ("স্বপ্ন ছোঁয়া ঐক্য সমিতি" / `cloud_sync_drive`)  
**Role:** Principal Software Architect & Enterprise SaaS Engineering Lead  
**Date:** 2026-11-14  
**Status:** Architecture Specification & Engineering Plan (Pre-Implementation)

---

## 1. Identification & Evidence of the Exact 4 Remaining Features

Based on the forensic audit of the Flutter codebase (`lib/`), Web SPA (`index.html`), Firestore rules (`firestore.rules`), and Firebase configuration:

```
┌────┬─────────────────────────────────────────────────┬───────────┬──────────┬──────────┬──────────┬──────────────┐
│ #  │ Remaining Modernization Feature                 │ Frontend  │ Backend  │ Database │ Security │ Integration  │
├────┼─────────────────────────────────────────────────┼───────────┼──────────┼──────────┼──────────┼──────────────┤
│ 1  │ Automated Cloud Functions & Scheduled Cron Jobs │ PARTIAL   │ MISSING  │ PARTIAL  │ PARTIAL  │ NOT DEPLOYED │
│ 2  │ True Background Push Notifications (FCM Engine) │ PARTIAL   │ MISSING  │ PASS     │ PASS     │ NOT DEPLOYED │
│ 3  │ PWA Offline Service Worker & Asset Caching      │ PARTIAL   │ N/A      │ PASS     │ PASS     │ MISSING      │
│ 4  │ Cryptographic RBAC via Firebase Custom Claims   │ PASS      │ MISSING  │ PASS     │ PARTIAL  │ MISSING      │
└────┴─────────────────────────────────────────────────┴───────────┴──────────┴──────────┴──────────┴──────────────┘
```

---

## 2. Feature 1: Automated Cloud Functions & Scheduled Financial Operations

### A. Current Status & Evidence
- **Frontend**: In `view-reports` and `view-deposits`, late fines are calculated client-side in UI tables. There is no automated background process applying overdue penalties to member accounts.
- **Backend**: `functions/` directory is missing from the project root. No server-side Node.js or Python Cloud Functions exist to execute cron schedules.
- **Database**: Subcollections `/somitis/{somitiId}/savings_accounts` exist, but no automated penalty transaction documents are created.
- **Security**: Client-side execution of interest or penalties introduces tampering risk if a malicious client modifies the calculation script.

### B. Business Value
- Eliminates manual penalty entry by cashier or manager.
- Ensures strict compliance with cooperative bylaws (e.g., ৳50 fixed fine or 5% penalty applied automatically on the 10th of every calendar month at 23:59 BST).
- Guaranteed ledger consistency across all societies on the platform.

### C. Technical Implementation Plan
- **Backend Directory**: Create `functions/` with Node.js 20 runtime and Firebase Functions SDK v5.x.
- **Cloud Function 1: `scheduledMonthlyDpsPenalty`**:
  - Cron syntax: `59 23 10 * *` (Runs on the 10th of every month at 23:59 Asia/Dhaka time).
  - Iterates over active societies where `features.savings_management == true`.
  - Queries active DPS accounts with unpaid installments for the current month.
  - Generates immutable penalty transaction under `/somitis/{somitiId}/savings_transactions`.
- **Cloud Function 2: `nightlyLedgerReconciliation`**:
  - Cron syntax: `0 0 * * *` (Midnight reconciliation).
  - Verifies $\sum \text{Transactions} == \text{Current Vault Balance}$ and flags discrepancies in audit logs.
- **Database Changes**: Add `lastAutomatedFineAt: Timestamp` to `savings_accounts`.
- **Master Admin Switchboard**: Module toggle `automated_late_fine` (Module 22) enables/disables the job per society.
- **Complexity**: Medium (3 developer days).

---

## 3. Feature 2: True Background Push Notification Dispatch Engine

### A. Current Status & Evidence
- **Frontend**: `lib/services/notification_service.dart` handles local device token capture. Web UI has `view-notifications` rendering in-app alerts.
- **Backend**: No server-side HTTP or Cloud Firestore triggers exist to invoke FCM (`admin.messaging().sendMulticast()`) when the app is closed.
- **Database**: `device_tokens` collection modeled, but orphaned without a push dispatcher.
- **Security**: Push tokens must be guarded against cross-tenant exposure.

### B. Business Value
- Instant SMS/Push alerts to members when a savings deposit or loan payment is recorded.
- Immediate fraud prevention: members receive real-time receipts on their Android/iOS devices even when the app is terminated.
- Critical broadcast circulars sent by Society President reach all members instantly.

### C. Technical Implementation Plan
- **Cloud Function: `onNotificationCreated`**:
  - Firestore trigger on `somitis/{somitiId}/notifications/{notifId}`.
  - Fetches target member's device tokens from `somitis/{somitiId}/members/{memberId}/device_tokens`.
  - Dispatches FCM payload with localized Bengali title, body, and deep-link route (`view-deposits` or `view-loans`).
- **Master Admin Switchboard**: Tied to `notifications_module` (Module 16) and `sms_notifications` (Module 14).
- **Complexity**: Low-Medium (2 developer days).

---

## 4. Feature 3: PWA Offline Service Worker & Offline-First Field Sync

### A. Current Status & Evidence
- **Frontend**: Single-page web application (`index.html`) loads smoothly online via Cloudflare tunnel, but has no `sw.js` (Service Worker) registered.
- **Offline Behavior**: If an internet outage occurs in rural field collection zones, reloading `index.html` fails with `ERR_INTERNET_DISCONNECTED`.
- **Database**: Firestore offline cache persistence works, but HTML/CSS/JS web assets are not cached by the browser cache API.

### B. Business Value
- Field officers collecting daily/weekly installments in remote Bangladeshi villages can operate continuously without cellular connectivity.
- App loads instantly (< 300ms) from local cache regardless of network latency.

### C. Technical Implementation Plan
- **Service Worker File (`sw.js`)**:
  - Cache-first strategy for static assets: fonts, CSS, images, and HTML shell.
  - Network-first strategy for real-time Firebase Auth and Firestore endpoints.
  - Background Sync API: Queues offline deposit receipts and syncs automatically upon network reconnection.
- **Web App Manifest (`manifest.json`)**:
  - Full PWA metadata, standalone display mode, Bengali app name ("স্বপ্ন ছোঁয়া ঐক্য সমিতি"), green brand icons.
- **Complexity**: Low (1 developer day).

---

## 5. Feature 4: Cryptographic Role Enforcement via Firebase Custom Claims

### A. Current Status & Evidence
- **Frontend**: Role evaluation uses local document reads and fallback email comparisons (`isPlatformMasterAdmin`).
- **Backend**: Firestore rules check `exists(...)` or hardcoded emails (`hossansajjad1994@gmail.com`).
- **Limitation**: `exists()` rule evaluations consume 1 additional Firestore read per request, increasing latency and billing.
- **Security**: Email-based checks are rigid; custom claims embed signed roles directly inside the JWT token (`auth.token.role`).

### B. Business Value
- Military-grade cryptographic verification: User roles (`master_admin`, `society_owner`, `accountant`, `member`) cannot be spoofed.
- 30% reduction in Firestore security rules evaluation latency (zero extra document reads).

### C. Technical Implementation Plan
- **Cloud Function: `setRoleCustomClaims`**:
  - Triggered when Master Admin or Society Owner assigns a role.
  - Invokes `admin.auth().setCustomUserClaims(uid, { role: roleName, somitiId: somitiId })`.
  - Client calls `user.getIdToken(true)` to refresh signed token immediately.
- **Firestore Rules Update**:
  - Replace `isPlatformMasterAdmin()` with `request.auth.token.role == 'super_admin'`.
  - Replace `isSocietyAdmin(somitiId)` with `request.auth.token.somitiId == somitiId && request.auth.token.role in ['owner', 'admin']`.
- **Complexity**: Low-Medium (1.5 developer days).
