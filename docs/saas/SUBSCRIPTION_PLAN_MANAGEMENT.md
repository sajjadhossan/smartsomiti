# PHASE 5: SUBSCRIPTION PLAN MANAGEMENT & PRICING SPECIFICATION

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Subscription Plan Catalog, Tier Configuration & Usage Quotas  

---

## 1. Standard Tiered Pricing Architecture

Plans are dynamically defined in Firestore collection `/saas_plans/{planId}` with integer Poisha pricing:

| Plan ID | Plan Name (Bangla) | Monthly Price | Annual Price (2 Months Free) | Member Limit | User/Staff Limit | Included Capabilities |
|:---|:---|:---:|:---:|:---:|:---:|:---|
| `plan_starter` | **স্টার্টার প্ল্যান (Starter)** | ৳৯৯৯ (৯৯,৯০০ পয়সা) | ৳৯,৯৯০ | ১০০ জন | ৩ জন | সঞ্চয় ও কিস্তি, সদস্য পাসবুক, বেসিক ক্যাশবহি, মানি রসিদ |
| `plan_standard` | **স্ট্যান্ডার্ড প্ল্যান (Standard)** | ৳১,৯৯৯ (১৯৯,৯০০ পয়সা) | ৳১৯,৯৯০ | ৫০০ জন | ৮ জন | স্টার্টারের সব + ক্ষুদ্রঋণ বিতরণ, EMI সূচি, নোটিশ প্যাড, ড্রাইভ ব্যাকআপ |
| `plan_premium` | **প্রিমিয়াম প্ল্যান (Premium)** | ৳৩,৯৯৯ (৩৯৯,৯০০ পয়সা) | ৳৩৯,৯৯০ | ২০০০ জন | ২০ জন | স্ট্যান্ডার্ডের সব + ডাবল-এন্ট্রি হিসাববিজ্ঞান, অনুমোদন ওয়ার্কফ্লো, মেকার-চেকার |
| `plan_enterprise` | **এন্টারপ্রাইজ (Enterprise)** | ৳৭,৯৯৯ (৭৯৯,৯০০ পয়সা) | ৳৭৯,৯৯০ | আনলিমিটেড | আনলিমিটেড | সকল মডিউল + সার্বজনীন সিকিউরিটি সেন্টার, কাস্টম ব্র্যান্ডিং, ডেডিকেটেড সাপোর্ট |

---

## 2. Dynamic Plan Attributes Schema
```json
{
  "planId": "plan_premium",
  "nameBn": "প্রিমিয়াম প্ল্যান (IFRS Double-Entry + Workflow)",
  "monthlyPriceInPoisha": 399900,
  "quarterlyPriceInPoisha": 1099700,
  "annualPriceInPoisha": 3999000,
  "currency": "BDT",
  "trialDays": 14,
  "maxMembers": 2000,
  "maxStaff": 20,
  "maxBranches": 5,
  "storageLimitMb": 5120,
  "includedModules": [
    "society_management", "authentication", "member_management",
    "savings_management", "loan_management", "financial_accounting",
    "workflow_approval", "reports", "pdf_export"
  ],
  "entitlementOverrides": {
    "workflow.maker_checker": true,
    "accounting.double_entry": true
  },
  "isActive": true
}
```
Super Admin can add, update, pause, or retire plans in real time via the Master Admin Control Center.
