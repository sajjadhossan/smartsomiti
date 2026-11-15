# INVENTORY_MANAGEMENT.md — Society Inventory & Stock Management

## 1. Inventory Categories
- Office Stationery & Passbooks (Passbook booklets, vouchers, receipt pads).
- IT & Office Consumables (Printer toner, paper, ID card ribbons).
- Promotional Materials (Banners, leaflets, member gifts).

## 2. Stock Movement Types
- `STOCK_OPENING`: Initial balance when onboarding.
- `STOCK_RECEIVING`: Inward from approved procurement orders.
- `STOCK_ISSUE`: Outward to field officers or branches.
- `STOCK_RETURN`: Unused materials returned to store.
- `STOCK_ADJUSTMENT`: Reconciled physical variance (damage/loss).

## 3. Concurrency Protection & Zero Negative Stock
Stock deductions are protected by Firestore transactions. No stock item can fall below zero unless explicitly configured.
Low-stock alerts are triggered when stock reaches `reorderLevel`.
