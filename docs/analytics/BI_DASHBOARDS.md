# ENTERPRISE BUSINESS INTELLIGENCE & EXECUTIVE DASHBOARDS

## 1. Multi-Tiered Executive Dashboard Design
The platform provides role-tailored Executive Dashboards ensuring zero cross-tenant or unprivileged data exposure:

| Dashboard Tier | Primary Target Audience | Primary Visualizations & KPIs |
| :--- | :--- | :--- |
| **Platform Super Admin** | SaaS System Owner (`hossansajjad1994@gmail.com`) | Total Tenant Societies, Platform MRR/ARR, Active AI Tokens, Gateway Uptime, Churn Rate |
| **Society President / Owner** | Cooperative Society Executive Committee | Total Members, Solvency & Liquidity Ratio, Net Annual Surplus, Total Loan Portfolio |
| **Manager & Accountant** | Operational Society Management | Daily Cash Position, Overdue Installments, Bank Reconciliation Status, Pending KYC |
| **Field Officer** | Mobile Collection Staff | Assigned Members, Daily Collection Targets, Route Schedule, Cash Receipt Verification |

## 2. Dashboard Customization & Widget Controls
Super Admin controls widget availability at:
1. Global Platform Level
2. Subscription Tier Level (Starter vs Pro vs Enterprise)
3. User Role Level

Users cannot manually query unauthorized widgets. Widget configurations persist in Firestore under `/somitis/{somitiId}/analytics_widget_configs/{userId}`.
