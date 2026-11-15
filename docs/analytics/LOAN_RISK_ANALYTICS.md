# LOAN & CREDIT RISK ANALYTICS SPECIFICATION

## 1. Credit Risk Overview & Portfolio Metrics
The Loan Risk engine provides transparent, explainable credit risk assessment. It evaluates the cooperative's loan portfolio health using standard microfinance industry indicators:

### 1. Portfolio at Risk (PAR):
$$\text{PAR}_{30} = \frac{\text{Total Outstanding Principal of Loans with Installment Overdue} > 30\text{ Days}}{\text{Total Outstanding Loan Portfolio}} \times 100\%$$
$$\text{PAR}_{60} = \frac{\text{Total Outstanding Principal of Loans with Installment Overdue} > 60\text{ Days}}{\text{Total Outstanding Loan Portfolio}} \times 100\%$$
$$\text{PAR}_{90} = \frac{\text{Total Outstanding Principal of Loans with Installment Overdue} > 90\text{ Days}}{\text{Total Outstanding Loan Portfolio}} \times 100\%$$

Cooperative Regulatory Benchmark: $\text{PAR}_{30} \le 5.0\%$.

## 2. Configurable Risk Indicators
1. **Missed Installment Velocity**: Sudden gap of 2 or more installments in a previously regular borrower.
2. **Guarantor Over-Commitment**: A single member acting as guarantor for more than 3 active loans simultaneously.
3. **Savings-to-Loan Ratio Discrepancy**: Outstanding loan exceeds 5 times the member's accumulated savings balance without additional collateral.

## 3. Human Approval Boundary
AI risk scoring outputs an **Explainability Card** citing exact repayment dates and missed amounts. It **never** automatically rejects or approves loans. Final credit decisions must follow Phase 3 multi-level human approvals.
