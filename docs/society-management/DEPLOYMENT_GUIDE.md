# DEPLOYMENT_GUIDE.md — Phase 6 Production Deployment Guide

## 1. Prerequisites
- Existing Firebase deployment (Firestore, Auth, Storage).
- Phase 1-5 database collections active.

## 2. Deployment Steps
1. **Firestore Rules**: Deploy updated `firestore.rules` containing `/somitis/{somitiId}/...` subcollections.
2. **Storage Rules**: Deploy updated `storage.rules` with MIME and path checks.
3. **Database Seed**: Initialize default departments (Accounts, Field Operations, Admin) and leave categories (CL, SL, EL).
4. **Compile Client Apps**: Web, Android, iOS.
