# Database Migration & Production Data Protection Guide
## Phase 12 Enterprise Standards

---

## 1. Zero-Downtime Migration Principles

In multi-tenant financial applications, database schema migrations must never disrupt active accounting periods or risk data loss.

### The 4 Non-Negotiable Rules:
1. **Never In-Place Destructive Migrations**: Columns/fields are never removed or renamed in-place. A phase-transition pattern is employed: Add new field → Dual-write → Backfill historical data → Read new field → Deprecate old field.
2. **Point-In-Time Backup Prior to DDL/Batch**: Before any migration script executes, an automated snapshot of `/somitis/{somitiId}` and root collections is generated.
3. **Restoration Dry-Run in Staging**: All migrations must be tested against a sanitized mirror of production data in the staging environment before touching production.
4. **Automated Rollback Triggers**: If any migration task encounters more than 0.01% errors or unhandled exceptions, it automatically executes the compensating rollback script and aborts.

---

## 2. Backup & Disaster Recovery SLAs

- **RPO (Recovery Point Objective)**: **≤ 15 minutes**. Continuous transaction log archiving and hourly incremental backups guarantee that no more than 15 minutes of non-reconstructible operational data can be lost.
- **RTO (Recovery Time Objective)**: **≤ 30 minutes**. Automated point-in-time restoration scripts can stand up a standby cluster and restore all tenant databases within 30 minutes.
- **Backup Window**: **02:00 Asia/Dhaka** daily automated full backup to encrypted cloud bucket.
