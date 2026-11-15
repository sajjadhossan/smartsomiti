# PHASE 4: SESSION, DEVICE & ACCESS MANAGEMENT SPECIFICATION

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Real-Time Active Session Registry, Device Tracking & Token Revocation  

---

## 1. Active Session Architecture
Every authentication event creates an authoritative session document in `/security_sessions/{sessionId}` with:
- `sessionId`: Unique cryptographically secure UUID (`sess_202611_...`).
- `userId`: The authenticated user's Firebase UID.
- `userEmail`: Associated email address.
- `societyId`: Currently active tenant ID.
- `deviceName`: Human-readable device descriptor (e.g., "Samsung Galaxy S24 (Android 15)", "Chrome 131 on Windows 11").
- `ipAddress`: Redacted / hashed IP for privacy compliance.
- `loginAt`: Timestamp of session initiation.
- `lastActiveAt`: Timestamp of most recent API/Firestore call.
- `expiresAt`: Calculated session expiry timestamp.
- `isRevoked`: Boolean flag for immediate real-time termination.
- `revokedBy`: UID of administrator who revoked the session.
- `revocationReason`: Stated reason for audit trail.

---

## 2. Instant Session Revocation Workflow
1. Super Admin or Society Admin views the **Active Sessions & Device Manager** in the Security Dashboard.
2. Admin clicks **"Revoke Session"** or **"Force Logout All Devices"**.
3. Target session document is updated with `isRevoked = true` and `revokedAt = serverTimestamp()`.
4. The client's in-memory session listener receives the document snapshot and immediately:
   - Flushes local credentials and cached authentication tokens.
   - Redirects user to the login screen with the alert: `"Your session was terminated by an administrator for security purposes."`
   - Rejects any in-flight background network operations.
