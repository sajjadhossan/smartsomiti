# PHASE 9 DEPLOYMENT & FIELD READINESS GUIDE

## 1. Prerequisites
- Firebase CLI installed.
- Firestore Security Rules updated with `/offline_sync_queue`, `/device_registry`, `/cash_reconciliations`, and `/collection_routes`.
- Android `AndroidManifest.xml` permissions:
  - `android.permission.ACCESS_FINE_LOCATION`
  - `android.permission.ACCESS_COARSE_LOCATION`
  - `android.permission.CAMERA`
  - `android.permission.ACCESS_NETWORK_STATE`
- iOS `Info.plist`:
  - `NSCameraUsageDescription`
  - `NSLocationWhenInUseUsageDescription`

## 2. Firestore Deployment
Deploy the updated security rules ensuring field sync operations are tenant-isolated:
```bash
firebase deploy --only firestore:rules
```

## 3. Field Device Provisioning Checklist
1. Install mobile APK / iOS build on cooperative fleet tablet.
2. Log in with officer credentials.
3. Submit device registration request.
4. Society Admin or Super Admin approves device in Dashboard.
5. Set 4-digit Offline PIN for local database encryption.
6. Run initial full sync on branch Wi-Fi before route departure.
