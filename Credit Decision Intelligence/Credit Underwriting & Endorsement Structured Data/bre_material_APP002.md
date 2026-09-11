# BRE MATERIAL BUNDLE - APP002

## MATERIAL BRE RULE R07 — APP002

Application ID: APP002
Borrower ID: C002
BRE Run ID: BRE-APP002-20260908
Rule ID: R07
Rule Name: DSCR
Actual Value: 1.18
Required Threshold: minimum 1.25x
BRE Outcome: FAIL
Severity: High
Exception or Referral Route: Financial exception review
Source Field: financial_performance.dscr
Policy Version: Credit Policy - Working Capital v1.0
Evaluated On: 2026-09-08
Record Boundary: APP002_R07_ONLY

record_type=bre_material_results_by_application
logical_source_file=bre_rule_results.csv
application_id=APP002
borrower_id=C002
bre_run_id=BRE-APP002-20260908
overall_bre_status=EXCEPTION_REVIEW_REQUIRED
record_boundary=APP002_MATERIAL_ONLY
representation=retrieval_safe_atomic_line
pass_count=11
fail_count=2
refer_count=0
caution_count=1
hard_stop_count=0
specialist_review_required=Yes
exception_or_review_class=Financial / Liquidity
routing_path=Senior Credit Risk Specialist
summary_reason=DSCR and current ratio below policy; utilisation in caution band.
base_sanction_authority=Regional Credit Committee
run_date=2026-09-08
material_non_pass_rule_count=3

MATERIAL_RULE|application_id=APP002|borrower_id=C002|bre_run_id=BRE-APP002-20260908|rule_id=R07|rule_name=DSCR|actual_value=1.18|threshold_or_rule=>=1.25x|bre_outcome=FAIL|severity=High|exception_or_referral_route=Financial exception review|source_field=financial_performance.dscr|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP002_R07_ONLY
MATERIAL_RULE|application_id=APP002|borrower_id=C002|bre_run_id=BRE-APP002-20260908|rule_id=R08|rule_name=Current ratio|actual_value=1.05|threshold_or_rule=>=1.10x|bre_outcome=FAIL|severity=Medium|exception_or_referral_route=Liquidity exception review|source_field=financial_performance.current_ratio|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP002_R08_ONLY
MATERIAL_RULE|application_id=APP002|borrower_id=C002|bre_run_id=BRE-APP002-20260908|rule_id=R10|rule_name=Average facility utilisation|actual_value=92|threshold_or_rule=up to 90 acceptable; above 90 through 95 caution; above 95 review|bre_outcome=CAUTION|severity=Medium|exception_or_referral_route=Analyst comment required|source_field=banking_behavior.avg_limit_utilisation_pct|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP002_R10_ONLY

END_MATERIAL_BUNDLE|application_id=APP002|bre_run_id=BRE-APP002-20260908|record_count=3
