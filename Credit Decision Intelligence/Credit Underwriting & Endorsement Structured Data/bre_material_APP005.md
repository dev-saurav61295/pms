# BRE MATERIAL BUNDLE - APP005

record_type=bre_material_results_by_application
logical_source_file=bre_rule_results.csv
application_id=APP005
borrower_id=C005
bre_run_id=BRE-APP005-20260908
overall_bre_status=HARD_STOP
record_boundary=APP005_MATERIAL_ONLY
representation=retrieval_safe_atomic_line
pass_count=5
fail_count=6
refer_count=3
caution_count=0
hard_stop_count=0
specialist_review_required=No
exception_or_review_class=Severe combined weakness
routing_path=Remediation before reconsideration
summary_reason=SMA-2, >60 DPD, bureau below 700 and multiple financial/collateral failures.
base_sanction_authority=Branch Credit Manager
run_date=2026-09-08
material_non_pass_rule_count=9

MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R02|rule_name=Commercial bureau score|actual_value=684|threshold_or_rule=>=700|bre_outcome=FAIL|severity=High|exception_or_referral_route=Specialist exception screening|source_field=bureau_profile.commercial_bureau_score|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R02_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R05|rule_name=DPD above 60 days|actual_value=63|threshold_or_rule=>60 days: not normally eligible|bre_outcome=FAIL|severity=Critical|exception_or_referral_route=Severe-conduct exception screening|source_field=repayment_behavior.max_dpd_12m|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R05_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R06|rule_name=DPD above 30 days|actual_value=63|threshold_or_rule=>30 days: Credit Committee referral|bre_outcome=REFER|severity=High|exception_or_referral_route=Conduct specialist review|source_field=repayment_behavior.max_dpd_12m|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R06_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R07|rule_name=DSCR|actual_value=0.92|threshold_or_rule=>=1.25x|bre_outcome=FAIL|severity=High|exception_or_referral_route=Financial exception review|source_field=financial_performance.dscr|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R07_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R08|rule_name=Current ratio|actual_value=0.88|threshold_or_rule=>=1.10x|bre_outcome=FAIL|severity=Medium|exception_or_referral_route=Liquidity exception review|source_field=financial_performance.current_ratio|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R08_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R09|rule_name=Debt / Equity|actual_value=3.1|threshold_or_rule=<=2.50x|bre_outcome=FAIL|severity=High|exception_or_referral_route=Leverage exception review|source_field=financial_performance.debt_equity|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R09_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R10|rule_name=Average facility utilisation|actual_value=98|threshold_or_rule=<=90 acceptable; >90-95 caution; >95 review|bre_outcome=REFER|severity=High|exception_or_referral_route=Credit review|source_field=banking_behavior.avg_limit_utilisation_pct|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R10_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R11|rule_name=Realizable collateral coverage|actual_value=0.8|threshold_or_rule=>=1.25x; 1.00-1.24 exception/additional collateral; <1.00 Credit Committee exception|bre_outcome=FAIL|severity=High|exception_or_referral_route=Credit Committee exception|source_field=collateral.realizable_coverage_x|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R11_ONLY
MATERIAL_RULE|application_id=APP005|borrower_id=C005|bre_run_id=BRE-APP005-20260908|rule_id=R14|rule_name=Account status / material irregularity|actual_value=SMA-2|threshold_or_rule=Material account irregularity triggers credit review|bre_outcome=REFER|severity=High|exception_or_referral_route=Credit review|source_field=repayment_behavior.current_account_status|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP005_R14_ONLY

END_MATERIAL_BUNDLE|application_id=APP005|bre_run_id=BRE-APP005-20260908|record_count=9
