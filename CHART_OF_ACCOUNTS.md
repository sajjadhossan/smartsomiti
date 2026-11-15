# ENTERPRISE CHART OF ACCOUNTS (COA) SPECIFICATION
**Project:** Multi-Society Cooperative Management SaaS Platform ("স্বপ্ন ছোঁয়া ঐক্য সমিতি")  
**Module:** Phase 2 — Advanced Double-Entry Financial Engine  
**Standards:** IFRS for SMEs & Bangladesh Cooperative Societies Rules  
**Date:** 2026-11-14

---

## 1. Accounting Structure & Hierarchy

The Chart of Accounts (COA) is organized using a standardized 4-digit code hierarchy supporting Parent Accounts and Sub-Accounts (Child Accounts):

```
Code Range      Account Category              Normal Balance
--------------------------------------------------------------
1000 – 1999     ASSETS (সম্পদ)                 DEBIT (ডেবিট)
2000 – 2999     LIABILITIES (দায়)              CREDIT (ক্রেডিট)
3000 – 3999     EQUITY / CAPITAL (মূলধন ও তহবিল) CREDIT (ক্রেডিট)
4000 – 4999     INCOME / REVENUE (আয়)          CREDIT (ক্রেডিট)
5000 – 5999     EXPENSES (ব্যয়)                DEBIT (ডেবিট)
```

---

## 2. Standardized Cooperative Chart of Accounts Master Template

### 1000 — ASSETS (সম্পদ সমূহ)
- **1100 — Current Assets (চলতি সম্পদ)**
  - `1110` — Main Cash in Hand / Vault (প্রধান ক্যাশ ড্রয়ার - হাতের নগদ) [DEBIT]
  - `1120` — Cash at Commercial Banks (ব্যাংক হিসাব) [DEBIT]
    - `1121` — City Bank PLC Current Account
    - `1122` — Sonali Bank PLC General Account
  - `1130` — Mobile Financial Services (MFS ওয়ালেট) [DEBIT]
    - `1131` — bKash Merchant Wallet
    - `1132` — Nagad Merchant Wallet
    - `1133` — Rocket Wallet
  - `1140` — Micro-Loans Principal Receivable (বিতরণকৃত ঋণ আসল প্রাপ্য) [DEBIT]
    - `1141` — General Micro-credit Loan Principal
    - `1142` — SME Business Loan Principal
    - `1143` — Emergency Loan Principal
  - `1150` — Interest & Penalties Receivable (বকেয়া সুদ ও জরিমানা প্রাপ্য) [DEBIT]
  - `1160` — Advance & Security Deposits Paid (অগ্রিম ও নিরাপত্তা জামানত) [DEBIT]
- **1200 — Non-Current Assets (স্থায়ী ও দীর্ঘমেয়াদী সম্পদ)**
  - `1210` — Office Furniture & Fixtures (আসবাবপত্র ও ডেকোরেশন) [DEBIT]
  - `1220` — Computer & Electronic Equipment (কম্পিউটার ও ইলেকট্রনিক্স) [DEBIT]
  - `1230` — Office Vault & Safe (লোহার সিন্দুক / সেফ) [DEBIT]
  - `1290` — Accumulated Depreciation (পুঞ্জীভূত অবচয়) [CREDIT - Contra Asset]

---

### 2000 — LIABILITIES (দায় সমূহ)
> [!IMPORTANT]
> **Strict Regulatory Invariant**: Member savings deposits are strictly categorized as **LIABILITIES (আমানত দায়)** owed back to members, NEVER as society revenue or income!
- **2100 — Member Savings Liabilities (সদস্য সঞ্চয় ও আমানত দায়)**
  - `2110` — General Daily Savings (সাধারণ দৈনিক সঞ্চয়) [CREDIT]
  - `2120` — Monthly DPS Savings (মাসিক ডিপিএস সঞ্চয়) [CREDIT]
  - `2130` — Long-Term Term Deposit / FDR (মেয়াদী সঞ্চয় আমানত) [CREDIT]
  - `2140` — Member Security Deposit (সদস্য জামানত তহবিল) [CREDIT]
- **2200 — Current Liabilities & Payables (চলতি দেনা ও পাওনা)**
  - `2210` — Accrued Salaries Payable (বকেয়া কর্মকর্তা/কর্মচারী বেতন) [CREDIT]
  - `2220` — Office Rent Payable (বকেয়া অফিস ভাড়া) [CREDIT]
  - `2230` — Utility Bills Payable (বকেয়া বিদ্যুৎ ও ইন্টারনেট বিল) [CREDIT]
  - `2240` — Audit & Legal Fees Payable (অডিট ও আইনি ফি প্রদেয়) [CREDIT]
  - `2250` — Cooperative Welfare Fund Payable (কল্যাণ তহবিল দায়) [CREDIT]

---

### 3000 — EQUITY & RESERVES (মালিকানা স্বত্ব ও রিজার্ভ তহবিল)
- **3100 — Share Capital (শেয়ার মূলধন)**
  - `3110` — Member Paid-up Share Capital (পরিশোধিত শেয়ার মূলধন) [CREDIT]
- **3200 — Statutory & Cooperative Reserves (সংবিধিবদ্ধ রিজার্ভ)**
  - `3210` — Statutory Reserve Fund - 15% (সংবিধিবদ্ধ সংরক্ষিত তহবিল) [CREDIT]
  - `3220` — Cooperative Development Fund - 3% (সমবায় উন্নয়ন তহবিল) [CREDIT]
  - `3230` — Bad Debt Provision Reserve (কু-ঋণ সঞ্চিতি রিজার্ভ) [CREDIT]
- **3300 — Retained Earnings (পুঞ্জীভূত নিট উদ্বৃত্ত)**
  - `3310` — Prior Years' Retained Surplus (পূর্ববর্তী বছরের উদ্বৃত্ত) [CREDIT]
  - `3320` — Current Year Net Surplus / Deficit (চলতি বছরের নিট উদ্বৃত্ত) [CREDIT]

---

### 4000 — REVENUE & INCOME (পরিচালন আয়)
> [!IMPORTANT]
> **Strict Revenue Invariant**: Only interest margins, service charges, passbook sales, and penalties constitute operational income!
- **4100 — Financial & Lending Income (আর্থিক ও ঋণ কার্যক্রমের আয়)**
  - `4110` — Micro-credit Loan Interest Income (ঋণের সরল/হ্রাসমান সুদ আয়) [CREDIT]
  - `4120` — Loan Processing & Form Fees (ঋণ প্রসেসিং ও ফরম ফি) [CREDIT]
  - `4130` — Overdue Installment Late Penalties (বকেয়া কিস্তির বিলম্ব ফি) [CREDIT]
  - `4140` — DPS Overdue Penalty Income (ডিপিএস বিলম্ব জরিমানা) [CREDIT]
- **4200 — Member Fee Income (সদস্য সেবা ও বিবিধ আয়)**
  - `4210` — Member Admission Fees (নতুন সদস্য ভর্তি ফি) [CREDIT]
  - `4220` — Digital Passbook & ID Card Sales (পাসবুক ও আইডি কার্ড ফি) [CREDIT]
  - `4230` — Bank Interest Received (ব্যাংক সঞ্চয়ী হিসাবের মুনাফা) [CREDIT]
  - `4290` — Miscellaneous Operational Income (বিবিধ আয়) [CREDIT]

---

### 5000 — OPERATIONAL EXPENSES (পরিচালন ব্যয়)
- **5100 — Financial Costs (আর্থিক ব্যয় ও মুনাফা প্রদান)**
  - `5110` — Dividend/Profit Paid on Member DPS (ডিপিএস সঞ্চয়ের ওপর লভ্যাংশ প্রদান) [DEBIT]
  - `5120` — Bank & MFS Transaction Charges (ব্যাংক ও বিকাশ ট্রানজেকশন চার্জ) [DEBIT]
- **5200 — Employee & Management Expenses (কর্মকর্তা ও প্রশাসনিক ব্যয়)**
  - `5210` — Staff Salaries & Allowances (কর্মকর্তা-কর্মচারীদের মাসিক বেতন) [DEBIT]
  - `5220` — Field Collection Agent Commission (মাঠ কর্মকর্তার আদায় কমিশন) [DEBIT]
  - `5230` — Eid & Festival Bonus (উৎসব ভাতা ও বোনাস) [DEBIT]
- **5300 — Office Administrative Expenses (অফিস পরিচালনা ব্যয়)**
  - `5310` — Office Rent Expense (প্রধান কার্যালয় ভাড়া) [DEBIT]
  - `5320` — Electricity, Water & Utilities (বিদ্যুৎ, পানি ও গ্যাস বিল) [DEBIT]
  - `5330` — Stationery, Printing & Passbooks (কাগজ, প্রিন্টিং ও স্টেশনারি) [DEBIT]
  - `5340` — Office Entertainment & Refreshments (আপ্যায়ন ও মেহমানদারি) [DEBIT]
  - `5350` — Software, Cloud & SMS Gateway Fees (ক্লাউড সফটওয়্যার ও এসএমএস গেটওয়ে) [DEBIT]
  - `5360` — Annual Audit & Regulatory Compliance (বার্ষিক অডিট ও সরকারি নবায়ন ফি) [DEBIT]
  - `5370` — Legal & Professional Fees (আইনি ও পরামর্শক ফি) [DEBIT]
  - `5380` — Asset Depreciation Expense (স্থায়ী সম্পদের অবচয় খরচ) [DEBIT]
  - `5390` — Miscellaneous Office Expenses (বিবিধ অনাকাঙ্ক্ষিত খরচ) [DEBIT]

---

## 3. Account Data Model & Validation Rules

```dart
class ChartOfAccountModel {
  final String id;
  final String code;             // e.g. "1110"
  final String name;             // e.g. "প্রধান ক্যাশ ড্রয়ার"
  final String englishName;      // e.g. "Main Cash Vault"
  final AccountCategory category;// asset, liability, equity, income, expense
  final String parentCode;       // e.g. "1100"
  final bool isHeaderAccount;    // If true, cannot post direct transactions to it
  final int normalBalance;       // +1 for Debit, -1 for Credit
  final int balanceInPoisha;     // Integer minor currency units (৳1.00 = 100 poisha)
  final bool isSystemLocked;     // Critical system accounts cannot be deleted
  final bool isActive;
}
```

- **Minor Currency Precision**: Balances are calculated in Poisha (integers) to guarantee 100.000% mathematical zero-drift.
- **Header vs Posting Account**: Posting is strictly permitted only to leaf accounts (`isHeaderAccount == false`).
