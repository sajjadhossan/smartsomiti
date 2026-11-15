# PHASE 5: RECURRING BILLING ENGINE & INVOICE MANAGEMENT

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Automated Invoicing, Proration, Tax Calculation & Coupons  

---

## 1. Mathematical Invariants & Precision Money Rules
All calculations operate on integer Poisha:
$$\text{Base Amount} = \text{Plan Rate in Poisha}$$
$$\text{Discount Amount} = \min(\text{Coupon Fixed Poisha}, \lfloor \text{Base Amount} \times \text{Discount \%} \rfloor)$$
$$\text{Taxable Subtotal} = \text{Base Amount} - \text{Discount Amount}$$
$$\text{VAT / Tax (5\%)} = \lfloor \text{Taxable Subtotal} \times 0.05 \rfloor$$
$$\text{Total Payable} = \text{Taxable Subtotal} + \text{VAT}$$

---

## 2. Invoice Data Schema (`/saas_invoices/{invoiceId}`)
- `invoiceNumber`: Unique alphanumeric code (`INV-202611-00001`).
- `societyId`: Bound tenant identifier.
- `billingCycle`: `monthly`, `quarterly`, `annual`.
- `subtotalInPoisha`: Raw price before tax/discount.
- `discountInPoisha`: Applied discount.
- `taxInPoisha`: Calculated government VAT.
- `totalInPoisha`: Net payable amount.
- `amountPaidInPoisha`: Billed payments credited.
- `paymentStatus`: `unpaid`, `partially_paid`, `paid`, `refunded`.
- `paymentMethod`: `bkash`, `nagad`, `sslcommerz`, `bank_transfer`, `cash`.
- `issuedAt`, `dueAt`, `paidAt`: ISO 8601 UTC timestamps with Asia/Dhaka conversion.
