# CRM_MODULE.md — Society CRM, Leads & Relationship Management

## 1. Overview
The CRM module organizes interactions with prospective members, guarantors, vendors, and partners with complete society-level tenant isolation.

## 2. Lead Lifecycle Stages
- `new`: Inbound inquiry or scouted contact.
- `contacted`: Initial phone call or physical visit completed.
- `interested`: Expressed interest in opening a savings account or taking micro-loans.
- `followup_required`: Scheduled callback or site verification.
- `application_started`: Prospective member application initiated.
- `converted`: Officially registered as a cooperative member (zero duplicate entry).
- `rejected` / `closed`: Ineligible or declined.

## 3. Data Invariants & Anti-Duplication
- Phone numbers are validated and indexed for duplicate detection per society.
- Lead conversion directly links to the existing `MemberModel` ID without recreating personal history.
- All communications (calls, visits, notes) are stored as timestamped immutable interaction events.
