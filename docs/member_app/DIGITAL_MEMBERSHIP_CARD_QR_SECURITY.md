# Digital Membership Card & QR Identification Security

## 1. Overview & Threat Model

The **Digital Membership Card** provides verified society members with an instant, tamper-evident digital credential displayed on their smartphone screen. It incorporates dynamic QR code verification for branch entry, annual general meeting (AGM) attendance, loan installment collections, and emergency identity verification.

### Threat Scenarios Mitigated
1. **Screen Capture / Clone Attacks**: Static QR codes can be screenshotted and shared with unauthorized persons.
2. **Data Scraping via QR**: Embedding plaintext NIDs, financial balances, or phone numbers in QR codes exposes sensitive data to third-party QR scanners.
3. **Cross-Tenant Replay Attacks**: An authentic QR code generated for Society A presented to verify entry at Society B.
4. **Revoked Member Impersonation**: Suspended or expelled members attempting to use older physical cards or offline screenshots.

---

## 2. Dynamic HMAC-SHA256 Signed QR Token Design

The QR code payload is an encrypted/signed compact JSON Web Token (JWT) or HMAC payload formatted as:

```json
{
  "cid": "CARD-SOMITI001-MEM101",
  "sid": "SOMITI-001",
  "mid": "MEM-101",
  "iat": 1731639600,
  "exp": 1731643200,
  "sig": "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
}
```

### Signature Computation
$$\text{Signature} = \text{HMAC-SHA256}(\text{Key}_{\text{society}}, \text{"cid"}\parallel\text{"sid"}\parallel\text{"mid"}\parallel\text{"iat"}\parallel\text{"exp"})$$

- **Zero Sensitive Data in QR**: The QR code contains **no financial balance**, **no NID number**, and **no phone number**.
- **Server-Side Authorization upon Scan**: When scanned by an authorized field officer or branch cashier, the scanner app sends the token to `/api/v1/member/verify-card`. The backend validates the signature, checks expiration (`now() < exp`), checks revocation status in Firestore, and returns only the authorized details (Name, Photo, Member Number, Active Status) to the scanner.
- **Auto-Rotation**: The dynamic QR token rotates automatically every 15 minutes while online.

---

## 3. Card Visual Layout & Anti-Counterfeiting Elements

The digital card features:
1. **Official Society Branding**: Society Laurel logo, full organization name, registration number, and curved Bengali slogan.
2. **Member Credentials**: High-resolution photo, full member name, member ID badge (e.g. `MEM-101`), and membership date.
3. **Interactive Security Hologram Effect**: CSS animated micro-sheen gradient that renders smoothly on mobile and web to indicate an active screen rather than a static screenshot.
4. **Real-time Status Pill**: `🟢 সক্রিয় সদস্য (Active Member)` with digital stamp of authenticity.
5. **Instant Revocation Check**: If Super Admin or Society Admin suspends the member, the digital card status instantly updates to `🔴 সদস্যপদ স্থগিত (Suspended)` and QR token validation will return `CARD_REVOKED`.
