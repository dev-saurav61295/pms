# PMS — Pending Items for POC Review

38 items requiring decision or input, consolidated from [PMS_Contradictions_Requiring_Decision.md](../PMS_Contradictions_Requiring_Decision.md) (12 items, C-01…C-12) and [PMS_Open_Items_Pending.md](../PMS_Open_Items_Pending.md) (26 items, O-01…O-26). Already-resolved items are excluded — everything below is still open.

**Suggested order for the POC conversation:** name the owners (O-24) → C-01/C-02/C-03 (unlocks the most KPIs fastest) → C-08 (data-leak risk, don't let it wait) → O-01–O-06 as a single server/DB session (six items closed in one sitting) → resourcing formulas (O-09–O-13) and executive scoring (O-15–O-19) last, since those need the most invention.

---

## 1. Correctness fixes

The earlier questionnaire answer is factually wrong here — not a preference, needs sign-off to change.

| ID | Item | Ask | Table(s) to check |
|---|---|---|---|
| **C-01** 🔴 | Issue severity mapping inverted | Code says `1=Low, 2=Medium, 3=High`; earlier answer had it backwards. Confirm which one ships. | `tbl_project_issues` (`severity`, `priority` columns); `tbl_project_impact` (the separate `impact_id` FK — don't conflate it with `priority`) |
| **C-02** 🔴 | Status must resolve via `status_type`, not hardcoded IDs | Every status-filtered query needs rewriting off this. Needs Delivery/PMS PO sign-off. | `tbl_project_task_status`, `tbl_project_issue_status` (the `status_type` column); `tbl_project_tasks`, `tbl_project_issues` (the queries that filter on them) |
| **C-03** 🔴 | "InProgress treated as Closed" claim is false | Query O-03 will settle this once run — confirm disposition after. | `tbl_project_issue_status` |
| **C-04** 🔴 | Risk identifier points at wrong table (`tbl_risk.risk_id`) | Confirm the correction. | `tbl_risk` (correct, operational register); `tbl_project_risk` (the wrong one the questionnaire pointed at — versioned, no `reference_no`, appears unused by reporting) |
| **C-05** 🔴 | Department query references a non-existent table | Confirm corrected SQL; this is also the one SKIPPED query in the last verifier run. | `tbl_project_department` (real table); `tbl_projects` (`department_id` — plain int, no FK constraint, so orphans are possible) |

## 2. RBAC / security decisions

One of these is a live data-leak risk.

| ID | Item | Ask | Table(s) to check |
|---|---|---|---|
| **C-08** 🟠 | **Company-privacy filter missing from every mapped query** | Flagged as a data-leak concern, not a preference — needs Product Owner/Security approval before anything ships. | `tbl_projects` (`company_id`); `tbl_user_company` (`user_id` ↔ `company_id` — needed to resolve the caller's company before filtering) |
| **C-06** 🟠 | "My Projects": accepted membership vs. union of PM/owner/member | Confirm scope. | `tbl_project_users` (`request_status`, `status`); `tbl_projects` (`pm_user_id`, `project_owner_id`) |
| **C-07** 🟠 | Archived projects: always-exclude (new rule) vs. the app's existing toggle | Confirm this deliberate divergence is acceptable. | `tbl_projects` (`archive` column) |

## 3. Task/issue workflow gaps

| ID | Item | Ask | Table(s) to check |
|---|---|---|---|
| **C-09** 🟠 | `parent_id`/`ignore_report` filters omitted from task counts | Confirm both filters are adopted. | `tbl_project_tasks` (`parent_id`, `ignore_report`) |
| **C-10** 🟡 | "Pending approval" task bucket has no code equivalent | Drop it, or define it fresh. | `tbl_project_task_status` (the `Approve` row's `status_type` — needs O-02 run first) |
| **C-11** 🟡 | "Critical issue" — status or severity? | Depends on C-01. | `tbl_project_issue_status` (status reading); `tbl_project_issues` (`severity` reading) |
| **C-12** 🟡 | Risk bands: 3-band model vs. the requested 4 bands | Confirm which banding ships. | `tbl_risk` (`rating`, `rating_color_code`); `tbl_risk_probability`, `tbl_risk_impact` (the factors the rating is built from) |

## 4. Server config values

Needs someone with server/app access, not a DB query — no table involved.

| ID | Item | Ask | Where to check |
|---|---|---|---|
| **O-01** 🔴 | `GLOBAL_PROJECT_STATUS` value | Decides if every status query needs a `project_id` filter added. | Site config on the app server (gitignored) — `grep -rn "GLOBAL_PROJECT_STATUS" config/` |
| **O-04** 🔴 | `MONTHLY_BILLING_HOURS` value | Denominator for every utilisation KPI in §7.4 — nothing in that section ships without it. | Site config on the app server (gitignored) — `grep -rn "MONTHLY_BILLING_HOURS" config/` |

## 5. Master-data confirmations

One DB read each, no real decision involved.

| ID | Item | Table(s) to check |
|---|---|---|
| **O-02** | Task status master rows — confirms O-01, feeds C-02/C-10 | `tbl_project_task_status` |
| **O-03** | Issue status master rows — settles C-03 | `tbl_project_issue_status` |
| **O-05** | Project priority master rows — what does priority `0` mean; does `1` even exist? | `tbl_project_priority`; `tbl_projects` (`priority` FK) |
| **O-06** | Department UAT sample (blocked on C-05 fix) | `tbl_project_department`, `tbl_projects` |
| **O-07** | Confirm no unique index on project titles | `tbl_projects` (`SHOW INDEX FROM tbl_projects`) |
| **O-08** | Task estimate/percent-complete data coverage — decides which completion formula is usable | `tbl_project_tasks` (`estimate`, `percent_complete`) |

## 6. Resourcing & capacity formulas

None of this exists in the app; must be invented and owned by Resource Mgmt/HR.

| ID | Item | Table(s) to check |
|---|---|---|
| **O-09** | Weekly capacity per employee | None — no such data anywhere in `engagedb`; must come from HR |
| **O-10** | Working days per week | None — no such constant anywhere in `engagedb` |
| **O-11** | Leave/holiday treatment — no calendar table exists at all; may need an external source | None — confirmed absent from the schema |
| **O-12** | Part-time / FTE treatment — no FTE field exists anywhere | `tbl_project_users` (`allocation_hrs`, `allocation_from`, `allocation_to`, `resource_type`) — per-project only, not person-level FTE; usable only as a rough proxy |
| **O-13** | Over-allocation threshold — app currently hard-caps at 100%, so >100% reporting is new behavior | `tbl_project_users` (allocation figures); depends on O-04's `MONTHLY_BILLING_HOURS` for the denominator |

## 7. Completion & executive scoring

Delivery/PMO owned, entirely greenfield.

| ID | Item | Table(s) to check |
|---|---|---|
| **O-14** | Subtask handling in completion % (avoid double-counting rolled-up hours) | `tbl_project_tasks` (`parent_id` rollup) |
| **O-15** | Executive attention score — which of the 7 proposed indicators to keep | `tbl_project_tasks` (overdue/priority), `tbl_risk` (`rating`), `tbl_project_issues` (status/overdue), `tbl_projects` (`update_date`, `end_date`, `rag`, `overall_score`, `attention_required`) |
| **O-16** | Executive attention score — weights (currently just guesses summing to 100) | Same tables as O-15 — no new table, just a number per confirmed indicator |
| **O-17** | Executive attention score — per-indicator thresholds | Same tables as O-15 |
| **O-18** | Should manually-entered project RAG feed the score, override it, or be shown separately? | `tbl_projects` (`rag` — manually entered string, sparsely populated, nothing computes it) |
| **O-19** | Residual risk — use `after_mitigation_risk_score` or always the original rating? | `tbl_risk` (`rating`, `after_mitigation_risk_score`, `revised_probability`, `revised_impact`) |

## 8. KPI sign-off

| ID | Item | Table(s) to check |
|---|---|---|
| **O-20** | 21 KPIs × 6 confirmations each. Recommended: sign off §7.3 (Risk/Issue, 4 KPIs) and §7.2 (Task Delivery, 4 KPIs) first — those only need C-01/C-02, everything else is blocked on Group 6/7 above. | Spans `tbl_risk`, `tbl_project_issues`, `tbl_project_tasks`, `tbl_projects` depending on which KPI group — see §7 in [PMS_Inputs_Required_From_User.md](../PMS_Inputs_Required_From_User.md) for the per-KPI breakdown |

## 9. Test data

Needs real IDs from you, not the POC.

| ID | Item | Table(s) to check |
|---|---|---|
| **O-21** | Numeric `user_id` for UAT (all 6 slots currently just say "Saurav Kaushik" by name) | `tbl_users` |
| **O-22** | 5 of 7 project-sample slots still blank | `tbl_projects`; `tbl_project_issues`, `tbl_risk`, `tbl_project_users` (to find a project with each kind of data); `tbl_project_executive_summary`, `tbl_project_infrastructure_planning` / `tbl_project_infrastructure_requirements` (unconfirmed as populated — check before assigning those two slots) |
| **O-23** | All 6 transaction-sample slots blank (task w/ assignees, task w/ subtasks, etc.) | `tbl_project_tasks` (assignees, subtasks via `parent_id`); `tbl_timesheets` (task with logged hours); `tbl_risk` (with history); `tbl_project_issues` (valid reference); `tbl_project_department` (see O-06) |

## 10. Governance

Names and dispositions, no technical content — no table involved.

| ID | Item | Notes |
|---|---|---|
| **O-24** | Named sign-off owner for each of 9 decision areas — nothing in Group 6/7 above can be closed until these are named | Pure governance — names, not data |
| **O-25** | Disposition (keep deferred / remove / reframe) for 8 areas with no current logic | Tables exist but are empty or unused: `tbl_project_task_milestone` / `tbl_project_task_milestone_mapping` (milestones — empty), `tbl_project_estimation` (versions — needs population check), `tbl_project_team` (team-name questions), `tbl_master_skills` / `tbl_user_skills` (skills — viable, recommend promoting out of deferred) |
| **O-26** | DBA index review — blocked on C-02 being settled first | `tbl_projects`, `tbl_project_tasks`, `tbl_timesheets`, `tbl_project_users`, `tbl_risk`, `tbl_project_issues` — start from the captured slow-query log at `source/application/modules/Risk/classes/Project-mysql-slow-queries` rather than synthetic tests |
