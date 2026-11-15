# MEMBER_LIFECYCLE.md — Member Lifecycle Management

## 1. Lifecycle State Machine
Integrates seamlessly with the existing `MemberModel` and membership registry:

```mermaid
stateDiagram-v2
    [*] --> Prospect : CRM Inbound
    Prospect --> ApplicationSubmitted : ফর্ম জমা
    ApplicationSubmitted --> UnderReview : ভেরিফিকেশন ও অডিট
    UnderReview --> Approved : নির্বাহী কমিটি অনুমোদন
    Approved --> Active : প্রথম সঞ্চয় জমা ও পাসবুক ইস্যু
    Active --> Suspended : ঋণ খেলাপি বা শৃঙ্খলাজনিত স্থগিতাদেশ
    Suspended --> Active : সমস্যা সমাধান ও পুনঃসক্রিয়করণ
    Active --> Inactive : দীর্ঘমেয়াদে নিষ্ক্রিয়
    Active --> Resigned : আনুষ্ঠানিকভাবে সদস্যপদ প্রত্যাহার
    Resigned --> Archived : স্থায়ী সংরক্ষণ (অডিট অক্ষত)
```

## 2. Invariants
- Historical financial transactions (savings deposits, loan repayments) are **NEVER deleted** when a member resigns or becomes inactive.
- Status transitions require maker-checker approval and produce cryptographic audit logs.
