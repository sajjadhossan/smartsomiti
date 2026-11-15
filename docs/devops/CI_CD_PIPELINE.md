# Enterprise CI/CD Pipeline & Build Automation Manual

## ১. পাইপলাইন ধাপসমূহ (Pipeline Stages)
1. **Lint & Static Analysis**: `dart analyze` ও ফরম্যাট চেকার।
2. **Unit & Financial Regression Tests**: ডাবল-এন্ট্রি লেজার, এআই ভ্যালিডেশন, অফলাইন আইডেমপোটেন্সি ও সিকিউরিটি রুলস টেস্ট।
3. **Build Artifacts**:
   - Web: `flutter build web --release`
   - Android: `flutter build apk --release` (Java 17, Gradle Wrapper)
4. **Security & Vulnerability Scan**: সিক্রেট ডিটেকশন ও ডিপেন্ডেন্সি অডিট।
5. **Staging Auto-Deploy**: টেস্ট সার্ভারে স্বয়ংক্রিয় ডিপ্লয় ও স্মোক টেস্ট।
6. **Production Gate & Approval**: ম্যানুয়াল অনুমোদন সাপেক্ষে প্রোডাকশনে ট্রাফিক রোলআউট।

## ২. রোলব্যাক সুরক্ষা (Automated Rollback Trigger)
- ডিপ্লয়মেন্ট পরবর্তী ১০ মিনিটের মধ্যে যদি ৫xx এরর রেট > ১% বৃদ্ধি পায় বা হেলথচেক ব্যর্থ হয়, পাইপলাইন স্বয়ংক্রিয়ভাবে পূর্ববর্তী স্টেবল ভার্সনে রোলব্যাক ট্রিগার করে।
