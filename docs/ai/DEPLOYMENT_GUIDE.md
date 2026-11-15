# PHASE 8 DEPLOYMENT & CLOUD FUNCTIONS GUIDE

## 1. Prerequisites
- Google Cloud Project with Billing Enabled.
- Firebase CLI (`firebase-tools`) installed.
- Secret Manager API enabled: `gcloud services enable secretmanager.googleapis.com`.
- Vertex AI API enabled: `gcloud services enable aiplatform.googleapis.com`.

## 2. Storing Secrets in Google Secret Manager
Execute the following commands to store provider API keys securely:
```bash
echo -n "YOUR_GEMINI_API_KEY" | gcloud secrets create GEMINI_API_KEY --data-file=-
echo -n "YOUR_CLAUDE_API_KEY" | gcloud secrets create CLAUDE_API_KEY --data-file=-
```
Assign IAM permissions to the Cloud Functions service account:
```bash
gcloud secrets add-iam-policy-binding GEMINI_API_KEY \
    --member="serviceAccount:${PROJECT_ID}@appspot.gserviceaccount.com" \
    --role="roles/secretmanager.secretAccessor"
```

## 3. Firestore Rules Deployment
Deploy the updated security rules ensuring zero public access to AI conversation metadata and risk alerts:
```bash
firebase deploy --only firestore:rules
```

## 4. Cloud Functions Deployment
Deploy the backend AI router and analytics aggregation functions:
```bash
firebase deploy --only functions:aiChatRouter,functions:generateDailyAnalyticsSnapshot,functions:detectFinancialAnomalies
```
