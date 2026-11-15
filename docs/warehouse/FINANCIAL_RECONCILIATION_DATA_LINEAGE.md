# FINANCIAL RECONCILIATION & DATA LINEAGE SPECIFICATION

## ১. শতভাগ আর্থিক রিকনসিলিয়েশন সূত্র (Financial Reconciliation Equations)
ডাটা ওয়্যারহাউজের প্রতিটি মেট্রিক অবশ্যই অপারেশনাল জেনারেল লেজারের সাথে পয়সায়-পয়সায় মিলে যেতে হবে।

### ক. ফান্ডামেন্টাল অ্যাকাউন্টিং সমীকরণ:
$$\text{মোট সম্পদ (Assets)} = \text{মোট দায় (Liabilities)} + \text{মূলধন ও সঞ্চিতি (Equity)}$$

### খ. ওয়্যারহাউজ রিকনসিলিয়েশন সমীকরণ:
1. **সঞ্চয় দায় রিকনসিলিয়েশন:**
   $$\sum \text{fact\_savings\_transactions.balance} \equiv \text{GL Liability Account (2001 - সদস্য সঞ্চয়)}$$
2. **ঋণ সম্পদ রিকনসিলিয়েশন:**
   $$\sum \text{fact\_loan\_installments.outstandingPrincipal} \equiv \text{GL Asset Account (1002 - ঋণ বিতরণ)}$$
3. **ক্যাশ ও ব্যাংক রিকনসিলিয়েশন:**
   $$\text{fact\_daily\_cashbook.closingBalance} \equiv \text{GL Asset Account (1001 - ক্যাশ বাক্স)} + \text{GL Asset (1003 - ব্যাংক হিসাব)}$$

> [!IMPORTANT]
> ওয়্যারহাউজ কোনো ড্রাফট বা আনপোস্টেড ভাউচার হিসাব করবে না। শুধুমাত্র পোস্টকৃত (`posted`) জাবেদা থেকেই ফ্যাক্ট টেবিল আপডেট হবে।

---

## ২. পোর্টফোলিও অ্যাট রিস্ক (Portfolio-at-Risk - PAR) সূত্র
সমবায়ের ঋণ ঝুঁকি পরিমাপের আন্তর্জাতিক মানদণ্ড:
- **PAR 30 (১ - ৩০ দিন বকেয়া):** সাধারণ বিলম্বিত কিস্তি (Standard Watchlist)
- **PAR 60 (৩১ - ৬০ দিন বকেয়া):** সাব-স্ট্যান্ডার্ড ঋণ (Substandard Loan)
- **PAR 90 (৬১ - ৯০ দিন বকেয়া):** সন্দেহজনক ঋণ (Doubtful Debt)
- **PAR 90+ (> ৯০ দিন বকেয়া):** মন্দ ও অনাদায়ী ঋণ (Bad/Loss Debt)

$$\text{PAR } X\% = \frac{\text{যেসব ঋণের বকেয়া } > X \text{ দিন তাদের সর্বমোট অবশিষ্ট আসল ব্যালেন্স}}{\text{সমিতির মোট বিতরণকৃত ঋণের অবশিষ্ট আসল ব্যালেন্স}} \times 100$$

---

## ৩. সোর্স-টু-টার্গেট ডাটা লিনিয়েজ (Data Lineage Map)
```
[Firestore: deposits] ──────> [ETL: cleanse & cast to Poisha] ───> [fact_savings_transactions] ───> [BI: সঞ্চয় প্রবৃদ্ধি]
[Firestore: loans] ─────────> [ETL: split principal & profit] ───> [fact_loan_installments] ────> [BI: PAR 30/60/90]
[Firestore: journals] ──────> [ETL: double-entry integrity] ────> [fact_journal_entries] ──────> [BI: ট্রায়াল ব্যালেন্স]
```
প্রতিটি ট্রান্সফরমেশন ভার্সন ও এক্সিকিউশন টাইমস্ট্যাম্প অডিট লগে ক্রিপ্টোগ্রাফিক হ্যাশ সহ সংরক্ষিত থাকে।
