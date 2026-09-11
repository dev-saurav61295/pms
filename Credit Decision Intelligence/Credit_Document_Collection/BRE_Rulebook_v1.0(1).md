# BRE Rulebook v1.0

**Effective date:** 01-Sep-2026  
**Document type:** Synthetic Demo Rulebook  
**Purpose:** One Space Credit Intelligence demonstration.

## 1. Role of the BRE
The Business Rules Engine evaluates configured policy tests using authoritative structured borrower values. It returns rule-level results and a routing status. It does not make a final lending decision and does not decide whether professional judgement can override a rule.

## 2. Core rule families
The BRE evaluates operating history, bureau score, suit/write-off flags, DPD, DSCR, current ratio, debt/equity, average utilisation, collateral coverage, customer concentration, GST variance, and material account irregularity. Thresholds come from `Credit_Policy_Working_Capital_v1.0.md`.

## 3. Output statuses
- **PASS** - configured rule satisfied.
- **CAUTION** - policy requires analyst comment but not an exception by itself.
- **REFER** - enhanced or specialist review is required.
- **FAIL** - policy requirement not satisfied; exception screening is required before any further progression.
- **HARD_STOP** - the exception policy marks the condition as non-overrideable for the current stage.

## 4. Routing rule
A FAIL is not the same as a final decline. The BRE sends failures to the exception-screening layer. `Credit_Exception_Review_Policy_v1.0.md` determines whether a failed rule is reviewable, referral-only, or non-overrideable.

## 5. Auditability
Every BRE result must preserve application_id, borrower_id, rule_id, actual value, policy threshold, policy version, result, and evaluation timestamp.
