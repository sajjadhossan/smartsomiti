# PHASE_7_ARCHITECTURE.md — Enterprise Payment, Banking & Financial Integration Ecosystem

## 1. Executive Summary
Phase 7 introduces a provider-agnostic, bank-grade payment and banking integration architecture. It interfaces with Bangladesh's premier payment rails:
- **MFS (Mobile Financial Services)**: bKash Tokenized Merchant API, Nagad Direct Merchant PGW.
- **Card & Internet Banking**: SSLCOMMERZ Hosted Gateway (Visa, Mastercard, Amex, UnionPay, Internet Banking).
- **Commercial Banking**: Bank transfer verification, automated statement import (CSV/Excel), and 3-way reconciliation.
- **QR Payment Infrastructure**: Dynamic member-specific and installment-specific QR codes with replay protection.
- **Offline/Mobile Field Collections**: Tamper-proof field collection registers with two-step maker-checker verification.

```mermaid
flowchart TD
    MEMBER["Member / Society User"] --> CHANNELS["Payment Channels"]
    CHANNELS --> BKASH["bKash Tokenized"]
    CHANNELS --> NAGAD["Nagad Merchant"]
    CHANNELS --> SSL["SSLCOMMERZ"]
    CHANNELS --> BANK["Bank Wire / Deposit"]
    CHANNELS --> QR["Dynamic Bangla QR"]
    CHANNELS --> FIELD["Field Collector App"]

    BKASH & NAGAD & SSL & BANK & QR & FIELD --> ENGINE["Payment Integration Gateway Engine"]
    ENGINE --> IDEMP["Idempotency & Anti-Replay Guard"]
    IDEMP --> VERIFY["Automated Server Verification"]
    VERIFY --> GL["Phase 2 Double-Entry General Ledger"]
    VERIFY --> SAAS["Phase 5 SaaS Billing Engine"]
    VERIFY --> NOTIF["Phase 6 Notification Hub"]
    SUPER["👑 Master Super Admin Control Center"] --> ENGINE
```

## 2. Fundamental Architectural Invariants
1. **Never Trust Client Status**: No client app can mark an online payment, deposit, or loan repayment as "PAID" or "SUCCESS".
2. **Integer Poisha Precision**: All money math uses integer Poisha ($1\text{ BDT} = 100\text{ Poisha}$).
3. **Idempotency Keys**: Deterministic UUID/HMAC prevents duplicate debit/credit or double-charging.
4. **Tenant & Fund Segregation**: Platform SaaS fees and society microfinance funds remain strictly isolated in segregated charts of accounts.
