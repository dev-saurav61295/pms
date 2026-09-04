# One Space Event Demo - Credit Decision Intelligence

## Purpose
This package is a synthetic, event-ready SME/corporate working-capital credit intelligence demonstration for One Space. It is designed to show how One Space can combine structured enterprise data, unstructured documents, policy evidence, calculations, conversational context and human-review recommendations.

## Demo positioning
**Do not position this as an autonomous lending engine.** Position it as an evidence-backed decision-support system for authorized credit professionals. Final sanction, decline and policy-exception authority remains human.

## What is included
1. `Credit_Structured_Data_Collection.zip` - ingestible structured borrower/application datasets.
2. `Credit_Document_Collection.zip` - ingestible synthetic policy and borrower documents.
3. `Credit_Decision_Intelligence_Prompts.md` - master and two specialist prompts.
4. `SETUP_GUIDE.md` - recommended One Space setup and verification steps.
5. `Credit_Decision_Intelligence_Testing_Guide.docx` - scripted test plan, question bank and expected behavior.

## Recommended architecture
```text
USER
  |
  v
CREDIT INTELLIGENCE MASTER
  |------------------------------|
  v                              v
STRUCTURED CREDIT DATA       POLICY / DOCUMENT AGENT
  |                              |
CRM/LOS/LMS/Financials       Policy/RM Notes/Valuation/Committee Notes
  |                              |
  |------------------------------|
                 |
                 v
        EVIDENCE + POLICY SYNTHESIS
                 |
                 v
        HUMAN CREDIT RECOMMENDATION
```

## Synthetic borrower scenarios
| Borrower | Intended scenario | Expected recommendation category |
|---|---|---|
| C001 Apex Auto Components | Strong, policy-compliant growth case | RECOMMEND APPROVAL |
| C002 BluePeak Textiles | Deteriorating financials | POLICY EXCEPTION REQUIRED |
| C003 Crestline Foods | Healthy financials but 45-day DPD event | REFER FOR ENHANCED CREDIT REVIEW / committee referral |
| C004 Delta Engineering | Strong case with collateral shortfall | CONDITIONAL RECOMMENDATION |
| C005 EcoBuild Materials | Multiple severe weaknesses | NOT RECOMMENDED |
| C006 FreshRoute Logistics | Fast growth but <3 years operating history | POLICY EXCEPTION REQUIRED |
| C007 GreenLeaf Packaging | Strongest clean profile | RECOMMEND APPROVAL |
| C008 Horizon Medical Supplies | Strong numbers but 58% single-customer concentration | REFER FOR ENHANCED CREDIT REVIEW |

## Important intentional test condition
C001 has an intentional conflict:
- structured FY2026 revenue = INR 420 million;
- RM visit note contains a management statement of approximately INR 440 million.

A correct agent must preserve the conflict and identify the RM value as a management statement, not silently overwrite the structured record.

## What NOT to ingest
Do not ingest the testing guide or expected-outcome tables into the production/demo knowledge collections. They are QA material and would leak expected answers to the model.

## Suggested event sequence
1. Ask for a full assessment of APP001 / Apex.
2. Ask "Why? Show the policy checks."
3. Ask "What human authority applies?"
4. Compare with EcoBuild.
5. Ask which financially strong borrower still has hidden risk; expect Horizon.
6. Ask which applicant can become compliant through more security; expect Delta.
7. Ask how much additional realizable collateral Delta needs; expect INR 12 million.
8. Finish with a portfolio/committee summary.

## Safety and governance
- No protected personal characteristics are included or required.
- Use only synthetic data for the event.
- Agent recommendations must remain advisory.
- Use evidence citations/source references where One Space supports them.
