# PHASE 5: SUBSCRIPTION LIFECYCLE FINITE STATE MACHINE (13 STATES)

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** 13-State Transition Rules, Grace Period & Expiry Handling  

---

## 1. Lifecycle States
1. `trialing` (বিনামূল্যে ট্রায়াল চলমান — ১৪ দিন)
2. `active` (সক্রিয় ও নিয়মিত পরিশোধিত)
3. `pending_payment` (পেমেন্ট ইনভয়েস প্রস্তুত, অর্থ পরিশোধ অপেক্ষমাণ)
4. `pending_activation` (ম্যানুয়াল বা ব্যাংক পেমেন্ট জমা, অ্যাডমিন ভেরিফিকেশন অপেক্ষমাণ)
5. `upcoming_renewal` (মেয়াদ শেষের ৭ দিন পূর্বে রিনিউয়াল নোটিশ প্রেরিত)
6. `renewal_due` (মেয়াদ উত্তীর্ণের দিন নবায়ন প্রযোজ্য)
7. `payment_overdue` (মেয়াদোত্তীর্ণ কিন্তু গ্রেস পিরিয়ড কার্যকর)
8. `grace_period` (অতিরিক্ত ৭ দিন পূর্ণ কার্যক্ষমতাসহ বিশেষ সুবিধা)
9. `suspended` (গ্রেস পিরিয়ড শেষ, নতুন লেনদেন সাময়িক স্থগিত)
10. `cancelled` (সমিতি কর্তৃপক্ষ কর্তৃক স্বেচ্ছায় বাতিল)
11. `expired` (স্থায়ীভাবে মেয়াদোত্তীর্ণ ও নিষ্ক্রিয়)
12. `reactivated` (বকেয়া পরিশোধের পর পুনরায় সক্রিয়)
13. `upgraded_downgraded` (প্ল্যান স্তর পরিবর্তন প্রক্রিয়াকৃত)

---

## 2. Invariant Expiry Principles
- **No Data Deletion**: Subscription expiry or suspension **NEVER deletes society data**.
- **Audited Reactivation**: Once an overdue invoice is verified, state transitions automatically to `active` and expiry date is extended by the billed duration.
