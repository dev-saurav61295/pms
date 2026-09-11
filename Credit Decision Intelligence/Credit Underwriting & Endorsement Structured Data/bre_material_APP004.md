# BRE MATERIAL BUNDLE - APP004

record_type=bre_material_results_by_application
logical_source_file=bre_rule_results.csv
application_id=APP004
borrower_id=C004
bre_run_id=BRE-APP004-20260908
overall_bre_status=EXCEPTION_REVIEW_REQUIRED
record_boundary=APP004_MATERIAL_ONLY
representation=retrieval_safe_atomic_line
pass_count=13
fail_count=1
refer_count=0
caution_count=0
hard_stop_count=0
specialist_review_required=Yes
exception_or_review_class=Collateral
routing_path=Senior Credit Risk Specialist
summary_reason=Collateral coverage 1.10x is below 1.25x but within policy exception range.
base_sanction_authority=Regional Credit Committee
run_date=2026-09-08
material_non_pass_rule_count=1

MATERIAL_RULE|application_id=APP004|borrower_id=C004|bre_run_id=BRE-APP004-20260908|rule_id=R11|rule_name=Realizable collateral coverage|actual_value=1.1|threshold_or_rule=>=1.25x; 1.00-1.24 exception/additional collateral; <1.00 Credit Committee exception|bre_outcome=FAIL|severity=Medium|exception_or_referral_route=Additional collateral or approved exception|source_field=collateral.realizable_coverage_x|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP004_R11_ONLY

END_MATERIAL_BUNDLE|application_id=APP004|bre_run_id=BRE-APP004-20260908|record_count=1
