# PHASE 5: PLATFORM SaaS REVENUE & COMMERCIAL ACCOUNTING

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** IFRS-15 Revenue Recognition & Separation of Commercial SaaS from Society Funds  

---

## 1. Accounting Policy: Absolute Separation of Funds

```
┌────────────────────────────────────────────────────────┐
│             PLATFORM COMMERCIAL ACCOUNTS               │
│                                                        │
│ 1111: Platform Merchant bKash Wallet                  │
│ 1122: Platform Corporate Bank (City Bank PLC)          │
│ 1150: Commercial Accounts Receivable (Due Subscriptions)│
│ 4310: SaaS Subscription Service Revenue                │
│ 2310: Unearned / Deferred Subscription Revenue         │
│ 5410: Payment Gateway Commission Expense               │
└────────────────────────────────────────────────────────┘
                           ≠
┌────────────────────────────────────────────────────────┐
│          SOCIETY COOPERATIVE OPERATIONAL ACCOUNTS       │
│                                                        │
│ 1110: Society Cash in Hand (Member Cash Drawer)        │
│ 1141: Microfinance Loan Principal Receivables          │
│ 2110: Member Daily Savings Deposit Liability           │
│ 2120: Member Monthly DPS Deposit Liability             │
│ 3110: Member Paid-up Share Capital                     │
└────────────────────────────────────────────────────────┘
```

A society's subscription fee is an expense of that society and SaaS revenue of the platform. Under no circumstances does a society subscription transaction manipulate member savings or loan ledger balances.

---

## 2. Journal Entries for Subscription Lifecycle
1. **Invoice Issuance (Monthly Due)**:
   - Debit: `1150 Accounts Receivable` (৳১,৯৯৯)
   - Credit: `4310 SaaS Subscription Revenue` (৳১,৯৯৯)
2. **Online Payment Receipt via bKash (1.5% fee)**:
   - Debit: `1111 Platform bKash Wallet` (৳১,৯৬৯.০২)
   - Debit: `5410 Payment Gateway Expense` (৳২৯.৯৮)
   - Credit: `1150 Accounts Receivable` (৳১,৯৯৯.০০)
