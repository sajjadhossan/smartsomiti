# Phase 18: Enterprise Member Super App & Digital Self-Service Ecosystem Architecture

## 1. Executive Overview

The **Enterprise Member Super App & Digital Self-Service Ecosystem** is an integrated extension of the multi-society cooperative management SaaS platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি" / `cloud_sync_drive`). It grants verified cooperative society members self-service access to their own savings, loans, statements, digital membership credentials, payment receipts, service tickets, and authorized applications—while preserving strict multi-tenant isolation, immutable security invariants, and server-side authorization boundaries.

```mermaid
flowchart TD
    subgraph MemberClient["Member Self-Service Layer (Web / Android / iOS)"]
        MA[Member Super App UI]
        MC[Digital Card & Secure QR]
        MS[Savings & Withdrawal Portal]
        ML[Loan Application & Repayment]
        MD[Statements & Document Center]
        MT[Helpdesk & Service Tickets]
    end

    subgraph SecurityGate["Security & Policy Gatekeeper"]
        Auth[Firebase Authentication & MFA]
        RBAC[Super Admin Universal Policy Engine]
        TenantFilter[Strict Multi-Tenant & Member UID Isolation]
    end

    subgraph CoreBackend["Authoritative Core Business Engines (Reused)"]
        OLTP[(Firestore Operational DB)]
        GL[Double-Entry General Ledger (Phase 2)]
        WF[Maker-Checker Workflow Engine (Phase 3)]
        Pay[Payment Gateway bKash/Nagad/Bank (Phase 7)]
        HD[Customer Support Helpdesk (Phase 14)]
        DW[Enterprise Data Warehouse (Phase 17)]
    end

    MA --> SecurityGate
    MC --> SecurityGate
    MS --> SecurityGate
    ML --> SecurityGate
    MD --> SecurityGate
    MT --> SecurityGate

    SecurityGate --> GL
    SecurityGate --> WF
    SecurityGate --> Pay
    SecurityGate --> HD
    SecurityGate --> OLTP
    SecurityGate --> DW
```

---

## 2. Architectural Design Principles

1. **Zero Financial Calculation Duplication**:
   - The Member App **never** calculates savings interest, loan amortization schedules, or ledger balances locally. All financial figures are read directly from posted transactions and verified backend engines (`DoubleEntryAccountingService`, `LoanService`).
2. **Client-Side Security Non-Reliance**:
   - Hiding a button or menu in the member interface is **never** considered an authorization boundary. Every API endpoint, Firestore path, and cloud function performs server-side role and tenant verification (`request.auth.uid == member.uid`).
3. **No Self-Approval (Maker-Checker Enforcement)**:
   - Members can submit withdrawal requests, profile updates, KYC documents, and loan applications. However, they **cannot approve** their own requests. All submissions enter the Phase 3 Maker-Checker Workflow Engine for review by authorized society officers.
4. **Tenant & Member Boundary Isolation**:
   - Member $M_1$ belonging to Society $S_A$ cannot access data from Member $M_2$ or Society $S_B$. Direct query filters strictly constrain all reads to `/somitis/{societyId}/members/{memberId}`.
5. **Offline Read-Only Safety**:
   - Offline cached data is strictly tagged with a timestamp and marked as "অফলাইন ক্যাশ". No financial mutations are acknowledged as completed until verified by the authoritative backend.

---

## 3. Storage & Domain Model Schema

| Collection / Path | Purpose | Access Control |
| :--- | :--- | :--- |
| `/somitis/{somitiId}/members/{memberId}` | Authoritative member profile, savings total, KYC status | Owner Member & Society Admins |
| `/somitis/{somitiId}/digital_cards/{cardId}` | Digital membership card, signed QR token, status | Owner Member (Read), Admins (Manage) |
| `/somitis/{somitiId}/member_requests/{reqId}` | Withdrawal requests, loan applications, KYC submissions | Owner Member (Create/Read), Maker-Checker Officers (Review) |
| `/somitis/{somitiId}/deposits/{depositId}` | Member savings deposit history & vouchers | Owner Member (Read-only posted records) |
| `/somitis/{somitiId}/loans/{loanId}` | Approved loans, installment schedules, repayments | Owner Member (Read-only) |
| `/somitis/{somitiId}/support_tickets/{ticketId}` | Member service requests & helpdesk integration | Owner Member & Assigned Support Agents |

---

## 4. Super Admin Universal ON/OFF Permission Controls

The Platform Super Admin exercises full centralized control over every member-facing capability across 8 hierarchy levels:
- **Global Platform Level**: Master kill-switch for the entire Member Self-Service subsystem (`member_super_app`).
- **Society Level**: Disable member online withdrawals or loan applications for specific societies.
- **Subscription Plan Level**: Basic plan societies may have read-only passbooks; Enterprise plans get online payments and loan applications.
- **Role Level**: Distinction between General Member, Committee Member, and Support Staff.
- **Individual Member Level**: Suspension of compromised or defaulting member app access.
- **Module & Feature Level**: Granular toggles for `member_digital_card`, `member_online_payment`, `member_kyc_upload`.
- **Action Level**: Control over individual actions such as `act_member_withdrawal_request` or `act_member_loan_application`.

> [!IMPORTANT]
> **Immutable Invariants**: Tenant isolation, double-entry ledger balance invariants, and the prohibition of member self-approval can **never** be turned off through administrative toggles.
