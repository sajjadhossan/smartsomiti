# QR_PAYMENT.md — Dynamic Bangla QR & Payment Code Generation

## 1. QR Modes
1. **Dynamic Installment QR**: Generated on-the-fly for a specific monthly savings installment or loan repayment. Includes: `societyId`, `memberId`, `voucherType`, `amountInPoisha`, `tokenUuid`, `expiresAt` (valid for 15 minutes).
2. **Static Member Passbook QR**: Printed on member ID card or digital passbook for quick identification by field collectors.

## 2. Replay & Anti-Tamper Defense
- Each dynamic QR payload is cryptographically signed with an HMAC token.
- Once a dynamic QR payment is verified, the `tokenUuid` is immediately invalidated. Re-scanning returns `EXPIRED_OR_ALREADY_USED`.
