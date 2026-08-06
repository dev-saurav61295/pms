# PMS Questionnaire, SQL, KPI and OneSpace Tool Implementation Plan

**Project:** OneSpace – PMS Question Catalogue and Query Intelligence  
**Last updated:** 5 August 2026  
**Current overall stage:** Phases 0–3 complete for the current base-query set; Phase 4 semantic and identifier hardening in progress

---

## 1. Objective

Create a reliable PMS question catalogue that can answer operational, management, dashboard and executive questions through deterministic data access and approved business logic.

The target solution should:

- Support 150 active natural-language questions.
- Retain simple and direct questions, but tag them clearly.
- Prioritise complex, derived, KPI, dashboard and executive questions where an LLM is more likely to make mistakes.
- Use predefined SQL and KPI logic instead of allowing the LLM to invent joins, filters or calculations.
- Reuse canonical query tools where several natural-language questions can be answered from the same dataset.
- Exclude or defer questions that depend on empty tables.
- Apply RBAC and current-user context at runtime.
- Use the LLM mainly for intent recognition, explanation, summarisation and follow-up conversation.

---

## 2. Target Architecture

```text
Natural-language question
        ↓
Intent / canonical-question matching
        ↓
Predefined Bridge query or KPI tool
        ↓
Runtime parameters and RBAC
        ↓
Live PMS database execution
        ↓
Structured result
        ↓
Optional Mesh explanation or executive summary
        ↓
Orbit tool / dashboard / report output
```

### Component responsibilities

| Component | Responsibility |
|---|---|
| Bridge | Execute deterministic SQL against live PMS data |
| Prism | Retrieve policies, process documents, contracts and supporting knowledge |
| Mesh | Explain results, reason across multiple tool outputs and support follow-up questions |
| Orbit | Package repeatable queries, KPI calculators, watchlists and workflows as reusable tools |

---

## 3. Current Scope

### Active catalogue

| Item | Count |
|---|---:|
| Active PMS questions | 150 |
| Existing questions retained | 100 |
| Existing questions remapped to populated alternatives | 6 |
| New executive, KPI and complex questions | 44 |
| Deferred questions dependent on empty tables | 14 |

### Current SQL verification scope

Only questions already marked as either of the following were included in the first verification run:

- `Mapped – Direct Schema`
- `Mapped – Populated Alternative`

This produced 50 selected SQL queries.

### Verification result

| Result | Count |
|---|---:|
| Passed and returned data | 31 |
| Passed but returned no rows for the selected test parameters | 18 |
| Skipped because a test parameter was unavailable | 1 |
| SQL failures | 0 |
| Total selected queries | 50 |

The first run confirms that the mapped SQL is structurally compatible with the live database. Empty results do not necessarily indicate incorrect SQL; they frequently mean that the selected project, employee, date range or other parameter did not have matching related records.

---

## 4. Current Project Stage

### Overall status

**Current stage: Base-query validation completed; semantic hardening and KPI preparation are next.**

The work is not limited to the 50 queries. Those queries are the validated foundation on top of which the remaining derived, dashboard and executive questions will be implemented.

### Stage summary

| Phase | Status | Progress | Main outcome |
|---|---|---:|---|
| Phase 0 – Scope and schema assessment | Complete | 100% | PMS areas, schema coverage and empty tables identified |
| Phase 1 – Questionnaire reorganisation | Complete | 100% | 150 active questions classified and 14 unsupported questions deferred |
| Phase 2 – Base SQL mapping | Complete for current base set | 100% of selected set | 50 mapped base queries available |
| Phase 3 – Live SQL technical verification | Complete for current base set | 98% executed; 1 parameter skip | 49 executed successfully; 0 SQL failures |
| Phase 4 – Semantic and identifier hardening | In progress | Initial findings available | Business rules and safer identifiers need confirmation |
| Phase 5 – Derived KPI query development | Not started | 0% | Operational and management KPI queries to be created |
| Phase 6 – Executive and composite tools | Not started | 0% | CEO watchlists, health scoring and portfolio exposure tools |
| Phase 7 – UAT, performance and regression | Not started | 0% | Business validation, query tuning and repeatable regression testing |
| Phase 8 – Bridge, Mesh and Orbit implementation | Not started | 0% | Production tools, RBAC, caching and user experience |

---

## 5. Work Completed

### 5.1 Questionnaire preparation

- Prepared and refined a PMS question catalogue.
- Reorganised the catalogue after identifying populated and empty tables.
- Retained simple/direct questions and added explicit complexity tags.
- Added more complex questions suitable for management, KPI and executive use.
- Added audience, business value, derivation logic, data readiness, query strategy and LLM-risk tags.
- Moved unsupported empty-table questions to a deferred section.

### 5.2 Schema and data-coverage analysis

- Identified usable project, task, timesheet, allocation, user, risk, issue and supporting lookup tables.
- Identified empty milestone, estimation, weekly-status, team and other supporting tables that should not drive active questions.
- Identified populated alternative tables where possible.

### 5.3 Base SQL preparation

- Prepared SQL for direct questions and questions that could be remapped to populated alternatives.
- Kept non-direct, derived and business-rule-dependent questions separate.
- Avoided creating SQL where source data or business meaning was unclear.

### 5.4 Live technical verification

- Tested 50 selected SQL queries against the live PMS database.
- Confirmed 49 executed successfully.
- Confirmed no missing-table, missing-column or SQL-syntax failures in the tested set.
- Retrieved real lookup values for project, task, issue and risk status structures.
- Collected `EXPLAIN` output for performance review.

### 5.5 Important live-data findings

- Active project status is `project_status_id = 2`.
- Project stages currently used are Initiation and Implementation, plus unspecified code `0`.
- Task priorities are High, Medium, Low and blank/null.
- Task RAG data is sufficiently populated for dashboard use.
- Project RAG is sparsely populated and should not be the primary health indicator.
- Risk status, priority, probability and impact masters are sufficiently defined for risk KPIs.
- Issue severity and priority are sparsely populated and require careful use.
- Several task, risk and issue reference values may not be globally unique.
- Name-based and reference-only filters should be hardened for production use.

---

## 6. Why Only 50 Queries Were Tested

The questionnaire contains 150 active natural-language questions, but not every question requires a separate SQL statement.

Several questions can reuse the same canonical query. For example:

| Natural-language questions | Reusable canonical tool |
|---|---|
| What is the project status? What stage is it in? Who is the PM? When does it end? | Project Details |
| How many tasks are open? How many are complete? How many are Red? | Project Task Summary |
| How much effort was logged? Who logged the most? What is the burn trend? | Project Effort Summary |
| How many risks are open? What is the total exposure? Which are overdue? | Project Risk Summary |

The intended mapping is:

```text
150 natural-language questions
        ↓
fewer canonical intents and reusable tools
        ↓
base SQL queries
        ↓
derived KPI queries
        ↓
executive composite tools
```

The first 50 queries represent the base-data layer. They validate the most important tables, relationships and common operational outputs before more complex formulas are added.

---

## 7. Next Work Phases

## Phase 4 – Semantic and Identifier Hardening

### Goal

Convert technically valid SQL into production-safe SQL.

### Required changes

- Replace project-title filters with `project_id` or `project_unique_id` where possible.
- Replace employee-name filters with `user_id`.
- Replace task-reference-only filters with `task_id`, or `project_id + task_reference`.
- Replace risk-reference-only filters with `risk_id`, or `project_id + risk_reference`.
- Replace issue-reference-only filters with `issue_id`, or `project_id + issue_reference`.
- Apply `project_status_id = 2` to questions that explicitly ask for active projects.
- Confirm explicit open and closed status sets for tasks and issues.
- Confirm RBAC meaning for “my projects,” “my tasks” and management hierarchy.
- Retest the one skipped department query with a valid populated department.

### Deliverables

- Updated base-query workbook.
- Production identifier column for each query.
- Business-rule status column.
- Verification status column.
- Revised SQL verifier with domain-specific parameter discovery.

### Exit criteria

- Every base query uses a safe, unique runtime identifier.
- No query depends on an unapproved status interpretation.
- All 50 base queries are executed with representative parameters.
- Zero SQL failures.
- Empty results are confirmed as valid business outcomes or corrected test-data issues.

---

## Phase 5 – Operational and Derived KPI Queries

### Goal

Build deterministic SQL for questions requiring aggregation, comparison, trend, exception or derived calculations.

### Initial query batch

- Open tasks by project.
- Overdue open tasks.
- Task completion rate.
- High-priority overdue tasks.
- Red and Amber task concentration.
- Open and overdue issues.
- Issue aging.
- Reopened issues.
- Open and overdue risks.
- Aggregate risk exposure.
- Estimate versus actual effort.
- Effort burn trend.
- Allocation load by resource.
- Timesheet compliance and trend.
- Project inactivity indicators.

### Deliverables

- Derived KPI SQL catalogue.
- KPI definition for every calculation.
- Formula, threshold, denominator and null-handling documentation.
- Live validation result for every KPI query.

### Exit criteria

- Each KPI has an approved business definition.
- The SQL result is reproducible and deterministic.
- The LLM does not calculate the KPI independently.
- Sample outputs are accepted by the PMS business owner.

---

## Phase 6 – Management Dashboard and Executive Questions

### Goal

Implement complex portfolio, leadership and CEO-level questions using approved KPI outputs.

### Proposed executive questions

- Which projects require immediate executive attention?
- Which projects are most likely to miss their end dates?
- Which project managers carry the highest concentration of unhealthy projects?
- Which projects are consuming effort faster than work is being completed?
- Which projects have both high risk exposure and serious unresolved issues?
- Which projects depend too heavily on a single contributor?
- Which resources are overallocated across concurrent projects?
- Which projects show declining performance month over month?
- What requires leadership attention in the next 30, 60 and 90 days?
- How much deal value or committed effort is associated with unhealthy projects?

### Implementation principle

These should be deterministic Orbit KPI or Watchlist Tools.

```text
Base query outputs
        +
Approved KPI calculations
        +
Thresholds and weights
        ↓
Ranked executive watchlist
        ↓
Mesh explanation and recommended actions
```

### Deliverables

- Executive KPI definitions.
- Portfolio-health calculation.
- Executive-attention scoring model.
- 30/60/90-day watchlist.
- Management dashboard query set.
- Sample executive report.

### Exit criteria

- Every score and ranking can be explained from source metrics.
- Weights and thresholds are approved.
- No LLM-generated arithmetic is used as the source of truth.
- Results are validated against a manually reviewed project sample.

---

## Phase 7 – UAT, Performance and Regression

### Goal

Confirm that the queries are technically correct, business-correct and efficient enough for production use.

### Activities

- Run positive test cases where data must be returned.
- Run negative test cases where an empty result is expected.
- Compare output with the PMS UI or trusted reports.
- Validate RBAC using users at different hierarchy levels.
- Review duplicate rows and one-to-many join inflation.
- Review null, blank and unspecified-code handling.
- Review `EXPLAIN` plans and full table scans.
- Recommend indexes where needed.
- Store approved test cases for regression testing.

### Deliverables

- UAT test-case matrix.
- Query verification report.
- Performance-review report.
- Approved regression dataset.
- Signed-off query catalogue.

### Exit criteria

- No unresolved high-severity data or query defects.
- Query outputs match expected business answers.
- RBAC is validated.
- Performance is acceptable for expected concurrency.
- Regression tests pass after query or schema changes.

---

## Phase 8 – OneSpace Productisation

### Goal

Package the validated query and KPI catalogue into production OneSpace components.

### Bridge

- Register canonical query tools.
- Add runtime parameter definitions.
- Add RBAC predicates.
- Configure FAQ and semantic intent mappings.
- Use NL2SQL cache only where appropriate.
- Avoid response caching for live operational data unless a short, approved TTL is used.

### Mesh

- Add project manager, delivery health, resource planning, risk and reporting agents.
- Restrict agents to approved Bridge tools and KPI outputs.
- Use Mesh for explanation, comparison and recommendations.

### Orbit

- Package repeatable tools such as:
  - Project Details
  - Project Task Summary
  - Project Effort Summary
  - Project Risk Summary
  - Project Issue Summary
  - Project Health Assessment
  - Executive Portfolio Watchlist
  - Weekly Project Status Report

### Deliverables

- Production Bridge tool catalogue.
- Mesh agent definitions.
- Orbit tool and workflow definitions.
- User acceptance sign-off.
- Monitoring and audit configuration.

### Exit criteria

- Tools execute only approved SQL/KPI logic.
- RBAC and audit trails are active.
- Tool responses are reproducible.
- Production users accept the results and experience.

---

## 8. Inputs Required From the PMS/Business Team

### Mandatory before Phase 4 completion

- Confirm the meaning of “my projects”:
  - PM-managed projects
  - Owned projects
  - Allocated projects
  - Task-assigned projects
  - Union of selected relationships
- Confirm the list of open task status IDs.
- Confirm the list of completed task status IDs.
- Confirm the list of open issue status IDs.
- Confirm the list of resolved/closed issue status IDs.
- Confirm whether Active project means only `project_status_id = 2`.
- Confirm whether duplicate project names are allowed.
- Confirm whether task, risk and issue reference numbers repeat by project.
- Provide a valid populated department name or department ID for UAT.

### Mandatory before Phase 5

- Confirm project completion formula.
- Confirm resource-capacity basis and over-allocation threshold.
- Confirm utilization formula.
- Confirm expected working hours per day/week.
- Confirm stale task, issue and project thresholds.
- Confirm risk exposure formula and thresholds.
- Confirm effort source of truth:
  - Task actual hours
  - Timesheet hours
  - Project booked hours
  - Combination with precedence rules

### Mandatory before Phase 6

- Confirm executive-attention scoring weights.
- Confirm health bands such as Green, Amber and Red.
- Confirm whether deal value, committed effort or another commercial field should represent exposure.
- Confirm 30/60/90-day watchlist criteria.
- Confirm desired dashboard audience and hierarchy filters.

---

## 9. MCP Usage Plan

The local MCP should now be used for live validation and interactive investigation rather than for schema discovery.

### Recommended MCP activities

- Run read-only SQL for individual KPI development.
- Inspect representative records for projects, tasks, issues, risks, allocations and timesheets.
- Validate code meanings and null behaviour.
- Test join cardinality and duplicate inflation.
- Compare alternative formulas.
- Run `EXPLAIN` during performance tuning.
- Validate query output against known PMS examples.

### Allowed operations

```text
SELECT
WITH ... SELECT
SHOW
DESCRIBE
EXPLAIN
```

### Operations to block

```text
INSERT
UPDATE
DELETE
ALTER
DROP
TRUNCATE
```

### Recommended MCP workflow per complex question

1. Select one question from the KPI or executive backlog.
2. Confirm its business definition.
3. Identify source tables and fields.
4. Write deterministic SQL.
5. Execute against representative live data.
6. Review duplicates, nulls and edge cases.
7. Run `EXPLAIN`.
8. Compare output with a manually known case.
9. Add the approved SQL and definition to the workbook.
10. Add the case to the regression verifier.

---

## 10. Ownership and Responsibilities

| Work item | Suggested owner | Support |
|---|---|---|
| Question catalogue and canonical intents | OneSpace/PMS product team | Business stakeholders |
| SQL development | Data/Bridge engineering | PMS database team |
| Business-rule definitions | PMS product owner | PMO and delivery leadership |
| KPI formulas and thresholds | PMO/leadership | Data and OneSpace team |
| RBAC rules | PMS application owner/security | Bridge engineering |
| Query verification | Data/QA team | OneSpace team |
| Performance/index review | DBA | Data engineering |
| Mesh agent behaviour | OneSpace AI team | PMS product owner |
| Orbit tool design | OneSpace product/engineering | UX and business owners |
| UAT and sign-off | PMS business users | QA and OneSpace team |

---

## 11. Progress Tracker

| ID | Work item | Status | Owner | Dependency | Evidence/Deliverable |
|---:|---|---|---|---|---|
| 1 | Review PMS schema | Complete | OneSpace/Data team | Schema dump | Schema coverage analysis |
| 2 | Identify populated and empty tables | Complete | OneSpace/Data team | DB/table data | Data Coverage sheet |
| 3 | Prepare initial question catalogue | Complete | OneSpace team | Business scope | Questionnaire workbook |
| 4 | Reorganise catalogue for populated tables | Complete | OneSpace team | Empty-table list | 150-question active catalogue |
| 5 | Add executive/KPI questions | Complete | OneSpace team | Management use cases | 44 complex questions |
| 6 | Prepare base SQL queries | Complete for selected base set | OneSpace/Data team | Schema clarity | 50 mapped queries |
| 7 | Run live SQL verification | Complete | PMS/Data team | DB access | Verification JSON |
| 8 | Resolve missing department test parameter | Pending | PMS/Data team | Populated department | Rerun result |
| 9 | Confirm task open/closed rules | Pending | PMS product owner | Status mapping | Approved status list |
| 10 | Confirm issue open/closed rules | Pending | PMS product owner | Status mapping | Approved status list |
| 11 | Confirm “my projects” and RBAC | Pending | PMS/security owner | Access model | RBAC definition |
| 12 | Harden identifiers in base SQL | Pending | Data/Bridge team | ID strategy | Revised base SQL |
| 13 | Retest all base queries with domain-specific parameters | Pending | QA/Data team | Updated verifier | Full validation report |
| 14 | Develop operational KPI batch | Not started | Data/Bridge team | Approved rules | KPI SQL catalogue |
| 15 | Develop management dashboard batch | Not started | Data/Bridge team | KPI batch | Dashboard query set |
| 16 | Develop executive composite tools | Not started | OneSpace/PMO | Approved weights | Executive watchlist tools |
| 17 | Run UAT and business validation | Not started | PMS business/QA | Completed query set | UAT sign-off |
| 18 | Tune performance and indexes | Not started | DBA/Data team | Query plans | Performance report |
| 19 | Register Bridge tools | Not started | Bridge engineering | Approved SQL | Bridge catalogue |
| 20 | Configure Mesh agents | Not started | OneSpace AI team | Bridge/KPI tools | Agent definitions |
| 21 | Build Orbit tools and workflows | Not started | Orbit engineering | Approved components | Production tools |
| 22 | Production rollout and monitoring | Not started | OneSpace/PMS teams | UAT sign-off | Release and monitoring plan |

---

## 12. Immediate Next Actions

| Priority | Action | Expected output |
|---:|---|---|
| 1 | Confirm task open and completed status lists | Approved task lifecycle rules |
| 2 | Confirm issue open and resolved status lists | Approved issue lifecycle rules |
| 3 | Confirm “my projects” and hierarchy/RBAC meaning | Access-definition document |
| 4 | Provide a valid populated department ID/name | Complete the skipped base-query test |
| 5 | Replace name/reference-only filters with production IDs | Hardened base SQL |
| 6 | Rerun all 50 base queries with domain-specific test parameters | Complete base-query verification |
| 7 | Approve the first KPI batch definitions | Ready-to-build KPI backlog |
| 8 | Build and test the first operational KPI queries | Phase 5 initial delivery |

---

## 13. Definition of Done

The PMS questionnaire and OneSpace implementation will be considered complete when:

- All 150 active questions map to an approved canonical intent.
- Each intent maps to a validated base query, KPI tool, composite tool, Prism search or documented unsupported/deferred reason.
- All business rules, formulas and thresholds are documented.
- Queries use safe identifiers and enforce RBAC.
- SQL and KPI calculations are technically and business validated.
- Performance is acceptable and regression tests pass.
- Executive outputs can be traced back to underlying metrics.
- Bridge tools, Mesh agents and Orbit tools are deployed with auditability and monitoring.

---

## 14. Current Decision Summary

- The 50 tested queries are the validated foundation and can be used for direct/UAT answers.
- They do not represent the full final scope.
- Most do not need complete rewrites, but some require targeted semantic and identifier improvements.
- The remaining questions should be implemented through reusable derived KPI and composite tools rather than one independent SQL query per wording.
- The project is ready to move from base-query verification into semantic hardening and KPI-query development.
