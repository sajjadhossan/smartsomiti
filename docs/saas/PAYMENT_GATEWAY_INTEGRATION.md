# PHASE 5: PAYMENT GATEWAY INTEGRATION & SECURITY ARCHITECTURE

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** bKash, Nagad, SSLCOMMERZ & Bank Transfer Verification  

---

## 1. Supported Commercial Gateways in Bangladesh

1. **bKash Tokenized Merchant Checkout**:
   - `createPayment` -> `executePayment` server-to-server handshake.
   - Immediate verification of payment amount, merchant number, and transaction ID (`TrxID`).
2. **Nagad Merchant Direct API**:
   - Private key signed order initialization and callback payment verification.
3. **SSLCOMMERZ Hosted Gateway**:
   - Session initiation (`gw.sslcommerz.com/gwprocess/v4/api.php`).
   - Server-side IPN validation via `validator/api/validationserverAPI.php`.
4. **Manual Commercial Bank Transfer**:
   - Offline deposit to Platform Bank Account (e.g., City Bank PLC).
   - Society uploads bank transaction memo number & deposit slip.
   - Super Admin validates and marks invoice paid.

---

## 2. Idempotent Processing & Callback Validation
- Every payment verification request requires a unique `idempotencyKey` (`idemp_pay_...`).
- Double-payment prevention: If callback is re-sent by gateway, previous processed result is returned without re-crediting the invoice or extending the subscription twice.
