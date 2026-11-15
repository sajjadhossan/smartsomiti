# INVOICE_MANAGEMENT.md — SaaS Invoicing & Billing Lifecycle

## 1. Invoice Numbering Scheme
SaaS invoices follow a strict non-repeating sequential format:
`INV-{YYYY}{MM}-{5-digit-sequence}` (e.g., `INV-202611-00042`).

## 2. Integer Poisha Line Item Model
All financial calculations operate in integer Poisha (1 BDT = 100 Poisha):
- **Base Plan Fee**: e.g., 199,900 Poisha (৳1,999.00)
- **Discount / Coupon**: e.g. -19,990 Poisha (10% off)
- **Subtotal**: Base - Discount
- **VAT / Tax (Standard 5% or 15%)**: Computed via integer division `(Subtotal * TaxRateBps) ~/ 10000`
- **Total Payable**: Subtotal + Tax

## 3. Invoice States
- `draft`: Prepared by Super Admin or system scheduler.
- `pending_payment`: Issued to society; awaiting gateway webhook or bank confirmation.
- `paid`: Payment received and verified; linked to a unique transaction ID.
- `void`: Canceled due to billing adjustment or plan change.
- `refunded`: Returned to society via official credit memo.

## 4. PDF Invoice Generation & Printable A4 Pad
Invoices are rendered with SVG/Canvas letterhead pad, QR Code pointing to public verification endpoint, society details, and automated transaction reference receipt.
