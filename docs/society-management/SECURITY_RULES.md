# SECURITY_RULES.md — Firestore and Storage Security Rules for Society Operations

## 1. Tenant Isolation
All society operations are organized under `/somitis/{somitiId}/...`. Only users belonging to the specific `somitiId` or the Platform Master Admin can read/write to these collections.

## 2. Storage Rules
Protected under `storage.rules`:
- Files must be under 10MB.
- MIME type must match `image/*` or `application/pdf`.
- Storage path must start with `/somiti_documents/{somitiId}/`.
- Cross-tenant read/write blocked at the storage layer.
