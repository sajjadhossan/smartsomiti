# ADVANCED MEMBER INTELLIGENCE & SEGMENTATION SPECIFICATION

## 1. Objectives
The Member Intelligence Dashboard analyzes membership lifecycle conversion, savings consistency, loan participation, and KYC compliance while strictly preventing any discriminatory profiling.

## 2. Authorized Member Segmentation Taxonomy
| Segment Code | Segment Name (Bengali) | Inclusion Criteria | Recommended Action |
| :--- | :--- | :--- | :--- |
| `SEG_ACTIVE_SAVER` | নিয়মিত সঞ্চয়ী সদস্য | Deposited savings in at least 3 of last 3 months, zero overdue | Eligible for higher loan tiers & interest dividend |
| `SEG_ACTIVE_BORROWER` | ঋণগ্রহীতা সদস্য | Active running loan, timely installment repayments | Regular monitoring & passbook sync |
| `SEG_OVERDUE_RISK` | ঝুঁকিপূর্ণ খেলাপি সদস্য | Missed $\ge 2$ consecutive loan installments | Field officer visit & reminder SMS |
| `SEG_PENDING_KYC` | KYC অসম্পূর্ণ সদস্য | Profile missing verified NID or photo verification | Block loan disbursement until verified |
| `SEG_DORMANT` | নিষ্ক্রিয় সদস্য | Zero transactions across all accounts for $\ge 90$ days | Relationship manager re-engagement |

## 3. Retention & Churn Rate Analytics
$$\text{Monthly Retention Rate} = \frac{E - N}{S} \times 100\%$$
Where:
- $S$ = Number of members at start of period
- $E$ = Number of members at end of period
- $N$ = New members acquired during period
Cooperative benchmark target: $\text{Retention Rate} \ge 95\%$.
