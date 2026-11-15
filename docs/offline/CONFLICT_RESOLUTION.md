# CONFLICT DETECTION & RESOLUTION POLICIES

## 1. Conflict Scenarios in Distributed Microfinance
In field cooperative operations, conflicts occur when:
1. **Concurrent Member Modification**: An office staff member updates member contact info online while a field officer takes an address note offline.
2. **Prior Settlement / Reversal**: A loan installment was marked paid or rescheduled at the branch while the field officer was offline collecting the same installment.
3. **Account Suspension**: A member was placed on legal hold or suspended by the Executive Committee while the officer was offline in the field.

## 2. Policy Matrix by Domain
| Domain | Conflict Resolution Strategy | Automated Action | Human Requirement |
| :--- | :--- | :--- | :--- |
| **Financial (Cash/Savings/Loan)** | **Server-Authoritative Hold** | Mark `REQUIRES_REVIEW` | Branch Cashier & Manager Reconciliation |
| **Member Profile (Non-Financial)** | **Field-Level Granular Merge** | Merge disjoint fields | None (Auto-merged) |
| **Operational Tasks** | **Latest Timestamp Wins** | Update task state | Supervisor review if rejected |
| **Documents / KYC** | **Additive Append** | Append new photo version | KYC Officer verification |

## 3. Strict Financial Invariant
Financial operations are **never** resolved by "Last Write Wins". If a member's loan was already settled at the branch, the field collection amount enters an unallocated escrow account (`Account 2190 - Suspense Clearing`) until an authorized cashier reviews and credits it to savings or issues a refund.
