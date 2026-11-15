# SUBSCRIPTION_TEST_REPORT.md — SaaS Subscription Engine Test Execution Plan

## 1. Test Suite Coverage Matrix

| Test Suite / Area | Test Scenarios | Verification Method |
| :--- | :--- | :--- |
| **Integer Poisha Math** | Plan price calculation, 5% / 15% VAT, Coupon discounts | Deterministic integer arithmetic tests |
| **Lifecycle State Machine** | 13 lifecycle states transition validation | `SaasSubscriptionModel.canTransitionTo` state checks |
| **Entitlement Resolution** | Feature limits, member quota enforcement, module gates | Mock society quota vs. plan tier limits |
| **Invoice Generation** | Number sequencing (`INV-YYYYMM-XXXXX`), subtotal/tax matching | Invoicing service test |
| **Payment Verification** | Idempotency key replay defense, amount matching, auto-activation | Webhook verification test |
| **Revenue Accounting** | MRR / ARR calculation, segregated commercial ledger posting | Accounting service integration test |

## 2. Execution Log
All unit tests are executed in `test/saas_subscription_test.dart` and must output 100% green pass.
