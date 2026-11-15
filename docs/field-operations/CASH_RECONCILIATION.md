# FIELD CASH RECONCILIATION & MAKER-CHECKER VERIFICATION

## 1. Accounting Formula & Discrepancy Equation
At the conclusion of each collection shift, the field officer must balance:

$$\text{Physical Cash Submitted} == \text{Total Verified Collections} + \text{Opening Float}$$

Where:
$$\text{Total Collections} = \sum \text{Offline Cash Collections} + \sum \text{Spot Direct Payments}$$

### Discrepancy Scenarios:
- **Cash Shortage (ঘাটতি)**: $\text{Physical Cash} < \text{System Total}$. Officer must explain or deposit the difference into `Account 1115 - Staff Cash Shortage Receivable`.
- **Cash Excess (উদ্বৃত্ত)**: $\text{Physical Cash} > \text{System Total}$. Credited to `Account 2190 - Suspense Clearing` pending receipt audit.

## 2. Maker-Checker Separation of Duties
- **Maker**: Field Officer (`emp_field_01`) who collected money in the community.
- **Checker**: Branch Head Cashier (`emp_cashier_01`) who physically counts banknotes and approves the deposit batch.
- **System Constraint**: If `officerId == cashierId`, the transaction is blocked with an error:
  `"Separation of Duties Violation: সংগ্রাহক কর্মকর্তা নিজে ক্যাশিয়ার হিসেবে অনুমোদন করতে পারবেন না!"`
