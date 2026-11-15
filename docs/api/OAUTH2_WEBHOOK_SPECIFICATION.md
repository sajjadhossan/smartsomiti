# OAUTH 2.0 & WEBHOOK SPECIFICATION — PHASE 15

## ১. ভূমিকা (Overview)

বহিরাগত বিশ্বস্ত অ্যাপ্লিকেশন ও ডেভেলপারদের নিরাপদ অনুমোদন নিশ্চিত করতে প্ল্যাটফর্মে RFC 6749 ও RFC 7636 (PKCE) ভিত্তিক ওঅথ ২.০ এবং ইভেন্ট-ড্রিভেন আর্কিটেকচারের জন্য ক্রিপ্টোগ্রাফিক্যালি সাইন্ড ওয়েবহুক সিস্টেম বাস্তবায়ন করা হয়েছে।

---

## ২. ওঅথ ২.০ অথরাইজেশন ফ্রেমওয়ার্ক (OAuth 2.0 Framework)

### ক. সমর্থিত ফ্লোসমূহ (Supported Grant Types):
1. **Client Credentials Grant:** সার্ভার-টু-সার্ভার ইন্টিগ্রেশন ও ব্যাকগ্রাউন্ড সিঙ্কিংয়ের জন্য (M2M)।
2. **Authorization Code Grant with PKCE:** ক্লাউড/মোবাইল অ্যাপ্লিকেশনের জন্য সিকিউর ইউজার অথরাইজেশন।

### খ. টোকেন লাইফসাইকেল (Token Lifecycles):
- **Access Token:** মেয়াদ ১ ঘণ্টা (৩,৬০০ সেকেন্ড), ক্রিপ্টোগ্রাফিক সাইফার টোকেন।
- **Refresh Token:** মেয়াদ ৩০ দিন, সিঙ্গেল-ইউজ রোটেশন পলিসি এনফোর্সড।
- **টোকেন রিভোকেশন:** `POST /api/v1/auth/revoke` এন্ডপয়েন্টে ইনস্ট্যান্ট টোকেন ইনভ্যালিডেশন।

---

## ৩. ওয়েবহুক অবকাঠামো ও নিরাপত্তা (Webhook Infrastructure & Security)

### ক. ইভেন্ট ক্যাটালগ (Event Catalog):
- `member.created`: নতুন সদস্য সফলভাবে নিবন্ধিত হলে
- `member.updated`: সদস্য প্রোফাইল হালনাগাদ হলে
- `savings.deposit.completed`: কিস্তি জমা হয়ে ডাবল-এন্ট্রি জার্নাল সম্পন্ন হলে
- `savings.withdrawal.completed`: সঞ্চয় উত্তোলন অনুমোদিত ও সম্পন্ন হলে
- `loan.application.created`: নতুন ঋণের আবেদন জমা হলে
- `loan.disbursed`: ঋণ বিতরণ ও ব্যাংক ভাউচার পোস্ট হলে
- `loan.repayment.completed`: ঋণের কিস্তি পরিশোধ হলে
- `payment.completed`: ডিজিটাল গেটওয়ে (বিকাশ/নগদ) পেমেন্ট ভেরিফাইড হলে
- `payment.failed`: পেমেন্ট ব্যর্থ হলে

### খ. ক্রিপ্টোগ্রাফিক সিগনেচার ভেরিফিকেশন (HMAC-SHA256 Signature):
প্রতিটি ওয়েবহুক পেলোড প্রেরণের পূর্বে হেডার্সে সাইন করা হয়:
```http
X-Somiti-Signature: sha256=d58d7c2f...
X-Somiti-Timestamp: 1731627000
X-Somiti-Event-Id: evt_2026_9901
X-Somiti-Idempotency-Key: idm_txn_4412
```

**রিসিভার ভেরিফিকেশন কোড (Node.js উদাহরণ):**
```javascript
const crypto = require('crypto');
const signature = req.headers['x-somiti-signature'];
const timestamp = req.headers['x-somiti-timestamp'];
const payload = JSON.stringify(req.body);

const expectedSignature = 'sha256=' + crypto
  .createHmac('sha256', WEBHOOK_SECRET)
  .update(`${timestamp}.${payload}`)
  .digest('hex');

if (signature === expectedSignature) {
  // Verified & Process Event
}
```

### গ. রিট্রাই ও ব্যাকঅফ পলিসি (Retry with Exponential Backoff):
যদি গ্রাহকের সার্ভার HTTP 2xx রেসপন্স না দেয়, তবে সিস্টেম ৫ বার রিট্রাই করবে:
- প্রথম রিট্রাই: ১ মিনিট পর
- দ্বিতীয় রিট্রাই: ৫ মিনিট পর
- তৃতীয় রিট্রাই: ১৫ মিনিট পর
- চতুর্থ রিট্রাই: ১ ঘণ্টা পর
- পঞ্চম রিট্রাই: ৬ ঘণ্টা পর
৫ বার ব্যর্থ হলে ওয়েবহুকটি সাময়িকভাবে `SUSPENDED` স্ট্যাটাসে যাবে এবং ডেভেলপার ড্যাশবোর্ডে অ্যালার্ট প্রদর্শন করবে।
