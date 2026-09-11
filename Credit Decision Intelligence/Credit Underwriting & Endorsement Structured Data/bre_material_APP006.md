# BRE MATERIAL BUNDLE - APP006

record_type=bre_material_results_by_application
logical_source_file=bre_rule_results.csv
application_id=APP006
borrower_id=C006
bre_run_id=BRE-APP006-20260908
overall_bre_status=EXCEPTION_REVIEW_REQUIRED
record_boundary=APP006_MATERIAL_ONLY
representation=retrieval_safe_atomic_line
pass_count=13
fail_count=1
refer_count=0
caution_count=0
hard_stop_count=0
specialist_review_required=Yes
exception_or_review_class=Operating History
routing_path=Senior Credit Risk Specialist
summary_reason=Operating history 2.4 years is below 3-year minimum; compensating indicators are otherwise acceptable.
base_sanction_authority=Branch Credit Manager
run_date=2026-09-08
material_non_pass_rule_count=1

MATERIAL_RULE|application_id=APP006|borrower_id=C006|bre_run_id=BRE-APP006-20260908|rule_id=R01|rule_name=Operating history|actual_value=2.4|threshold_or_rule=>=3 completed years|bre_outcome=FAIL|severity=Medium|exception_or_referral_route=Operating-history exception review|source_field=customer_master.operating_years|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP006_R01_ONLY

END_MATERIAL_BUNDLE|application_id=APP006|bre_run_id=BRE-APP006-20260908|record_count=1
