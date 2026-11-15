# PAYMENT_GATEWAY_ARCHITECTURE.md — Provider-Agnostic Gateway Adapter Engine

## 1. Gateway Adapter Pattern
The platform abstracts all payment channels behind a uniform contract:

```dart
abstract class PaymentGatewayAdapter {
  Future<PaymentInitiationResult> initiatePayment(PaymentInitiationRequest request);
  Future<PaymentVerificationResult> verifyPayment(PaymentVerificationRequest request);
  Future<RefundResult> initiateRefund(RefundRequest request);
  Future<SettlementReport> fetchSettlement(String settlementDate);
  Future<GatewayHealthStatus> checkHealth();
}
```

## 2. Supported Concrete Adapters
- `BkashTokenizedAdapter`: Implements `createPayment`, `executePayment`, `queryPayment`, `refundPayment`.
- `NagadMerchantAdapter`: Implements public-key encrypted checkout, server verification, and payment check API.
- `SslcommerzHostedAdapter`: Implements session creation, IPN webhook listener, and `val_id` order validation.
- `BankWireManualAdapter`: Implements manual deposit slips, branch verification, and maker-checker approval.

## 3. Plug-and-Play Extensibility
Adding a future provider (e.g. Upay, Rocket, City Touch API) requires only implementing `PaymentGatewayAdapter` without modifying existing savings, loans, or accounting business logic.
