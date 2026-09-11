# Credit Underwriting & Endorsement Intelligence - Data Dictionary

**Purpose:** Synthetic demo data for One Space underwriting, BRE, specialist exception review, endorsement, decision lineage, and beyond-underwriting monitoring.

## Files

- `bre_rule_results.csv` - one row per application/rule result produced by the synthetic BRE.
- `bre_summary.csv` - application-level BRE status and routing path.
- `credit_exception_matrix.csv` - which failures/referrals are reviewable, required specialist role, and exception authority.
- `specialist_registry.csv` - synthetic certified specialist roles and delegated review/endorsement scope.
- `specialist_scorecard.csv` - completed synthetic professional scorecards for selected exception/referral cases.
- `endorsement_register.csv` - specialist endorsement outcome, conditions, rationale, and next authority.
- `underwriting_case_summary.csv` - compact current stage across BRE, specialist review, endorsement, and next action.
- `decision_audit_log.csv` - stage-by-stage decision lineage.
- `underwriting_assumption_register.csv` - assumptions/compensating factors to monitor if a case is sanctioned.

## Linking keys

- `application_id` links to the existing `credit_applications.csv`.
- `borrower_id` links to the existing `customer_master.csv`.
- `review_id` links specialist scorecards to endorsement records.
- `specialist_id` links specialist decisions to the synthetic specialist registry.

## Important interpretation

BRE results are deterministic rule outputs. A BRE failure is not automatically a final decline unless the exception policy marks the condition as non-overrideable. Specialist scores and endorsements are human-professional workflow evidence. They are not final sanction decisions.
