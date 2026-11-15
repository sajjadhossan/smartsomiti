# THIRD-PARTY INTEGRATION GUIDE & SANDBOX ENGINE — PHASE 15

## ১. ভূমিকা (Introduction)

"স্বপ্ন ছোঁয়া ঐক্য সমিতি" SaaS প্ল্যাটফর্ম বিভিন্ন থার্ড-পার্টি ফিনটেক ও এন্টারপ্রাইজ সেবার সাথে সংযোগ স্থাপনে প্রস্তুত। ফেজ ১৫-এ একটি সেন্ট্রালাইজড ইন্টিগ্রেশন হাব ও আইসোলেটেড স্যান্ডবক্স এনভায়রনমেন্ট প্রতিষ্ঠিত হয়েছে।

---

## ২. ইন্টিগ্রেশন ম্যাট্রিক্স ও সার্ভিস ক্যাটাগরি (Integration Matrix)

| ক্যাটাগরি | প্রোভাইডার | প্রোটোকল / মেথড | পরিবেশ | স্ট্যাটাস |
| :--- | :--- | :--- | :---: | :---: |
| **পেমেন্ট গেটওয়ে** | বিকাশ (bKash Direct Checkout) | REST API + Webhook Token | Sandbox / Live | 🟢 Connected |
| **পেমেন্ট গেটওয়ে** | নগদ (Nagad Online PGW) | REST API + RSA Signature | Sandbox / Live | 🟢 Connected |
| **পেমেন্ট গেটওয়ে** | রকেট / ডিবিবিএল নেক্সাসপে | API + BEFTN Settlement | Sandbox / Live | 🟢 Connected |
| **পেমেন্ট অ্যাগ্রিগেটর** | SSLCommerz PGW Hub | Hosted Checkout + IPN | Sandbox / Live | 🟢 Connected |
| **কোর ব্যাংকিং** | দ্য সিটি ব্যাংক পিএলসি | Corporate Host-to-Host (H2H) | Sandbox / Live | 🟢 Connected |
| **এসএমএস গেটওয়ে** | বাংলালিংক / গ্রামীণফোন বাল্ক এসএমএস | HTTP POST API + DLR Callback | Sandbox / Live | 🟢 Connected |
| **আন্তর্জাতিক এসএমএস**| Twilio SMS / WhatsApp Cloud API | REST v2 + Webhook | Sandbox / Live | 🟢 Connected |

---

## ৩. স্যান্ডবক্স বনাম প্রোডাকশন আইসোলেশন (Sandbox vs Production Environment)

1. **সম্পূর্ণ ডেটা বিচ্ছিন্নতা:**
   - স্যান্ডবক্স এনভায়রনমেন্টের জন্য আলাদা টেস্ট টেন্যান্ট আইডি (`sandbox_society_demo`) এবং সিন্থেটিক ডাটাবেজ ব্যবহৃত হয়।
   - স্যান্ডবক্স এপিআই কী (`sk_test_...`) দিয়ে প্রোডাকশন ডাটাবেজে অ্যাক্সেস কঠোরভাবে অসম্ভব।
2. **সিমুলেটেড পেমেন্ট ও টেস্ট কার্ড:**
   - বিকাশ স্যান্ডবক্স ওটিপি `123456` এবং পিন `12121` দ্বারা সফল পেমেন্ট ও ব্যর্থ পেমেন্টের সম্পূর্ণ লাইফসাইকেল টেস্ট করা যায়।
3. **পরিবেশ নির্দেশক (Environment Badge):**
   - ডেভেলপার ড্যাশবোর্ড এবং রিকোয়েস্টে স্পষ্ট লাল/হলুদ `SANDBOX MODE` ব্যাজ দৃশ্যমান থাকবে যাতে প্রোডাকশনের সাথে কোনো বিভ্রান্তি তৈরি না হয়।
