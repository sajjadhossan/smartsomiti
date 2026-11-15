# PHASE 5: UPGRADE, DOWNGRADE & PRORATION SPECIFICATION

**Project:** Multi-Society Cooperative Management SaaS Platform  
**Target:** Safe Plan Transitions, Prorated Billing & Quota Restrictions  

---

## 1. Upgrade Rules (Immediate Activation)
- **Calculation**: Unused value of current plan is credited toward the upgraded tier:
  $$\text{Unused Credit} = \text{Current Plan Rate} \times \left(\frac{\text{Days Remaining}}{\text{Total Plan Days}}\right)$$
  $$\text{Net Upgrade Charge} = \max(0, \text{Target Plan Rate} - \text{Unused Credit})$$
- Immediately provisions expanded member limits, staff seats, and unlocked modules upon payment verification.

---

## 2. Downgrade Rules (Non-Destructive Transition)
- **Principle of Non-Destruction**: Downgrades only restrict future creation beyond lower quota thresholds. Existing members, ledger entries, and historical reports remain 100% accessible in read-only format.
- Scheduled downgrades take effect at the end of the current paid billing cycle.
