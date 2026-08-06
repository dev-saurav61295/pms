# PMS Questionnaire and SQL Validation — Inputs Required From Your End

## Purpose

This document lists the remaining inputs, business decisions, and validations required from your side to finalize the PMS questionnaire, SQL mappings, and executive/KPI questions.

The current status is:

- 50 mapped queries were selected for verification.
- 49 queries executed successfully.
- 31 returned data.
- 18 returned no rows for the selected test parameters.
- 1 query was skipped because a department parameter was not available.
- No SQL query failed because of syntax, missing tables, or missing columns.

Most current SQL queries can be used for UAT and answer generation. Only a limited set requires business-rule confirmation or production hardening.

---

## 1. Mandatory Business-Rule Confirmations

### 1.1 Meaning of “My Projects”

Please confirm which records should be included when a user asks:

> What are my projects?

Choose one rule:

- Projects where the user is an accepted project member
- Projects where the user is the project manager
- Projects where the user is the project owner
- Union of project member, project manager, and project owner
- A different RBAC rule

Recommended rule:

```text
My Projects = Accepted project membership
              OR Project Manager
              OR Project Owner
```

Please confirm whether archived and inactive projects must always be excluded.

---

### 1.2 Active Project Definition

The database shows the following project statuses:

| Status ID | Status Name |
|---:|---|
| 0 | Unspecified |
| 1 | PendingApproval |
| 2 | Active |
| 5 | Approved |

Proposed rule:

```text
Active Project = project_status_id = 2
                 AND status = 1
                 AND archive = 0
```

Required confirmation:

- Should `Approved` projects also be treated as active?
- Should `PendingApproval` projects appear in executive dashboards?
- How should projects with status ID `0` be treated?

---

### 1.3 Open Task Definition

The database contains these task statuses:

| ID | Status |
|---:|---|
| 1 | New |
| 2 | InProgress |
| 3 | Complete |
| 4 | ReOpen |
| 5 | OnHold |
| 6 | ReTest |
| 7 | UAT |
| 8 | Live |
| 9 | Approve |
| 10 | Abandon |
| 11 | QAPass |
| 12 | ReqComplete |
| 13 | Completed in Dev |

Please confirm which status IDs count as:

- Open
- In progress
- Completed
- Closed
- Abandoned
- Pending approval

Suggested starting rule:

```text
Open: 1, 2, 4, 5, 6, 7, 9, 11, 13
Completed/Closed: 3, 8, 12
Abandoned: 10
```

This is only a proposal and requires business approval.

---

### 1.4 Open Issue Definition

The database contains these issue statuses:

| ID | Status |
|---:|---|
| 1 | Raised |
| 2 | InProgress |
| 3 | Complete |
| 4 | Acknowledged |
| 5 | Abandonned |
| 6 | Critical |
| 7 | Reopen |
| 8 | Dev Complete |
| 9 | QA Complete |
| 10 | Closed |

Please confirm which status IDs count as:

- Open issue
- Resolved issue
- Closed issue
- Abandoned issue
- Critical issue

Suggested starting rule:

```text
Open: 1, 2, 4, 6, 7, 8, 9
Resolved/Closed: 3, 10
Abandoned: 5
```

---

### 1.5 Issue Severity and Priority Mapping

Issue severity and priority values found in the database are:

```text
0, 1, 2, 3
```

Please provide the business labels for these values.

Example mapping to confirm or replace:

| Value | Possible Label |
|---:|---|
| 0 | Not Set |
| 1 | Low |
| 2 | Medium |
| 3 | High/Critical |

Without this mapping, questions such as “high-severity issues” cannot be finalized reliably.

---

### 1.6 Project Priority Mapping

Project priority values found are:

```text
0, 2, 3
```

The project-priority master table does not provide a reliable mapping.

Please confirm:

| Value | Business Meaning |
|---:|---|
| 0 | To be confirmed |
| 2 | To be confirmed |
| 3 | To be confirmed |

Until confirmed, the system should return the raw priority code only.

---

### 1.7 Utilization Formula

Please confirm the approved utilization formula.

Possible options:

```text
Option A:
Utilization % = Logged Hours / Available Hours × 100

Option B:
Billable Utilization % = Chargeable Hours / Available Hours × 100

Option C:
Allocation Utilization % = Allocated Hours / Capacity Hours × 100
```

Also confirm:

- Weekly capacity per employee
- Monthly capacity calculation
- Working days per week
- Treatment of leave and holidays
- Treatment of part-time resources
- Over-allocation threshold, for example above 100% or above 110%

---

### 1.8 Project Completion Formula

Please confirm how project completion should be calculated.

Possible options:

```text
Option A:
Completed Tasks / Total Tasks × 100

Option B:
Average of task percent_complete

Option C:
Weighted average using task estimate

Option D:
Milestone-based completion
```

Because milestone tables are currently empty, milestone-based completion is not currently recommended.

Recommended approach:

```text
Weighted Project Completion =
SUM(Task Estimate × Task Percent Complete)
/
SUM(Task Estimate)
```

A fallback rule is required for tasks with zero or null estimates.

---

### 1.9 Project Health or Executive Attention Score

Please approve the indicators and weights used to identify projects needing leadership attention.

Suggested indicators:

| Indicator | Suggested Weight |
|---|---:|
| Overdue high-priority tasks | 20% |
| Red or Amber task concentration | 15% |
| Open high risks | 20% |
| Overdue unresolved issues | 15% |
| Effort overrun | 15% |
| End-date exposure | 10% |
| Stale project activity | 5% |

Please confirm:

- Final indicators
- Weights
- Thresholds
- Green/Amber/Red score bands
- Whether stored project RAG should affect the score

Important: stored project RAG is sparsely populated, so it should not be the primary health indicator.

---

### 1.10 Risk Exposure Formula

The risk masters are populated and support probability and impact values.

Proposed formula:

```text
Risk Score = Probability Value × Impact Value
```

Please confirm:

- Whether this formula is correct
- Whether priority should also affect the score
- Whether mitigated risks should be excluded
- Whether residual risk should replace original risk where available
- Thresholds for Low, Medium, High, and Critical exposure

---

## 2. Production Identifier Decisions

The current queries often accept names or reference numbers. They work for UAT, but IDs are safer for production.

Please approve the following design:

| User-Facing Selection | Value Passed to SQL |
|---|---|
| Project name | `project_id` or `project_unique_id` |
| Employee name | `user_id` |
| Task reference | `task_id` or project ID + reference number |
| Risk reference | `risk_id` or project ID + reference number |
| Issue reference | `issue_id` or project ID + reference number |
| Department name | `department_id` |

Required confirmation:

- Are task reference numbers unique globally or only within a project?
- Are risk reference numbers unique globally or only within a project?
- Are issue reference numbers unique globally or only within a project?
- Are project titles guaranteed to be unique?

Recommended rule:

```text
Display names and references to the user, but pass internal IDs to the query.
```

---

## 3. UAT Test Data Required

Please provide or identify valid sample records for UAT.

### 3.1 User Samples

- One user who manages at least one project
- One user who owns at least one project
- One user with accepted project allocations
- One user with task assignments
- One user with timesheets in the selected date range
- One user with mapped skills

### 3.2 Project Samples

- One active project with tasks
- One project with timesheets
- One project with issues
- One project with risks
- One project with executive-summary data
- One project with infrastructure-cost data
- One project with active allocated users

### 3.3 Transaction Samples

- One task with assignees
- One task with subtasks
- One task with timesheet entries
- One risk with history
- One issue with a valid reference
- One department linked to active projects

These samples do not need to contain sensitive information. IDs alone are sufficient.

---

## 4. MCP Usage Required From Your End

The local MCP should be used for interactive, read-only validation.

### 4.1 Required Permissions

Allow only:

```text
SELECT
WITH ... SELECT
SHOW
DESCRIBE
EXPLAIN
```

Block:

```text
INSERT
UPDATE
DELETE
ALTER
DROP
TRUNCATE
CREATE
```

### 4.2 MCP Tasks

Use MCP to:

- Run individual queries with valid live parameters
- Check whether empty results are caused by parameter choice
- Inspect distinct business values
- Validate joins and duplicate rows
- Run `EXPLAIN` for complex queries
- Compare KPI output with the PMS application dashboard
- Validate each CEO/executive question before adding it to Orbit

### 4.3 Output to Share Back

For each failed or questionable query, share:

- Canonical question name
- SQL executed
- Parameters used
- Error message, if any
- First few non-sensitive result rows
- `EXPLAIN` output where performance is poor
- Expected result according to the PMS application

Do not share database passwords or production credentials.

---

## 5. Department Query Validation

The department query was skipped because no valid `department_name` parameter was discovered.

Please provide one department name that is linked to an active project, or run:

```sql
SELECT
    d.department_id,
    d.department_name,
    COUNT(*) AS project_count
FROM department d
JOIN tbl_projects p
    ON p.department_id = d.department_id
WHERE p.status = 1
  AND p.archive = 0
  AND d.department_name IS NOT NULL
  AND d.department_name <> ''
GROUP BY d.department_id, d.department_name
ORDER BY project_count DESC
LIMIT 10;
```

Share one valid department ID and name for UAT.

---

## 6. Performance Review and Index Approval

Several queries executed successfully but performed large scans.

Please ask the DBA or technical team to review indexes for:

- Project title and project status filters
- Task reference number
- Task project/status/due-date combinations
- Timesheet user/date combinations
- Timesheet task/date combinations
- Project-user user/status/request-status combinations
- Risk reference number
- Issue reference number

Recommended production approach:

- Prefer IDs over names
- Filter the parent entity before joining large transaction tables
- Add composite indexes only after reviewing existing indexes and write impact
- Do not create indexes directly in production without DBA approval

---

## 7. Executive/KPI Questions Requiring Sign-Off

The complex questions are technically feasible, but formulas must be approved before SQL is finalized.

Please prioritize approval for these KPI groups:

### 7.1 Portfolio Health

- Projects requiring immediate executive attention
- Red/Amber project watchlist
- Projects likely to miss committed end dates
- Projects with declining delivery performance

### 7.2 Task Delivery

- High-priority overdue tasks by project
- Red-task concentration by project
- Effort consumed versus work completed
- Task backlog aging

### 7.3 Risk and Issue Exposure

- Aggregate open-risk score by project
- High-priority open risks
- Overdue unresolved issues
- Projects with both high risk and severe issues

### 7.4 Resource and Capacity

- Overallocated resources
- Underutilized resources
- Projects dependent on one contributor
- Resource allocations ending soon
- Resource demand over the next 30, 60, and 90 days

### 7.5 Financial and Effort Exposure

- Deal value associated with unhealthy projects
- Effort overrun by project
- Chargeable versus booked hours
- Infrastructure-cost exposure

For each KPI, please confirm:

- Formula
- Threshold
- Reporting period
- Inclusion/exclusion criteria
- Required drill-down fields
- Expected dashboard visualization

---

## 8. Questions to Keep Deferred

The following areas should remain deferred until their source data is populated or an alternative source is approved:

- Milestone progress and milestone ownership
- Milestone-based completion
- Detailed project-estimation versions and assumptions where tables are empty
- Team-name-based questions where the team master is empty
- Exact project-stage aging without stage-change history
- Predictive probability without a validated historical model

Please confirm whether these should:

- Remain deferred
- Be removed from the first release
- Be reframed using tasks, dates, or other populated tables

---

## 9. Required Sign-Off Owners

Please identify the responsible person for each decision area.

| Decision Area | Suggested Owner |
|---|---|
| Project status and lifecycle | PMS Product Owner |
| Task workflow statuses | Delivery/PMS Product Owner |
| Issue workflow and severity | QA/Delivery Governance |
| Risk formula and thresholds | PMO/Risk Owner |
| Utilization and capacity | Resource Management/HR |
| Financial fields and deal value | Finance/Commercial Team |
| RBAC and “my” semantics | Product Owner/Security |
| KPI weights and executive score | PMO/Leadership |
| Database performance and indexes | DBA/Engineering |

---

## 10. Minimum Inputs Needed to Proceed

The next version can be generated once the following minimum inputs are available:

1. Approved active-project definition
2. Approved open and completed task status IDs
3. Approved open and closed issue status IDs
4. Issue severity and priority mappings
5. Project priority mapping, or approval to keep raw codes only
6. Definition of “my projects”
7. Utilization formula and capacity assumptions
8. Project-completion formula
9. Risk-score formula and thresholds
10. Executive-attention KPI indicators and weights
11. Confirmation to use internal IDs in production tools
12. Valid department sample for testing
13. Representative project/user/task/risk/issue IDs for UAT

---

## 11. Optional but Recommended Inputs

These are not required for initial UAT, but they will improve quality:

- Screenshot or export of the existing PMS dashboards
- Existing PMO KPI definitions
- SLA and escalation rules
- Expected working-hours calendar
- Holiday and leave data source
- Definition of billable versus non-billable hours
- Expected report formats for CEO, PMO, project manager, and resource manager
- Known duplicate or legacy-data conditions
- Data-retention rules
- Expected maximum query response time

---

## 12. Proposed Next Step After Receiving Inputs

After the above items are provided, the next version should:

1. Retain the validated SQL queries
2. Update active-project logic
3. Replace ambiguous open/closed conditions with approved status IDs
4. Use project, user, task, risk, and issue IDs for production queries
5. Add UAT validation status to each mapped question
6. Add deterministic SQL for approved executive/KPI questions
7. Flag unsupported questions clearly
8. Add performance notes for queries requiring index review
9. Produce a final questionnaire ready for Bridge FAQ, NL2SQL cache, and Orbit tool creation

---

## Response Template

You can provide the required decisions using the following format:

```text
Active Project Status IDs:

My Projects Rule:

Open Task Status IDs:
Completed Task Status IDs:
Abandoned Task Status IDs:

Open Issue Status IDs:
Closed Issue Status IDs:
Abandoned Issue Status IDs:

Issue Severity Mapping:
0 =
1 =
2 =
3 =

Issue Priority Mapping:
0 =
1 =
2 =
3 =

Project Priority Mapping:
0 =
2 =
3 =

Utilization Formula:
Weekly Capacity Hours:
Over-allocation Threshold:

Project Completion Formula:

Risk Score Formula:
Risk Thresholds:

Executive Attention Score Indicators and Weights:

Production Identifier Rule Approved: Yes/No

Representative UAT IDs:
- User ID:
- Project ID:
- Task ID:
- Risk ID:
- Issue ID:
- Department ID:
```
