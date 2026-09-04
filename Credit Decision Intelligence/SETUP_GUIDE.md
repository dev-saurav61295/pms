# Setup Guide - One Space Credit Decision Intelligence

## 1. Objective
Create a One Space demonstration that can answer borrower-level, policy-level, comparative and portfolio-level credit questions using two deliberately separated evidence collections.

## 2. Collections

### Collection A - Credit Structured Data
Ingest the contents of `Credit_Structured_Data_Collection.zip`.

Files:
- customer_master.csv
- credit_applications.csv
- financial_performance.csv
- repayment_behavior.csv
- banking_behavior.csv
- bureau_profile.csv
- gst_performance.csv
- collateral.csv
- customer_concentration.csv
- DATA_DICTIONARY.md

Primary joins:
- `borrower_id` across borrower-level tables.
- `application_id` for the application record.

Do not join by legal name when an ID exists.

### Collection B - Credit Documents
Ingest the contents of `Credit_Document_Collection.zip`.

Files:
- Credit_Policy_Working_Capital_v1.0.md
- Credit_Risk_Rating_Guide_v1.0.md
- Relationship_Manager_Visit_Notes.md
- Collateral_Valuation_Reports.md
- Historical_Credit_Committee_Notes.md
- Previous_Sanction_Summary.md

Recommended metadata where supported:
- document_type
- borrower_id
- application_id
- policy_version
- effective_date
- document_date
- source_system

## 3. Agents
Create three agents if One Space orchestration supports sub-agents.

### Agent 1 - Credit Decision Intelligence (Master)
Purpose: own the user conversation, request evidence from both specialists, reconcile it, apply documented policy and return the human-review recommendation.

Recommended model settings:
- Temperature: 0.1-0.2
- Deterministic/reasoning-oriented configuration preferred.

Paste the Master Agent prompt from `Credit_Decision_Intelligence_Prompts.md`.

### Agent 2 - Structured Credit Data Specialist
Purpose: retrieve/join structured facts and make deterministic calculations. It must not make the final credit recommendation.

Recommended settings:
- Temperature: 0
- Connect only to Collection A / structured tools.

Paste its prompt from the prompt file.

### Agent 3 - Credit Policy and Document Evidence Specialist
Purpose: retrieve exact policy clauses and borrower-document evidence; classify management statements versus observations and preserve conflicts.

Recommended settings:
- Temperature: 0-0.2
- Connect only to Collection B / document RAG.
- Suggested Top-K: 8-12 if configurable.

## 4. Orchestration rule
For simple factual structured questions, the master may call only the structured specialist.
For pure policy questions, it may call only the document specialist.
For any recommendation, compliance, risk synthesis, exception, comparison or "why" question that depends on both facts and policy, the master should call both relevant specialists.

Do not let the master independently invent structured facts or policy thresholds.

## 5. RAG guidance
If chunk configuration is available:
- target chunk size: approximately 800-1,200 tokens;
- overlap: approximately 100-150 tokens.

Preserve headings during chunking when possible. Policy sections should remain identifiable by document name/version.

## 6. Borrower boundary test
Before the demo, verify that asking about C001 never returns C008's 58% concentration or another borrower's collateral. Cross-borrower contamination is a hard failure.

## 7. Conflict test
Ask: `What was Apex Auto Components' FY2026 revenue?`
Expected behavior:
- structured financial record = INR 420 million;
- RM visit note = management statement of approximately INR 440 million;
- agent should state that the sources differ and should not silently pick INR 440 million as audited fact.

## 8. Missing-information test
Ask: `What was FreshRoute's FY2023 revenue?`
Expected behavior: the agent should say the available information does not establish FY2023 revenue. It must not extrapolate.

## 9. Calculation test
Ask: `How much additional realizable collateral does Delta Engineering need to meet policy?`
Expected deterministic calculation:
- proposed exposure = INR 80 million;
- required coverage = 1.25x;
- required realizable value = INR 100 million;
- existing realizable value = INR 88 million;
- shortfall = **INR 12 million**.

## 10. Human-authority test
Ask: `Who has authority for Apex's INR 90 million proposed exposure?`
Expected: Regional Credit Committee, because the synthetic policy places >INR 50 million and <=INR 100 million with that authority.

## 11. Production-like response design
For recommendations, show:
- recommendation category;
- executive summary;
- three-year financial trend;
- conduct/bureau/revenue/collateral assessment;
- policy compliance table;
- exceptions/referrals;
- conditions;
- missing information;
- source references.

## 12. Event demo runbook
Recommended sequence:
1. `Give me a complete credit assessment for APP001 / Apex Auto Components.`
2. `Why? Show every material policy check.`
3. `What human approval authority applies?`
4. `Now analyze EcoBuild and explain why the conclusion changes.`
5. `Which financially strong borrower still has a hidden business risk?`
6. `Which applicant could become policy-compliant through additional collateral?`
7. `How much additional realizable collateral is needed?`
8. `Give me a portfolio summary and identify cases needing committee intervention.`

## 13. Do not ingest QA answers
The testing guide contains expected outcomes. Keep it outside the RAG/agent collections so it cannot leak the answer to the agent during evaluation.
