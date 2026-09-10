# One Space Event Demo - Credit Decision Intelligence

## Purpose
This package is a synthetic, event-ready SME/corporate working-capital credit intelligence demonstration for One Space. It is designed to show how One Space can combine structured enterprise data, unstructured documents, policy evidence, calculations, conversational context and human-review recommendations.

It brings together applicant data, financial indicators, collateral information, policy rules, approval authority, and contextual risk signals to answer not only "Should we approve this?" but also "Why?", "What policy applies?", "Who needs to approve it?", and "What can be done to make the case acceptable?"

In the demo, it can:
- Assess an individual application end-to-end
- Identify strengths, weaknesses, policy breaches, and exceptions
- Explain the recommendation using specific evidence and policy checks
- Determine the required human approval or escalation authority
- Compare borrowers side by side
- Identify financially strong applicants with hidden risk
- Find applicants that can become compliant through remediation
- Calculate required additional collateral or security
- Summarize the whole portfolio for a Credit Committee

The value is that it moves credit analysis from a document/data lookup exercise to a decision-support system that combines evidence, policy, risk, and remediation into one explainable workflow.

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


## Demo Questions

Use these questions in this order:

1. "Give me a complete credit assessment of APP001 for Apex Auto Components Pvt Ltd. Include the applicant profile, facility request, financial position, key risks, policy/compliance status, collateral position, and your final recommendation."
2. "Why did you reach that recommendation for Apex? Show me the specific policy checks, thresholds, exceptions, and evidence that influenced the decision."
3. "What human authority or approval level applies to APP001? Explain who should review or approve this case and why."
4. "Compare Apex Auto Components with EcoBuild. Which is the stronger credit case, what are the major differences, and how should the bank treat them differently?"
5. "Among the financially strong borrowers, which applicant still has a significant hidden risk that management should not overlook?"
   - Expected demo reveal: **Horizon**.
6. "Which currently non-compliant applicant could become compliant if additional security or collateral is provided?"
   - Expected demo reveal: **Delta**.
7. "For Delta, how much additional realizable collateral is required to become compliant, and show me how you calculated it?"
   - Expected demo result: **INR 12 million**.
8. "Now give me a Credit Committee summary across the portfolio. Rank the applicants by decision readiness and risk, identify approvals, declines, conditional cases and escalation items, and tell the committee what actions should be taken next."

## Workflow

Loan Application
      │
      ▼
Data / Document Validation
      │
      ▼
BRE Engine
Deterministic Policy Rules
      │
      ├──────────── PASS ─────────────┐
      │                               │
      │                               ▼
      │                        Underwriting
      │                        Intelligence
      │
      └──── FAIL / REFER / EXCEPTION
                      │
                      ▼
             Exception Intelligence
                      │
             Is failure overrideable?
                      │
             ┌────────┴────────┐
             │                 │
            NO                YES
             │                 │
         Decline /         Specialist
         Stop              Review
                              │
                              ▼
                     Specialist Scorecard
                     + Compensating Factors
                     + Professional Judgement
                              │
                              ▼
                       Endorsement Layer
                              │
                              ▼
                   Approval Authority /
                    Credit Committee
                              │
                              ▼
                    Post-Sanction Monitoring