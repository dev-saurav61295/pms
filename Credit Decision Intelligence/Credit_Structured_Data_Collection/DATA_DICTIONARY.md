# Structured Credit Data Dictionary

All records are synthetic and intended only for the One Space event demonstration. Monetary fields ending in `_inr_mn` are INR million.

## Join keys
- `borrower_id`: canonical borrower key across all borrower-level datasets.
- `application_id`: canonical application key in `credit_applications.csv`.

## Files
- `customer_master.csv`: legal entity and relationship context.
- `credit_applications.csv`: facility request and purpose.
- `financial_performance.csv`: three-year financial series.
- `repayment_behavior.csv`: DPD and servicing conduct.
- `banking_behavior.csv`: account flows, utilisation, returns and revenue variance.
- `bureau_profile.csv`: commercial bureau and external exposure.
- `gst_performance.csv`: audited revenue versus GST-reported turnover.
- `collateral.csv`: property values and realizable coverage.
- `customer_concentration.csv`: customer/supplier concentration indicators.

## Important
Do not use legal name as the join key. Use `borrower_id`. Do not infer missing values.
