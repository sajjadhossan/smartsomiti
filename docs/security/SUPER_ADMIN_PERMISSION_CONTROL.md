# SUPER ADMIN — UNIVERSAL PERMISSION & SECURITY CONTROL SPECIFICATION

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Platform Super Admin / Master Admin Security Switchboard  
**Scope:** Universal Control over Modules, Features, Sub-Features, CRUD, Actions, and Buttons  

---

## 1. Architectural Philosophy: Absolute Sovereignty without Security Degradation

The Platform Super Admin holds supreme administrative authority to govern access, feature availability, and permissions across all societies. However, **Universal ON/OFF control must never create an unsafe backdoor or bypass the minimum security baseline**:
- Disabling a feature hides UI interactions and rejects new write operations.
- Historical records, ledger entries, and audit logs remain strictly preserved and immutable.
- Lower-tier user requests can never override higher-tier security restrictions.

---

## 2. Universal Permission Keys Registry (Granular Taxonomy)

Below is the authoritative dictionary of registered granular permission keys implemented in the platform:

### 2.1 Member Management (`members.*`)
| Permission Key | Description (Bangla) | Protected Actions & Buttons |
|:---|:---|:---|
| `members.view` | সদস্য তালিকা ও পাসবুক দেখা | View member directory, profile tabs |
| `members.create` | নতুন সদস্য নিবন্ধন | "নতুন সদস্য যোগ করুন" বাটন, রেজিস্ট্রেশন ফরম |
| `members.update` | সদস্য তথ্য ও ছবি সম্পাদন | "তথ্য সম্পাদন" বাটন, ছবি ও স্বাক্ষর আপলোড |
| `members.delete` | সদস্য নিষ্ক্রিয়/বাতিলকরণ | "সদস্য নিষ্ক্রিয় করুন" অ্যাকশন বাটন |
| `members.id_card` | ডিজিটাল আইডি কার্ড তৈরি | "আইডি কার্ড প্রিন্ট" বাটন ও PDF জেনারেশন |
| `members.export` | সদস্য তালিকা এক্সপোর্ট | "এক্সেল/CSV ডাউনলোড" বাটন |

### 2.2 Savings Management (`savings.*`)
| Permission Key | Description (Bangla) | Protected Actions & Buttons |
|:---|:---|:---|
| `savings.view` | সঞ্চয় ব্যালেন্স ও তালিকা দেখা | View savings accounts, total fund hero |
| `savings.deposit` | সঞ্চয় কিস্তি জমা গ্রহণ | "কিস্তি জমা নিন" বাটন ও জমা ফরম |
| `savings.withdraw` | সঞ্চয় উত্তোলন আবেদন | "টাকা উত্তোলন" বাটন ও উইথড্রয়াল সাবমিট |
| `savings.approve_withdrawal` | উত্তোলন অনুমোদন (Checker) | "উত্তোলন অনুমোদন করুন" বাটন |
| `savings.passbook_print` | পাসবুক ও রসিদ প্রিন্ট | "মানি রসিদ প্রিন্ট", A4 মেমো বাটন |

### 2.3 Loan Management (`loans.*`)
| Permission Key | Description (Bangla) | Protected Actions & Buttons |
|:---|:---|:---|
| `loans.view` | ঋণ তালিকা ও কিস্তি সূচি দেখা | View loan list, amortization schedules |
| `loans.create` | নতুন ঋণের আবেদন প্রস্তুত | "নতুন ঋণের আবেদন" বাটন |
| `loans.approve` | ঋণের আবেদন অনুমোদন | "অনুমোদন করুন" সিদ্ধান্ত বাটন |
| `loans.reject` | ঋণের আবেদন বাতিল | "বাতিল করুন" সিদ্ধান্ত বাটন |
| `loans.disburse` | ঋণ অর্থ বিতরণ (Disbursement) | "ক্যাশ আউট / বিতরণ সম্পন্ন" বাটন |
| `loans.repay` | ঋণের কিস্তি আদায় | "কিস্তি আদায়" বাটন ও ট্রানজিশন |
| `loans.reschedule` | কিস্তি পুনর্গঠন ও মওকুফ | "কিস্তি পুনর্নির্ধারণ" বাটন |

### 2.4 Financial Accounting (`accounting.*`)
| Permission Key | Description (Bangla) | Protected Actions & Buttons |
|:---|:---|:---|
| `accounting.view` | হিসাব খতিয়ান ও চার্ট দেখা | View Chart of Accounts, Trial Balance |
| `accounting.create_journal` | খসড়া জার্নাল ভাউচার তৈরি | "নতুন ভাউচার এন্ট্রি" বাটন |
| `accounting.post_journal` | ভাউচার লেজারে পোস্টিং | "ভাউচার পোস্ট ও লক করুন" বাটন |
| `accounting.reverse_journal` | ভাউচার রিভার্সাল দাখিলা | "সংশোধনী বিপরীত দাখিলা" বাটন |
| `accounting.close_period` | হিসাবকাল সমাপ্তি ও ক্লোজিং | "হিসাবকাল বন্ধ (Period Close)" বাটন |
| `accounting.reconcile_bank` | ব্যাংক বিবরণী সমন্বয় | "ব্যাংক রিকনসিলিয়েশন" বাটন |

### 2.5 Security, Access & Audit (`security.*`)
| Permission Key | Description (Bangla) | Protected Actions & Buttons |
|:---|:---|:---|
| `security.view` | সিকিউরিটি ড্যাশবোর্ড ও কেপিআই | Security Overview, Alert Feed |
| `security.manage_roles` | রোল ও প্রি-সেট পারমিশন পরিবর্তন | "রোল কনফিগারেশন" সেভ বাটন |
| `security.manage_permissions` | সার্বজনীন পারমিশন অন/অফ সুইচ | Universal Switchboard Toggles |
| `security.manage_sessions` | অ্যাক্টিভ সেশন ও ডিভাইস রদবদল | "সেশন রিভোক / ফোর্স লগআউট" বাটন |
| `security.view_audit_logs` | অপরিবর্তনীয় অডিট লগ ও হিস্ট্রি | Audit Trail Viewer & Chain Checker |
| `security.manage_policies` | এমএফএ ও সিকিউরিটি পলিসি নির্ধারণ | "এমএফএ পলিসি ও লকআউট সেটিংস" |

---

## 3. Super Admin Universal Control Scopes

1. **Global Master Scope**: Applies to all tenants and societies platform-wide.
2. **Society-Specific Scope**: Tailored per society ID (`/somitis/{somitiId}`).
3. **Module & Feature Scope**: Coarse toggles turning off functional modules.
4. **Action/Button Scope**: Fine-grained switches suppressing individual interaction buttons.
5. **Role & User Scope**: Assigning explicit grant or deny to roles or individual user IDs.

When an action is evaluated, the system guarantees instant sub-millisecond resolution via an in-memory cached policy map with real-time Firestore sync.
