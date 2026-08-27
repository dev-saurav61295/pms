# PMS Data Availability & Question Impact — Consolidated Report

**Database:** `engagedb` · **Date:** 2026-08-27
**Sources:** `empty_tables_report.json` (census 2026-08-04) · `engagedb.sql` (structure) · live query testing via MySQL MCP / phpMyAdmin · developer clarifications (2026-08-26 and 2026-08-27)
**Question set:** `PMS Questions and Query - Sheet1.csv` — 150 questions

> **Confidence labels used throughout:** **[CONFIRMED]** = verified by live query result or developer statement · **[SCHEMA]** = verified from the `CREATE TABLE` definition · **[UNVERIFIED]** = suspected but not yet tested; listed so it is not mistaken for settled.

---

## 1. Headline numbers

| Measure | Count |
|---|---|
| Tables in database | 306 |
| **Tables with no data at all** | **109** (36%) |
| — of which PMS-domain (delivery/risk/estimation/config) | 70 |
| — of which social-era, legacy, or non-production | 39 |
| Populated tables with **confirmed** unpopulated/unusable columns | 6 |
| Populated tables with **unverified** column-population risk | 5 |
| | |
| Questions **ready to serve** (Tool) | **111** |
| — of which fully intact | 89 |
| — of which **answerable but degraded** (scope silently narrowed) | 22 |
| Questions **unanswerable — data does not exist** | **11** |
| Questions **blocked on a business decision** | 7 |
| Questions needing SQL written (no data blocker) | 12 |
| Questions routed to NL2SQL (open-ended by design) | 9 |

---

## 2. Tables that are not populated at all

### 2.1 Empty tables that directly block questions **[CONFIRMED]**

| Empty table(s) | What is lost | Questions blocked |
|---|---|---|
| `tbl_project_task_milestone`, `tbl_project_task_milestone_mapping` | **All milestone data.** No milestone exists in the system | 3 (rows 21, 22, 23) |
| `tbl_risk_action`, `tbl_risk_mitigation_actions`, `tbl_risk_update` | Risk **action/mitigation register** as separate tracked items with due dates | 1 (row 94) |
| `tbl_weekly_task_status`, `tbl_weekly_issue_status`, `tbl_weekly_ticket_status` | **All historical weekly snapshots.** Cron never populated these | Trend questions must derive from `*_history` tables instead (rows 97, 121, 133, 143) |
| `tbl_project_status_history` | **Project status change history.** Project-level status trend is unavailable | Any "how did project status change over time" question |
| `tbl_task_insights` | Precomputed bugs / reopened / effort-variance / schedule-variance per task | Reopen-rate and variance metrics must be recomputed from `tbl_project_tasks_history` |
| `tbl_client_summary_report` | Group-level weekly client summary incl. **client mood** | 1 (row 120 — "client mood vs. objective health") |
| `tbl_project_documents` | **All project document records** (18 code load sites, zero rows) | No document questions currently in the workbook, but any future one |
| `tbl_project_estimation` + 6 satellites, `tbl_estimation_asumption` | **The estimation module is unpopulated.** Only `tbl_project_estimation_status`, `tbl_estimation_complexity`, `tbl_estimation_assumption_map` have rows | Pre-sales estimation questions are not answerable |
| `tbl_sub_todo_list` | Sub-todo items and their `done` flag | Sub-todo completion questions |
| `tbl_project_sponsors` | Project↔sponsor junction (only the scalar `tbl_projects.sponsor` exists) | Sponsor-based questions |
| `tbl_notes` | PM notes as records (only scalar `tbl_projects.pm_note`) | Notes questions |
| `tbl_project_risk`, `tbl_project_risk_status` | Estimation-side versioned risk register | **None** — superseded by `tbl_risk`, which is populated (settles C-04) |
| `tbl_project_department`, `tbl_project_team` | Department/team master | **None** — superseded by `tbl_groups` + `tbl_group_projects` (settles C-05); `tbl_projects.team_id` resolves to nothing |
| `tbl_project_priority` | Project priority lookup | **None** — settles O-05: priority is a PHP label map, not an FK |
| `tbl_project_rca_users` | RCA user junction | **None** — `tbl_project_rca_owners` / `_internal_users` are populated |

### 2.2 Empty tables — no current question impact, but worth knowing

`tbl_project_issue_move_history` · `tbl_project_issue_views` · `tbl_project_task_views` · `tbl_project_initiation_records` · `tbl_rt_env_details` · `tbl_rt_file` (RT attachments live in `tbl_attachment` with `type='GT'`) · `tbl_starred_files` · `tbl_onlyoffice_file_logs` · `tbl_comment_likes` · `tbl_batch_notifications` · `tbl_opportunity`(+`_history`,`_tangible`) · `tbl_process_issue_analysis` · `tbl_project_process_issue` · `tbl_group_task_income_var` · `tbl_read_histories` · `tbl_reminder` · `tbl_user_journey` · `tbl_user_account_history` · `tbl_settings` · `tbl_admins` · `tbl_admin_groups` · `tbl_admin_group_settings` · `tbl_ipfilter` · `tbl_iplist` · `tbl_ipignorelist` · `tbl_group_types`(+`_desc`) · `tbl_regions` · `tbl_privacy_rules` · `tbl_privacy_settings` · `tbl_activity_privacy_settings` · `tbl_meta`(+`_desc`) · `tbl_cms` · `tbl_contents`(+`_desc`) · `tbl_support`(+ 3 satellites — superseded by the `tbl_rt_*` module)

### 2.3 Empty — social-era / legacy / non-production (39 tables, ignore entirely)

`tbl_agenda` · `tbl_announcements` · `tbl_area_of_work` · `tbl_available_for_info`(+`_desc`) · `tbl_bulletin` + 6 satellites · `tbl_chat_broadcast_messages` · `tbl_follow` · `tbl_ims`(+`_desc`) · `tbl_mails_backup` · `tbl_mails_live` · `tbl_mails_desc_live` · `tbl_photos_users` · `tbl_promotion`(+`_desc`,`_ignore_user`) · `tbl_qa_attachment` · `tbl_qa_category_group` · `tbl_qa_category_noty_users` · `tbl_qualifications`(+`_desc`) · `tbl_review` · `tbl_user_photos` · `tbl_user_subscriptions` · `tbl_venue` · `tbl_videos` · `tbl_visitors` · `tbl_word_group` · `tbl_work_edu_mapping` · `tbl_work_education_types`(+`_desc`) · `temp_all_task`

---

## 3. Populated tables where key columns are not populated or not usable

This is the more dangerous category — the table returns rows, so a query **looks** like it worked while silently producing a wrong or narrowed answer.

### 3.1 Confirmed

| Table.column | Problem | Evidence | Consequence |
|---|---|---|---|
| **`tbl_project_users.allocation_from`**<br>**`tbl_project_users.allocation_to`** | **Not logged at all** in this instance. Columns exist; no data | **[CONFIRMED — developer, 2026-08-27]** Also proven live: a department utilization query returned **0 rows** with the date filter and **236 users / 533 projects / 25,265 hrs** without it | Any date-scoped allocation question is unanswerable; any period-filtered utilization query silently returns nothing |
| **`tbl_project_issues.date_closed`** | Stores zero-date `'0000-00-00 00:00:00'` for genuinely-open issues instead of `NULL`, so `IS NULL` / `IS NOT NULL` tests are meaningless | **[CONFIRMED — live]** Backlog query returned `closure_ratio = 100.00` for **every** project/month; issue `5916` has `date_closed = '0000-00-00 00:00:00'` and was labeled `Closed` | "Open issue" counts read as 0 and closure rates as 100% unless resolved via `status_type` instead |
| **`tbl_risk.date_closed`** | Same zero-date behavior | **[CONFIRMED — live]** Risk-owner query showed `overdue_risks = 0` alongside risks open **579–817 days** | Overdue-risk counts read as 0 |
| **`tbl_project_tasks.actual_hours`** | Declared **`tinyint`** — maximum value 127. Structurally cannot hold a realistic task effort total | **[SCHEMA]** | Unusable as an effort figure. Must aggregate `tbl_timesheets` instead. **6 questions currently read this column** (rows 29, 34, 40, 41, 45, 55) |
| **`tbl_project_issues.severity`**<br>**`tbl_project_issues.priority`** | "Not used in the form, so insufficient data" — the field is not captured in the UI | **[CONFIRMED — developer, C-01]**. Both are `int NOT NULL`, so unset reads as `0`, outside the documented 1–3 range | Severity-based questions will mostly return `0`. 3 questions depend on it (rows 100, 135, 137) |
| **`tbl_projects.attention_required`** | **The column does not exist** on `tbl_projects` (only on tasks/issues/PMS-issues/tickets) | **[SCHEMA]** — settles O-15 | Any attention-score indicator built on it must be dropped |

### 3.2 Populated but **not authoritative** — use a different path

| Column | Status | Use instead |
|---|---|---|
| `tbl_projects.department_id` | Populated (553 projects for test dept) but **superseded** | `tbl_group_projects` joined to `tbl_groups` **[CONFIRMED — developer, 2026-08-27]** |
| `tbl_projects.total_hours_booked`, `.total_chargable_hours`, `.combined_hours` | Denormalised caches, drift from source | `SUM()` over `tbl_timesheets` for anything auditable |
| `tbl_project_tasks.release_id`, `.released`, `.release_reference_no` | Denormalised in parallel with the junction | `tbl_task_release` junction |
| `tbl_project_tasks.priority` | Populated, but the ENUM includes `'Default'` and `'In Staging'` which the PHP UI cannot render | Expect rows the app shows blank; 5 levels exist, not 3 **[SCHEMA]** |

### 3.3 Unverified — population risk not yet tested

These are used by live queries but their data coverage has never been checked. **Each needs one `SELECT ... GROUP BY` to settle.**

| Column | Used by | Risk if unpopulated |
|---|---|---|
| `tbl_projects.deal_value` | rows 109, 110, 112, 116, 136, 140 | All deal-value-weighted portfolio KPIs return zeros/nulls |
| `tbl_project_issues.defect_origination_phase` / `defect_detection_phase` | row 135 | Defect-leakage rate is unanswerable |
| `tbl_project_tasks.acceptance_criteria` | row 132 | Acceptance-criteria coverage % is meaningless |
| `tbl_projects.client_id` ↔ `tbl_clients.client_id` | rows 15, 110, 128, 137 | **Type mismatch** (`int` vs `varchar(255)`) — join target unresolved; client reporting may silently return nothing |
| `tbl_group_users.request_status` | department/group membership paths | Column is **nullable with `DEFAULT NULL`**, so `= 'A'` silently drops NULL rows |

---

## 4. Questions we cannot answer — data does not exist (11)

These are not bugs and not fixable with better SQL. The underlying data is absent.

| Row | Question | Root cause |
|---|---|---|
| 21 | What is the task completion progress of milestone :milestone_name? | `tbl_project_task_milestone*` empty |
| 22 | Which milestone dates differ from their mapped task dates? | `tbl_project_task_milestone*` empty |
| 23 | Who owns milestone :milestone_name? | `tbl_project_task_milestone*` empty |
| 56 | What is the approval status of my timesheet? | No approval column/workflow exists on `tbl_timesheets` |
| 57 | Which timesheets were rejected? | No rejection column/workflow exists on `tbl_timesheets` |
| 62 | Whose project allocation ends in the next :days days? | `allocation_to` not logged |
| 63 | Whose project allocation starts in the next :days days? | `allocation_from` not logged |
| 80 | What is forecast utilization for :future_period? | `allocation_from`/`allocation_to` not logged — no forward-looking allocation data |
| 87 | What is the margin of :project_name? | `deal_value` exists but **no cost figure** to net against it |
| 94 | Which risk actions are due by :date? | `tbl_risk_action`, `tbl_risk_mitigation_actions`, `tbl_risk_update` all empty |
| 149 | Which resource allocations end before their assigned open tasks/project dates? | `allocation_to` not logged |

**Recommendation:** remove these from POC scope, or re-scope them (e.g. #56/#57 become "does timesheet approval exist as a feature?" — answer: no).

---

## 5. Questions that still answer but with **narrowed scope** (22)

These are live and will return plausible data — but the answer is **not the question originally asked**. Each needs the caveat surfaced in the agent's response, or the question re-worded.

### 5.1 "Period" became "current state" — 8 questions

Because `allocation_from`/`allocation_to` are not logged, the date-range filter was removed. The `:period` / `:start_date` / `:end_date` parameters are now **vestigial** — passed in, but not honored.

| Row | Question | Now actually returns |
|---|---|---|
| 66 | Who with skill X is available between D1 and D2? | Who with skill X has **no active allocation at all** |
| 76 | Who has allocations exceeding available capacity? | Current total allocation per person (no period) |
| 77 | How much idle capacity is available in :period? | Current allocation snapshot |
| 78 | Show utilization by project role for :period. | Current allocation by role |
| 79 | Show utilization for department X in :period. | Current allocation for that department |
| 145 | Which resources are overallocated across overlapping active projects? | Current total > caller-supplied threshold; "overlapping" not date-verified |
| 146 | Which resources have the largest allocated-vs-logged mismatch? | Allocation = current total; logged = genuinely period-scoped. **Mixed time basis** |
| 148 | Which users are spread across too many concurrent projects? | Current distinct active project count; "concurrent" not date-verified |

> Row 146 deserves special attention: it compares a **non-period** allocation figure against a **period** timesheet figure. The variance number is arithmetically valid but semantically mixed — flag it or drop the question.

### 5.2 Allocation dates shown as output columns — 4 questions

Rows **58, 59, 60, 61** display `allocation_from`/`allocation_to` in the result set. Rows are returned correctly; those two columns will simply render **blank/null** for every row. Cosmetic, but users will ask why.

### 5.3 Effort figures read from the capped `actual_hours` column — 6 questions

Rows **29, 34, 40, 41, 45, 55** read `tbl_project_tasks.actual_hours` (tinyint, max 127). Any task with >127 hours logged is misreported. Rows 40, 41 and 55 build **variance calculations** on it, so the variance is wrong wherever the cap bites. Should be re-pointed at `SUM(tbl_timesheets)`.

### 5.4 Open/closed determined by `percent_complete`, not `status_type` — 9 questions

Rows **12, 26, 28, 29, 31, 38, 43, 127, 129** use `percent_complete < 100` / `= 100` as the open/closed test. This contradicts decision C-02 (resolve status via `status_type`) and can disagree with the actual workflow status — a task can be Closed without `percent_complete` reaching 100, or sit at 100 while still open. Worth aligning, but lower risk than the above since it is at least a real, populated column.

### 5.5 Zero-date workaround applied — 3 questions

Rows **105, 133, 141** were rewritten to use `status_type` instead of `date_closed IS NULL`. These are **fixed**, listed here only so the change is visible: their numbers will differ (correctly) from any earlier run.

---

## 6. Questions blocked on a business decision, not on data (7)

| Row | Question | Waiting on |
|---|---|---|
| 100 | Which issues have high severity? | **C-01** — severity mapping; developer says the field is not captured, so this may be unanswerable in practice |
| 137 | Overdue/closed high-severity issues missing RCA/correction/corrective-action | **C-01** (same) |
| 135 | Highest defect leakage by origination→detection phase | **C-01** + unverified phase-column population |
| 110 | How much deal value is at risk in Red and Amber projects? | `tbl_clients` join + `deal_value` population **[UNVERIFIED]** |
| 128 | Largest estimate-to-actual effort variance | `tbl_clients` join **[UNVERIFIED]** |
| 139 | Which risks remain high after mitigation? | **C-12** — risk banding model (query currently uses an invented `>= 15` threshold that matches neither the 3-band nor 4-band model) |
| 142 | High-exposure risks lacking mitigation/contingency/responsibility/closure date | **C-12** (same) |

---

## 7. What to do next

**Five verification queries would close most of the remaining unknowns** (all read-only, all fast):

```sql
-- 1. Does deal_value actually carry data? (unblocks 6 KPI questions)
SELECT COUNT(*) total, SUM(deal_value IS NULL OR deal_value = 0) AS missing
FROM tbl_projects WHERE status = 1 AND archive = 0;

-- 2. Is issue severity actually captured? (settles C-01 in practice)
SELECT severity, COUNT(*) FROM tbl_project_issues WHERE status = 1 GROUP BY severity;

-- 3. Which tbl_clients join target is correct? (unblocks client reporting)
SELECT (SELECT COUNT(*) FROM tbl_projects WHERE status=1) AS projects,
       (SELECT COUNT(*) FROM tbl_projects p JOIN tbl_clients c ON c.id = p.client_id) AS via_id,
       (SELECT COUNT(*) FROM tbl_projects p JOIN tbl_clients c ON c.client_id = p.client_id) AS via_client_id;

-- 4. Defect phase columns populated? (unblocks row 135)
SELECT COUNT(*) total,
       SUM(defect_origination_phase = 0) AS no_origination,
       SUM(defect_detection_phase = 0) AS no_detection
FROM tbl_project_issues WHERE status = 1;

-- 5. Acceptance criteria coverage? (validates row 132)
SELECT COUNT(*) total,
       SUM(acceptance_criteria IS NULL OR TRIM(acceptance_criteria) = '') AS missing
FROM tbl_project_tasks WHERE status = 1 AND archive = 0;
```

**Decisions still needed from the business, not the database:**
- **C-01** — is issue severity worth reporting at all, given it is not captured in the form? (3 questions hang on this)
- **C-12** — which risk banding model: 3-band (≥20/12–19/<12, as hardcoded in the app) or 4-band? (2 questions)
- Whether the 8 "period → current state" questions in §5.1 should be **re-worded** to match what they now return, or **retired** alongside the §4 list.
- Whether the 6 `actual_hours` questions in §5.3 should be re-pointed at timesheet aggregates (recommended) or left as-is.
