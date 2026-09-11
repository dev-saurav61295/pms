# BRE MATERIAL BUNDLE - APP003

record_type=bre_material_results_by_application
logical_source_file=bre_rule_results.csv
application_id=APP003
borrower_id=C003
bre_run_id=BRE-APP003-20260908
overall_bre_status=REFER_SPECIALIST
record_boundary=APP003_MATERIAL_ONLY
representation=retrieval_safe_atomic_line
pass_count=13
fail_count=0
refer_count=1
caution_count=0
hard_stop_count=0
specialist_review_required=Yes
exception_or_review_class=Conduct
routing_path=Credit Conduct Specialist
summary_reason=45-day DPD triggers Credit Committee referral; otherwise credit profile is supportable.
base_sanction_authority=Branch Credit Manager
run_date=2026-09-08
material_non_pass_rule_count=1

MATERIAL_RULE|application_id=APP003|borrower_id=C003|bre_run_id=BRE-APP003-20260908|rule_id=R06|rule_name=DPD above 30 days|actual_value=45|threshold_or_rule=>30 days: Credit Committee referral|bre_outcome=REFER|severity=High|exception_or_referral_route=Conduct specialist review|source_field=repayment_behavior.max_dpd_12m|policy_version=Credit Policy - Working Capital v1.0|evaluated_on=2026-09-08|record_boundary=APP003_R06_ONLY

END_MATERIAL_BUNDLE|application_id=APP003|bre_run_id=BRE-APP003-20260908|record_count=1
