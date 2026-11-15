# NAGAD_INTEGRATION.md — Nagad Merchant Payment Integration

## 1. Security Architecture
Nagad integration uses asymmetric cryptography (PGP / RSA 2048-bit keys):
- Merchant Private Key signs outbound payload (`X-KM-Signature`).
- Nagad Public Key verifies inbound callbacks.
- Merchant ID (`merchantId`) and sensitive fields are encrypted.

## 2. API Endpoints
- Initialize: `POST /check-out/initialize/{merchantId}/{orderId}`
- Complete & Verify: `POST /check-out/complete/{paymentRefId}`
- Payment Verification Check: `GET /verify/payment/{paymentRefId}`
- Integer Poisha Match: Amount is verified strictly in integer Poisha before ledger confirmation.
