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

**Update — codebase analysis complete.** Every question below has been checked against the actual PHP application logic. Many items previously marked "needs a business decision" are now settled by the code. Where the code contradicts an earlier answer, that is called out explicitly and needs a decision, not an approval.

### Where to find what is still outstanding

This document is the full questionnaire with answers merged in. Two companion files track only what remains:

| File | Contains |
| ---- | -------- |
| [PMS_Contradictions_Requiring_Decision.md](PMS_Contradictions_Requiring_Decision.md) | **12 decisions (C-01…C-12)** — items where the code and the answered questionnaire disagree. Each states both candidate logics, the SQL that changes, and the blast radius. |
| [PMS_Open_Items_Pending.md](PMS_Open_Items_Pending.md) | **26 items (O-01…O-26)** — items with no logic defined anywhere. Grouped into lookups, formulas, test data, and governance, with the SQL skeleton for each. |

### Legend

| Marker | Meaning |
| ------ | ------- |
| ✅ **Resolved from code** | The application's behaviour is definitive. No decision needed — just adopt it. |
| ⚠️ **Conflict — decision required** | An earlier answer contradicts the code. Someone must choose which one wins. |
| 🔍 **One DB query away** | Mechanism is settled; only live row values are missing. |
| ❌ **Open** | No logic exists. Genuine business decision or external input. |

---

## 0. Findings That Change the Whole Document

Read these three before anything else — they affect most of the 50 mapped queries.

### 0.1 Task and issue status IDs must never be hardcoded ⚠️

`status_type` is a 5-value classifier column on every status row. The application **always** resolves open/closed by joining to the status table and filtering on `status_type` — it never hardcodes status IDs.

```text
status_type: 1 => New
             2 => In Progress
             3 => Closed
             4 => UAT
             5 => Abandoned/Deferred
```

Documented verbatim at four places in the code: `Project_model.php:10850`, `Project_model.php:12011`, `Task/index.php:2955`, `Task/index.php:6809`.

The same enum governs **both** `tbl_project_task_status` and `tbl_project_issue_status`. This supersedes the hardcoded ID lists previously approved in §1.3 and §1.4.

### 0.2 Status rows may be per-project — governed by a server constant ❌

Both status tables carry a `project_id` column. Every status lookup is wrapped in:

```php
if ( defined('GLOBAL_PROJECT_STATUS') && GLOBAL_PROJECT_STATUS == true ) {
    $cond .= ' AND project_id = 0';              // one global status set
} else if ( $project_id ) {
    $cond .= ' AND project_id = '.$project_id;   // per-project status set
}
```

`GLOBAL_PROJECT_STATUS` lives in the **gitignored** site config, so its value must be read from the server. Our validation found a single clean list of IDs 1–13, which suggests this deployment runs `GLOBAL_PROJECT_STATUS = true`.

> **Required from your end:** confirm the value of `GLOBAL_PROJECT_STATUS` on the server. If it is `false`, every project has its own status rows and **every** status-filtering query must also filter `project_id`.

### 0.3 Timesheet hours are split across two columns ✅

`tbl_timesheets` has **no** decimal hours column. It stores `hours` INT and `minutes` INT separately. Every hours calculation in the app is:

```sql
SUM(hours) + (SUM(minutes) / 60)
```

Any query reporting `SUM(hours)` alone silently under-reports effort. There is also **no `chargeable` column on timesheets** — chargeable is a `'Y'`/`'N'` flag on `tbl_project_tasks`.

---

## 1. Mandatory Business-Rule Confirmations

### 1.1 Meaning of “My Projects” — ✅ Resolved from code

Please confirm which records should be included when a user asks:

> What are my projects?

Choose one rule:

- Projects where the user is an accepted project member
- Projects where the user is the project manager
- Projects where the user is the project owner
- Union of project member, project manager, and project owner
- A different RBAC rule

> **Answer (confirmed by code):** **Accepted project membership only — not a union.**
>
> The canonical implementation is `getUserProjects()` (`Project_model.php:6840`):
>
> ```sql
> SELECT tbl_projects.*
> FROM tbl_projects
> LEFT JOIN tbl_project_users ON tbl_projects.project_id = tbl_project_users.project_id
> WHERE tbl_projects.status = 1
>   AND tbl_project_users.request_status = 'A'
>   AND tbl_project_users.status = 1
>   AND tbl_project_users.user_id = ?
> GROUP BY tbl_projects.project_id
> ```
>
> - `request_status` is a **CHAR**, not an int: `'A'` = Accepted, `'I'` = Invited, `'R'` = Rejected (`Project_model.php:3177`, `:3320`).
> - **The owner is always also a member** — on project creation the creator is auto-inserted into `tbl_project_users` with `access_type = 'ADMIN'`, `request_status = 'A'` (`Project_model.php:609-618`). `getUserOwnProjects()` still requires `request_status = 'A'` on top of `project_owner_id`.
> - **The project manager is a separate field**, `tbl_projects.pm_user_id`, distinct from `project_owner_id`. Nothing enforces that a PM is a member, so a union rule would add rows only for legacy/imported data.
>
> A union rule is **wider than the app**. If Orbit answers "my projects" with a union, its output will not match what the user sees in Collab.

#### Two RBAC filters this questionnaire omitted entirely ⚠️

Every project-listing query in the app appends two more filters that none of our mapped SQL includes:

1. **Company privacy** — `chkPrivateProject()` (`Project_model.php:84`). If the user's company is flagged private, results are restricted to `company_id = <user company>`; otherwise projects belonging to `private_company_ids` are excluded. **Omitting this leaks projects across company boundaries.**
2. **Archive toggle** — `chkHideArchiveProject()` (`Project_model.php:12192`):

```php
if ($hide_archive == 'TRUE') { $sql .= ' AND archive = 0 '; }
else                         { $sql .= ' AND archive = 1 '; }
```

Please confirm whether archived and inactive projects must always be excluded.

> **Answer:** Yes — always excluded.
>
> ⚠️ Note this is a **deliberate divergence from the app**. The app's archive handling is a session *toggle* — it shows either non-archived **or** archived, never both. "Always exclude archived" is a new, stricter reporting rule. Reasonable, but record it as a knowing divergence.

> **Still required from your end:** approve adding the **company-privacy filter** to all project queries. This is a data-leakage concern, not a preference.

---

### 1.2 Active Project Definition — ✅ Resolved from code (earlier answer confirmed)

The database shows the following project statuses:

| Status ID | Status Name     |
| --------: | --------------- |
|         0 | Unspecified     |
|         1 | PendingApproval |
|         2 | Active          |
|         5 | Approved        |

Required confirmation:

- Should `Approved` projects also be treated as active?
- Should `PendingApproval` projects appear in executive dashboards?
- How should projects with status ID `0` be treated?

> **Answer (confirmed by code):**
>
> ```text
> Active Project = tbl_projects.status = 1 AND tbl_projects.archive = 0
> ```
>
> Do not consider `project_status_id` at all. **The structural reason:** `tbl_project_status` has **no `status_type` column** — its columns are `status_id, group_id, color_code, project_type_id, status_name, status_order, status`. It is scoped per **group** and **project type** and carries no open/closed semantics. There is no code-derivable way to classify a `project_status_id` as "active".
>
> The executive dashboard's own baseline (`getAllProjectSummary()`, `Dashboard_model.php:735-741`) is:
>
> ```sql
> WHERE tbl_projects.status = 1
>   AND groups.status = 1
>   AND tbl_projects.start_date != '0000-00-00 00:00:00'
>   AND tbl_projects.end_date   != '0000-00-00 00:00:00'
> ```
>
> `project_status_id` is applied **only** when a user explicitly picks a status filter (`:742-744`).
>
> **All three sub-questions are therefore moot** — `Approved`, `PendingApproval` and `0` carry no machine-readable meaning. Treat `project_status_id` as a display label only.
>
> Note: `status` is the soft-delete flag; `archive` is independent. `is_approved` is set by a single approval action (`Project/index.php:8805`) and is used in no listing filter.

> **Live re-verification (2026-08-10):** Ran the `my_active_projects` query (`pms sql verifier.py` row 1) against live `engagedb` for `user_id = 3066`. All 7 returned projects had `status_name = NULL` (i.e. `project_status_id = 0`, unset). This is **expected, not a bug** — it's the direct, predicted consequence of the rule above. `status_name`/`stage_name` being blank does not disqualify a project from being "active"; do not re-flag this as a defect. System-wide, only 5 projects total currently have `project_status_id = 2` ("Active" by label), so any filter added on `project_status_id` would make "active projects" return almost nothing — confirming that filtering on it, rather than ignoring it, would be the actual bug.

---

### 1.3 Open Task Definition — ⚠️ Code contradicts the earlier answer

The database contains these task statuses:

|  ID | Status           |
| --: | ---------------- |
|   1 | New              |
|   2 | InProgress       |
|   3 | Complete         |
|   4 | ReOpen           |
|   5 | OnHold           |
|   6 | ReTest           |
|   7 | UAT              |
|   8 | Live             |
|   9 | Approve          |
|  10 | Abandon          |
|  11 | QAPass           |
|  12 | ReqComplete      |
|  13 | Completed in Dev |

Please confirm which status IDs count as Open, In progress, Completed, Closed, Abandoned, Pending approval.

> ~~**Earlier answer:** Open = status IDs `1, 2, 4, 5, 6, 7, 9, 11, 13`; Completed/Closed = `3, 8, 12`; Abandoned = `10`. Approved.~~
>
> ⚠️ **Superseded — the app never hardcodes status IDs.** Per §0.1 the correct rule is by `status_type`:
>
> ```text
> Open              = status_type IN (1, 2, 4)   -- New, In Progress, UAT
> Completed/Closed  = status_type = 3
> Abandoned         = status_type = 5
> ```
>
> Evidence:
>
> - `checkTaskInProgress()` returns "in progress" when `status_type NOT IN (1,3)` (`Project_model.php:11918`)
> - `getClosedTask()` counts `status_type = 3` (`:11337`)
> - `getDefaultTaskStatus()` picks `status_type = 1` for a new task (`:11657`)
> - `getOverdueTasks()` uses `status_type = 2` (`:3498`)
> - the Abandon status is fetched as `getProjectTaskStatus(0, $project_id, '', 5)` (`Project/index.php:9608`)
>
> The earlier ID list was close but wrong in two ways: it omits `status_type = 4` (UAT) as its own class, and it puts ID `10 (Abandon)` in a bespoke bucket rather than `status_type = 5`. More importantly, hardcoded IDs break the moment a status is added or a second project gets its own status set.

**Two further filters every task-count query must apply:**

1. `AND task_id != parent_id` — excludes self-referencing parent placeholder rows (`Project_model.php:10846`).
2. `AND ignore_report = 'N'` — `tbl_project_tasks.ignore_report = 'Y'` means "exclude from reports" and the app honours it (`Group/index.php:7640-7641`). KPI queries that skip this **over-count**.

> **Still required from your end:**
>
> 1. 🔍 Run the status query in §12 to list `status_type` per row — this replaces all guessed ID lists.
> 2. ❌ The **"In progress"** and **"Pending approval"** buckets in the original question are still unmapped. `status_type = 2` covers In Progress; there is **no** "pending approval" concept in the task enum. Confirm whether that bucket should be dropped.
>
> **Caveat to verify:** the app fetches a status for a type with `dbSelectSingle` — it assumes **exactly one** status row per `status_type` per project. If your data has several (e.g. `QAPass` and `ReTest` both `status_type = 2`), the app silently picks one and its own counts are already incomplete. Check with `GROUP BY status_type HAVING COUNT(*) > 1`.

---

### 1.4 Open Issue Definition — ⚠️ Code contradicts the earlier answer

The database contains these issue statuses:

|  ID | Status       |
| --: | ------------ |
|   1 | Raised       |
|   2 | InProgress   |
|   3 | Complete     |
|   4 | Acknowledged |
|   5 | Abandonned   |
|   6 | Critical     |
|   7 | Reopen       |
|   8 | Dev Complete |
|   9 | QA Complete  |
|  10 | Closed       |

> ~~**Earlier answer:** a per-ID mapping asserting that `2 InProgress` is treated as **Closed** by the app, and `3 Complete` is **Open**.~~
>
> ⚠️ **Superseded.** Same `status_type` mechanism, same enum as §0.1:
>
> ```text
> Open              = status_type IN (1, 2, 4)
> Resolved/Closed   = status_type = 3
> Abandoned         = status_type = 5
> ```
>
> `openIssues()` carries an explicit comment in the source:
>
> ```php
> // 1=>NEW, 2=>IN_PROGRESS status type
> ... WHERE tbl_project_issue_status.status_type IN(1,2)
> ```
>
> (`Project_model.php:9080-9086`, repeated at `:12247`.) `getClosedIssue()` uses `status_type = 3` (`:11355`); `getLongestOpenIssues()` uses `status_type != 3` (`:3554`).
>
> **On the claim "InProgress(2) is treated as CLOSED by the app":** there is **no such special case anywhere in the code**. Behaviour is driven purely by that row's `status_type`. If issue status ID 2 behaves as closed, it is because `tbl_project_issue_status.status_type = 3` **in your data** — a data-quality issue, not app logic.

> **Still required from your end:**
>
> 1. 🔍 Run the issue-status query in §12 — it settles this definitively.
> 2. ❌ The **"Critical issue"** bucket is still undefined. ID 6 is named `Critical` but severity is a separate column (§1.5). Confirm whether "critical issue" means `status_id = 6` or `severity = high`.

---

### 1.5 Issue Severity and Priority Mapping — ⚠️ Code contradicts the earlier answer — **decision required**

Issue severity and priority values found in the database are `0, 1, 2, 3`.

> ~~**Earlier answer:** `1 = High, 2 = Medium, 3 = Low`.~~
>
> ⚠️ **This is inverted relative to the application.** `Project/index.php:3197-3204`:
>
> ```php
> $priority_arr = array('1'=>'Low','2'=>'Medium','3'=>'High');
> ...
> $priority  = $priority_arr[$issue_detail['priority']];
> $severity  = $priority_arr[$issue_detail['severity']];
> ```
>
> **One array serves both `severity` and `priority`:**
>
> | Value | Label (per the app) |
> | ----: | ------------------- |
> |     0 | *no label* — undefined index, renders blank |
> |     1 | Low |
> |     2 | Medium |
> |     3 | High |
>
> If Orbit adopts the earlier answer, **every "high-severity issues" question will return the *lowest*-severity records.**

> **Required from your end — this is a correctness decision, not a preference:**
>
> - **Either** correct the questionnaire mapping to `1 = Low, 2 = Medium, 3 = High` (matches the app), **or** change the app. Pick one.
> - Confirm the label for value `0` (the app renders it blank).
> - Confirm the same mapping applies to **both** `severity` and `priority` — the code uses one array for both.
>
> **Do not conflate three different fields:** `tbl_project_issues.severity`, `tbl_project_issues.priority`, and a separate `impact_id` FK → `tbl_project_impact`, which the issue *report* uses as its priority axis (`Project_model.php:11316-11321`).

---

### 1.6 Project Priority Mapping — ✅ Mechanism resolved / 🔍 values need one DB read

> ~~**Earlier answer:** `1 = Low, 2 = Medium, 3 = High`.~~ Plausible, but it must be verified — and it cannot be hardcoded.
>
> ✅ **`tbl_projects.priority` is a foreign key, not an enum.** The app resolves the label through the master table:
>
> ```php
> $priority_details = $this->objProject->getProjectPriorityDetailsByID( $project_details['priority'] );
> $project_list[$i]['priority'] = $priority_details['priority_name'];
> ```
>
> `tbl_project_priority` = `priority_id, project_type_id, priority_name, priority_order, status`.
>
> **Why the master table looked "unreliable": it is scoped by `project_type_id`.** The same `priority_id` can carry a different name per project type, and rows with `status != 1` are retired. There is no single global map — the correct approach is to **join, not hardcode**:
>
> ```sql
> SELECT p.project_id, pr.priority_name
> FROM tbl_projects p
> LEFT JOIN tbl_project_priority pr ON p.priority = pr.priority_id
> ```
>
> ⚠️ Beware three **mutually inconsistent** hardcoded priority arrays elsewhere in the code, all used only for Excel-import validation and none authoritative: `array('High','Low','Urgent','Strategic')` (`Project/index.php:132`), `array('High','Low','Medium')` (`Task/index.php:2541`), `array('High','Medium','Low')` (`Task/index.php:4553`).

> **Still required from your end:** 🔍 run the priority query in §12 and confirm the actual rows. Note the DB values found were `0, 2, 3` — so `0` still needs a disposition and `1` does not occur in the data.

---

### 1.7 Utilization Formula — ✅ Formula resolved / ❌ capacity assumptions still open

> **Answer (confirmed by code):** **Option A is exactly what the app does**, with a **monthly** — not weekly — denominator, **capped at 100%**.
>
> `Dashboard/index.php:2688` (duplicated for the Excel export at `:3746`):
>
> ```php
> $percentage = ($monthly_hours[$j]['hours'] + ($monthly_hours[$j]['minutes'] / 60))
>               / MONTHLY_BILLING_HOURS * 100;
> $percentage = $percentage > 100 ? 100 : $percentage;
> ```
>
> ```text
> Utilization % = (SUM(hours) + SUM(minutes)/60) / MONTHLY_BILLING_HOURS × 100, capped at 100
> ```
>
> Hours come from `userMonthlyHours()` (`Dashboard_model.php:858-876`) — grouped by `LEFT(timesheet_date, 7)`, i.e. **calendar month**, **all** hours, **not** filtered by chargeable.
>
> **Option B (chargeable)** is feasible via `tbl_project_tasks.chargeable = 'Y'` (`Dashboard_model.php:908-909`).
> **Option C (allocated/capacity)** is feasible from `tbl_project_users.allocation_hrs` — the app already aggregates `SUM(allocation_hrs) AS tot_allocated_hrs` (`Project_model.php:12395`) — but still needs a capacity denominator.

The app's existing utilization colour bands, usable as reporting bands:

| Utilization | Colour    |
| ----------- | --------- |
| 100%        | `#56f75d` |
| 90–99%      | `#afe6b1` |
| 80–89%      | `#c0d8a3` |
| 70–79%      | `#debd58` |
| 60–69%      | `#d8c791` |
| 50–59%      | `#e0b34c` |
| 1–49%       | `#f44336` |
| 0%          | `#fffefe` |

**Still required from your end:**

| Sub-question | Status |
| ------------ | ------ |
| Monthly capacity calculation | 🔍 It is the constant `MONTHLY_BILLING_HOURS`. **Not defined anywhere in the repository** — only consumed. Read it from the server's gitignored site config. |
| Weekly capacity per employee | ❌ No such constant or calculation exists. |
| Working days per week | ❌ No such constant or calculation exists. |
| Treatment of leave and holidays | ❌ **No holiday, leave, or working-calendar table exists** in the schema. Cannot be computed — must come from HR or be deferred. |
| Treatment of part-time resources | ❌ No FTE or contracted-hours field on the user tables. `tbl_project_users` has `allocation_hrs`, `allocation_from`, `allocation_to`, `resource_type` — per-project allocation, not person-level capacity. |
| Over-allocation threshold | ❌ Not in code — **and note the app caps at 100%**, so it is structurally incapable of showing over-allocation today. Any >100% KPI is new behaviour. |

---

### 1.8 Project Completion Formula — ❌ Not in code (genuine business decision)

> **Answer:** Option C — weighted average using task estimate:
>
> ```text
> Weighted Project Completion = SUM(Task Estimate × Task Percent Complete) / SUM(Task Estimate)
> ```
>
> Rationale: a 100-hour task at 50% contributes proportionally more than a 2-hour task at 50%; reflects actual effort weight. Tasks with `estimate = 0` are excluded from the weighted calculation.

> **Code check:** ✅ this answer stands — but be aware it is **greenfield**, not a match to existing behaviour.
>
> **No project-completion percentage exists anywhere in the application.** Verified:
>
> - `tbl_project_tasks.percent_complete` exists but is only ever **displayed per task**. It is never aggregated to project level.
> - The dashboard's "project progress" (`Dashboard/index.php:561`) is a **Gantt timeline** — start/end dates, `no_of_days`, plus a tooltip comparing `estimate` against `hours_used`. No percentage.
>
> So there is no existing behaviour to match or contradict. Fields available: `tbl_project_tasks.estimate`, `estimate_complete`, `actual_hours`, `percent_complete`; `tbl_projects.estimate`.

**Three things this formula must still resolve:**

1. ❌ **Subtask handling.** The app rolls subtask hours into the master task (`Task/index.php:2949`), so summing all rows **double-counts**. Decide whether subtasks are counted or rolled up.
2. ✅ **Two mandatory exclusions** carried over from §1.3: `task_id != parent_id` and `ignore_report = 'N'`.
3. 🔍 **Data-coverage check before committing.** Weighted completion depends on PMs populating **both** `estimate` and `percent_complete` on every task. Verify coverage first:

```sql
SELECT COUNT(*) AS total,
       SUM(estimate IS NULL OR estimate = 0)  AS no_estimate,
       SUM(percent_complete IS NULL)          AS no_pct
FROM tbl_project_tasks WHERE status = 1 AND ignore_report = 'N';
```

**A cheaper alternative worth considering:** the app already treats *effort consumed vs. estimate* as its progress signal. `SUM(timesheet hours) / tbl_projects.estimate` requires no new data entry, whereas weighted completion depends on data whose completeness is unverified.

---

### 1.9 Project Health or Executive Attention Score — ❌ Not in code (entirely new)

Suggested indicators:

| Indicator                       | Suggested Weight |
| ------------------------------- | ---------------: |
| Overdue high-priority tasks     |              20% |
| Red or Amber task concentration |              15% |
| Open high risks                 |              20% |
| Overdue unresolved issues       |              15% |
| Effort overrun                  |              15% |
| End-date exposure               |              10% |
| Stale project activity          |               5% |

> **Answered so far — score bands only:**
>
> | Band  | Score Range | Meaning                               |
> | ----- | ----------: | ------------------------------------- |
> | Green |        0–25 | Healthy — no leadership action needed |
> | Amber |       26–55 | Watch — flag for next review          |
> | Red   |      56–100 | Immediate attention required          |

> **Code check: no health, attention, or composite score exists anywhere.** Three fields that look like candidates are all false leads:
>
> - **`tbl_projects.rag` is a manually-entered string**, not a computed value — `'Red'`, `'Amber'`, `'Green'`, `'Gray'` (`Project/index.php:135`). Tasks and issues use a 3-value variant without `'Gray'` (`Issue/index.php:49`). It is stored as a **string, so filter on `rag = 'Red'`, not an ID.** The earlier caution that stored RAG is sparse and should not be the primary indicator is well-founded — nothing computes it.
> - **`tbl_projects.overall_score` is not a health score.** It belongs to the EHS/audit module (`Ehs/index.php:452`, `:630`) and is written only by project audits.
> - **`attention_required` is not a health flag.** It is a delimited list of **user IDs** matched with `LIKE '%id%'` (`Project_model.php:2307`, `:3710`) — i.e. "who must look at this". Do not use it as a severity signal.

> **Still required from your end (4 items):**
>
> - ❌ Final indicators
> - ❌ Weights
> - ❌ Per-indicator thresholds (distinct from the score bands above)
> - ❌ Whether stored project RAG should affect the score
>
> Note two of the seven indicators depend on §1.7 and §1.8, which are themselves unresolved.

---

### 1.10 Risk Exposure Formula — ✅ Resolved from code (earlier answer confirmed exactly)

> **Answer (confirmed by code):** `Risk/index.php:253-263`, repeated identically at `:1347`, `:1887`, `:2152`:
>
> ```php
> $rating = (int) ($probability_value * $impact_value);
>
> if      ($rating >= 20)                  { $rating_color_code = $red;   }
> elseif  ($rating >= 12 && $rating < 20)  { $rating_color_code = $amber; }
> elseif  ($rating < 12)                   { $rating_color_code = $green; }
> ```
>
> ```text
> Risk Score = probability_value × impact_value   (integer cast)
>
> Red    : rating >= 20
> Amber  : rating 12–19
> Green  : rating < 12
> ```
>
> - **Formula correct — yes, use the stored rating.** ✅ The result is **persisted** to `tbl_risk.rating` and `tbl_risk.rating_color_code`, so reading it is correct and cheaper than recomputing.
> - **Priority does not affect the score** ✅ — `risk_priority_id` is filter-only (`Risk_model.php:583-589`).
> - **Open risks only** ✅ — but note **two different `status` concepts**. `tbl_risk_status.status_type` is only **`1 => New, 2 => Closed`** (`Risk/index.php:1365`), *and* `tbl_risk.status` is the soft-delete flag. Correct filter:
>
>   ```sql
>   JOIN tbl_risk_status rs ON r.status_id = rs.status_id
>   WHERE rs.status_type = 1   -- open
>     AND r.status = 1         -- not deleted
>   ```
>
>   ⚠️ This enum is **2 values only** — unlike the 5-value task/issue enum in §0.1. Do not reuse one for the other.
> - **Thresholds — the 3-band model is confirmed.** There is **no Low/Medium/High/Critical 4-band model in the code.** If leadership wants a Critical band, that is new behaviour.
> - `probability_value` ← `tbl_risk_probability`; `impact_value` ← `tbl_risk_impact`. **Both default to `1` when unset** (`Risk/index.php:247,251`) — so a risk with no probability/impact scores 1 (Green), not null.

> **Still required from your end:**
>
> - ❌ **Residual risk.** `tbl_risk` carries `revised_probability`, `revised_impact` and `after_mitigation_risk_score`, but **no code computes a revised rating** — `rating` is always from the original values. Substituting residual risk would be new behaviour. Business decision.

---

## 2. Production Identifier Decisions — ✅ Resolved from code (with one correction)

| User-Facing Selection | Value Passed to SQL                         |
| --------------------- | ------------------------------------------- |
| Project name          | `project_id` or `project_unique_id`         |
| Employee name         | `user_id`                                   |
| Task reference        | `task_id` or project ID + reference number  |
| Risk reference        | `risk_id` or project ID + reference number  |
| Issue reference       | `issue_id` or project ID + reference number |
| Department name       | `department_id`                             |

Required confirmation: **Confirmed.**

> **Answer (all four uniqueness annotations confirmed by code):** reference numbers are per-project counters generated as `COUNT(...) + 1`:
>
> | Entity | Generation | Evidence |
> | ------ | ---------- | -------- |
> | Task  | `getProjectWiseTaskCount($project_id) + 1`   | `Task/index.php:253-254`, `:303-304` |
> | Issue | `getProjectWiseIsssueCount($project_id) + 1` | `Issue/index.php:157-158` |
> | Risk  | `getProjectWiseRiskCount($project_id) + 1`   | `Risk/index.php:223-224` |
> | RCA   | `$projectwise_rca_count + 1`                 | `Rca/index.php:132` |
>
> ⚠️ **Worse than previously stated:** because these are `COUNT + 1` rather than `MAX + 1` sequences, they are **not reliably unique even within a project** — a deletion causes the next insert to reuse a number, and two concurrent inserts collide. Reference numbers should be treated as **display text only, never as a lookup key.**
>
> **Project titles are not unique** ✅ — no unique constraint in the table object. `tbl_projects` additionally carries `project_unique_id`, `short_url` and `reference_no` as alternate keys, and `short_url` is explicitly de-duplicated at insert time (`Project_model.php:597` → `prepareShortUrl`) — indirect evidence that titles collide in practice.

### ⚠️ Correction to the recommended identifier rule

> ~~Risk → `project_risk_id` (globally unique — note: NOT `risk_id`)~~
>
> **This pointed at the wrong table.** There are two parallel risk tables:
>
> | Table | PK | Role |
> | ----- | -- | ---- |
> | **`tbl_risk`** | **`risk_id`** | **The operational risk register the Risk module reads and writes.** Has `reference_no`, `rating`, `rating_color_code`, `probability_id`, `impact_id`, `status_id`. |
> | `tbl_project_risk` | `project_risk_id` | A separate **versioned** register (`version` column) with `original_risk_score` / `after_mitigation_risk_score`. **Has no `reference_no`.** |
>
> `Risk_model` loads both, but every list, count, search and report query uses `tbl_risk` (`Risk_model.php:198,594,709,1236`); `tbl_project_risk` is touched only by a two-line versioned insert (`:209-214`). Everything in §1.10 applies to **`tbl_risk`**.

**Corrected identifier rule:**

```text
Task    → tbl_project_tasks.task_id
Issue   → tbl_project_issues.issue_id
Risk    → tbl_risk.risk_id                        ← not project_risk_id
Project → tbl_projects.project_id
User    → user_id
Dept    → tbl_project_department.department_id    (see §5)
```

```text
Display names and references to the user, but pass internal IDs to the query.
```

> **Still required from your end:** 🔍 confirm the absence of a unique index on project titles with `SHOW INDEX FROM tbl_projects;`.

---

## 3. UAT Test Data Required — ❌ Open (DB read needed)

Not derivable from source. **Please supply user and project IDs, not names** — per §2, names are not reliable keys.

### 3.1 User Samples — ✅ named, 🔍 IDs still needed

- One user who manages at least one project [Saurav Kaushik]
- One user who owns at least one project [Saurav Kaushik]
- One user with accepted project allocations [Saurav Kaushik]
- One user with task assignments [Saurav Kaushik]
- One user with timesheets in the selected date range [Saurav Kaushik]
- One user with mapped skills [Saurav Kaushik]

> **Still needed:** the numeric `user_id` for this user.

### 3.2 Project Samples — 2 of 7 filled

- One active project with tasks [DE_Bandhan AMC_AMC Renewal of Bank's Website for 252 Mandays (2512/BFS/6265) ]
- One project with timesheets [DE_Bandhan AMC_AMC Renewal of Bank's Website for 252 Mandays (2512/BFS/6265) ]
- ❌ One project with issues
- ❌ One project with risks
- ❌ One project with executive-summary data
- ❌ One project with infrastructure-cost data
- ❌ One project with active allocated users

Resolve the first three of those with one query rather than by hand:

```sql
SELECT p.project_id, p.title,
       (SELECT COUNT(*) FROM tbl_project_issues i WHERE i.project_id = p.project_id AND i.status = 1) AS issues,
       (SELECT COUNT(*) FROM tbl_risk r          WHERE r.project_id = p.project_id AND r.status = 1) AS risks,
       (SELECT COUNT(*) FROM tbl_project_users u WHERE u.project_id = p.project_id AND u.request_status = 'A' AND u.status = 1) AS members
FROM tbl_projects p
WHERE p.status = 1 AND p.archive = 0
HAVING issues > 0 AND risks > 0 AND members > 1
LIMIT 5;
```

The executive-summary and infrastructure-cost slots map to `tbl_project_executive_summary` and the `tbl_project_infrastructure_*` tables, whose population is not yet confirmed.

### 3.3 Transaction Samples — ❌ all 6 still blank

- One task with assignees
- One task with subtasks
- One task with timesheet entries
- One risk with history
- One issue with a valid reference
- One department linked to active projects (see §5)

These samples do not need to contain sensitive information. IDs alone are sufficient.

---

## 4. MCP Usage Required From Your End — ✅ sound as written, one addition

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

> **⚠️ One addition from the code review:** this schema uses `'0000-00-00 00:00:00'` sentinel dates extensively (see §1.2). Ensure the MCP connection does **not** run with `NO_ZERO_DATE` / strict mode, or those rows will error rather than return.

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

## 5. Department Query Validation — ⚠️ The original SQL referenced a non-existent table

The department query was skipped because no valid `department_name` parameter was discovered. **We now know why: the lookup table was being read under the wrong name.**

The table is **`tbl_project_department`**, not `department`:

```text
tbl_project_department: department_id, company_id, department_name, post_date, post_ip, update_date, status
```

Corrected query:

```sql
SELECT d.department_id, d.department_name, COUNT(*) AS project_count
FROM tbl_project_department d
JOIN tbl_projects p ON p.department_id = d.department_id
WHERE p.status = 1
  AND p.archive = 0
  AND d.status = 1                    -- department not retired
  AND d.department_name IS NOT NULL
  AND d.department_name <> ''
GROUP BY d.department_id, d.department_name
ORDER BY project_count DESC
LIMIT 10;
```

Note `department_id` on `tbl_projects` is a plain int column with **no FK constraint**, and `tbl_project_department` is scoped by `company_id` — so department names may repeat across companies. Join on ID and, for multi-company reporting, group by `(company_id, department_id)`.

> **Still required from your end:** 🔍 run the corrected query and share one valid department ID and name for UAT.

---

## 6. Performance Review and Index Approval — partially answerable

Several queries executed successfully but performed large scans. Please ask the DBA or technical team to review indexes for:

- Project title and project status filters
- Task reference number
- Task project/status/due-date combinations
- Timesheet user/date combinations
- Timesheet task/date combinations
- Project-user user/status/request-status combinations
- Risk reference number
- Issue reference number

**Two concrete inputs surfaced by the code review:**

1. **A captured slow-query log already exists in the app repo** — `source/application/modules/Risk/classes/Project-mysql-slow-queries`. These are real slow statements from this application, including the task-listing queries with the `IF(t2.parent_id > 0, …)` self-join pattern. **Start the index review here** — it is production evidence rather than synthetic test queries.
2. **Prior optimisation work is already recorded** (`.claude/memory/perf_n1_fixes.md`): batch pre-fetch fixes for the issue/task listing pages and a `getTotalTasks` COUNT optimisation, **with `ALTER TABLE` statements still pending on the server**. Those pending indexes likely overlap the list above — reconcile before proposing new ones so the DBA receives one combined change set.

Recommended production approach (all consistent with how the app behaves):

- Prefer IDs over names — reinforced by §2
- Filter the parent entity before joining large transaction tables
- Add composite indexes only after reviewing existing indexes and write impact
- Do not create indexes directly in production without DBA approval

---

## 7. Executive/KPI Questions Requiring Sign-Off — ❌ Not in code

**None of the 21 KPIs below exist as implemented calculations.** They decompose into the primitives above, and their feasibility follows directly:

| KPI group | Feasible today? | Blocking dependency |
| --------- | --------------- | ------------------- |
| 7.1 Portfolio Health | **No** | §1.9 undefined (and RAG is manual + sparse) |
| 7.2 Task Delivery | **Mostly yes** | overdue/priority/RAG all queryable; "effort vs work completed" needs §1.8 |
| 7.3 Risk & Issue Exposure | **Yes** | §1.10 fully defined; needs §1.5 severity resolved first |
| 7.4 Resource & Capacity | **Partly** | `allocation_from`/`_to`/`_hrs` support "ending soon" and demand; over/under-utilisation blocked on `MONTHLY_BILLING_HOURS` and the 100% cap (§1.7) |
| 7.5 Financial & Effort | **Partly** | `deal_value`, `estimate`, `total_hours_booked`, `total_chargable_hours` exist on `tbl_projects`; "unhealthy" needs §1.9 |

> **Recommended sequencing:** ship **7.3 and 7.2 first** — they rest on the two rules already confirmed by code (§1.10 risk scoring, §1.3/§1.4 status types) and need no new formulas. Defer 7.1 and the utilisation half of 7.4 until §1.7 and §1.9 are signed off.

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

For each KPI, please confirm: formula, threshold, reporting period, inclusion/exclusion criteria, required drill-down fields, expected dashboard visualization.

Useful pre-computed fields on `tbl_projects` for 7.5: `deal_value`, `deal_type`, `business_type`, `estimate`, `total_hours_booked`, `total_chargable_hours`, `combined_hours`, `grant_hours`, `project_duration`. 🔍 Verify these are maintained rather than legacy before relying on them.

---

## 8. Questions to Keep Deferred — ✅ table existence verified

| Deferred area | Table exists? | Recommendation |
| ------------- | ------------- | -------------- |
| Milestone progress / ownership | **Yes** — `TableProjectTaskMilestone`, `TableProjectTaskMilestoneMapping` | **Remain deferred** — tables exist but are reported empty. A feature-adoption gap, not a schema gap; may become viable with no code change. |
| Milestone-based completion | as above | Remain deferred; §1.8 chooses effort-weighted instead |
| Project estimation versions | **Yes** — `TableProjectEstimation`, `…AuditTrails`, `…Lineitem` | Remain deferred pending population check |
| Team-name questions | **Yes** — `TableProjectTeam` (+ `tbl_projects.team_id`) | Remain deferred |
| Project-stage aging | **Partly** — `project_stage_id` exists, but **no stage-change history table** | **Reframe** using `tbl_projects.update_date`, or **remove**. Exact aging is not reconstructible. |
| Predictive probability | n/a | **Remove from first release** — no historical model, and no stage history to train one |
| Leave / holiday / capacity calendar | **No such table anywhere** | **Add to this deferred list** — §1.7 depends on it; must come from HR |
| Skills-based questions | **Yes** — `TableMasterSkills`, `TableUserSkills` | **Viable** — §3.1 already names a user with mapped skills |

> **Still required from your end:** confirm the disposition (remain deferred / remove / reframe) for each row above.

---

## 9. Required Sign-Off Owners — ❌ Organisational, not derivable

Please identify the responsible **person** for each decision area.

| Decision Area                    | Suggested Owner            | Named Owner |
| -------------------------------- | -------------------------- | ----------- |
| Project status and lifecycle     | PMS Product Owner          | ❌          |
| Task workflow statuses           | Delivery/PMS Product Owner | ❌          |
| Issue workflow and severity      | QA/Delivery Governance     | ❌          |
| Risk formula and thresholds      | PMO/Risk Owner             | ❌          |
| Utilization and capacity         | Resource Management/HR     | ❌          |
| Financial fields and deal value  | Finance/Commercial Team    | ❌          |
| RBAC and “my” semantics          | Product Owner/Security     | ❌          |
| KPI weights and executive score  | PMO/Leadership             | ❌          |
| Database performance and indexes | DBA/Engineering            | ❌          |

> **Note:** §1.5 (severity inversion) and §2 (risk table correction) are **factual corrections, not preference choices**. They need an owner who can authorise a change to either the app or the questionnaire — not merely approve a mapping.

---

## 10. Minimum Inputs — Status After Codebase Analysis

| # | Input | Status |
| -: | ----- | ------ |
| 1 | Active-project definition | ✅ **Resolved from code** — `status = 1 AND archive = 0`; ignore `project_status_id` |
| 2 | Open/completed task status IDs | ✅ **Resolved as `status_type`** (1,2,4 / 3 / 5) — one DB query to list the rows |
| 3 | Open/closed issue status IDs | ✅ **Same mechanism** — same DB query |
| 4 | Issue severity & priority mapping | ⚠️ **Code says 1=Low, 2=Medium, 3=High** — the earlier answer is inverted. Decision required. |
| 5 | Project priority mapping | ✅ mechanism resolved (FK join); 🔍 row values need one DB query |
| 6 | Definition of “my projects” | ✅ **Resolved from code** — accepted membership + company-privacy filter |
| 7 | Utilization formula & capacity | ⚠️ formula resolved (Option A); ❌ `MONTHLY_BILLING_HOURS` from server, leave/holiday has no source |
| 8 | Project-completion formula | ❌ **No code exists** — genuine business decision; check estimate/percent_complete coverage first |
| 9 | Risk-score formula & thresholds | ✅ **Fully resolved** — `probability × impact`; Red ≥20, Amber 12–19, Green <12 |
| 10 | Executive-attention indicators & weights | ❌ **No code exists** — entirely new |
| 11 | Internal IDs in production | ✅ Confirmed, with the `tbl_risk.risk_id` correction |
| 12 | Valid department sample | ⚠️ **Table name was wrong** — the corrected query in §5 will return it |
| 13 | Representative UAT IDs | ❌ Needs DB queries (§3) |

**Net: 6 of 13 resolved from code, 3 partially resolved, 4 remain genuine business decisions** (#8, #10, the capacity/leave half of #7, and the #4 severity decision).

---

## 11. Optional but Recommended Inputs — code-side notes

| Input | Status |
| ----- | ------ |
| Definition of billable versus non-billable hours | ✅ **Already defined in code** — `tbl_project_tasks.chargeable IN ('Y','N')`, applied at `Dashboard_model.php:908`. Note it is a **task-level** attribute, so a timesheet entry inherits it from its task. |
| Known duplicate or legacy-data conditions | ✅ **Several found** — worth recording formally: duplicate project titles (§2); `COUNT+1` reference-number collisions (§2); `'0000-00-00 00:00:00'` sentinel dates (§1.2); two parallel risk tables (§2); and a large number of `*_bkp` / `_12-03-2025` / `modules_live_bkp` duplicate source files that must not be mistaken for live logic when tracing behaviour. |
| Expected working-hours calendar | ❌ No table exists — must come from HR (blocks §1.7) |
| Holiday and leave data source | ❌ No table exists — must come from HR (blocks §1.7) |
| Screenshot or export of existing PMS dashboards | ❌ External |
| Existing PMO KPI definitions | ❌ External |
| SLA and escalation rules | ❌ External |
| Expected report formats for CEO, PMO, PM, resource manager | ❌ External |
| Data-retention rules | ❌ External |
| Expected maximum query response time | ❌ External |

---

## 12. Recommended Next Actions

**Highest value first.**

1. **🔍 Run two queries** — they close items #2 and #3 and settle the §1.4 "InProgress is closed" anomaly:

   ```sql
   SELECT task_status_id,  project_id, status_name, status_type, status, status_order
   FROM tbl_project_task_status  ORDER BY project_id, status_order;

   SELECT issue_status_id, project_id, status_name, status_type, status, status_order
   FROM tbl_project_issue_status ORDER BY project_id, status_order;
   ```

2. **🔍 Read two constants from the server's site config** (gitignored, not in the app repo): `GLOBAL_PROJECT_STATUS` — decides whether status queries need a `project_id` filter (§0.2); and `MONTHLY_BILLING_HOURS` — unblocks all utilisation KPIs (§1.7).

3. **⚠️ Resolve the §1.5 severity inversion.** This is a correctness bug in the questionnaire, not a preference — every "high severity" answer depends on it.

4. **Rewrite the mapped SQL to join on `status_type`** instead of hardcoded status IDs, and add the three filters the app applies but our drafts omit: company privacy (§1.1), `task_id != parent_id` and `ignore_report = 'N'` (§1.3).

5. **Correct the risk identifier to `tbl_risk.risk_id`** and re-point any query currently aimed at `tbl_project_risk` (§2).

6. **Fix the department query** to `tbl_project_department` (§5) and capture the UAT sample.

7. **🔍 Run the project-priority query** (§1.6) and the task-estimate coverage check (§1.8).

8. **Then** take the four genuine business decisions to their owners in §9: §1.5 severity direction, §1.8 completion formula, §1.9 attention score, and the §1.7 capacity assumptions.

---

## Response Template

You can provide the remaining decisions using the following format. Items already resolved from code are pre-filled and need confirmation only.

```text
── RESOLVED FROM CODE — confirm or object ──
Active Project Rule:      status = 1 AND archive = 0 (ignore project_status_id)
My Projects Rule:         accepted membership (tbl_project_users.request_status = 'A')
Add company-privacy filter to all project queries?   Yes / No
Task Status Rule:         status_type IN (1,2,4) open / 3 closed / 5 abandoned
Issue Status Rule:        status_type IN (1,2,4) open / 3 closed / 5 abandoned
Risk Score:               probability_value × impact_value; Red >=20, Amber 12-19, Green <12
Production Identifiers:   task_id / issue_id / tbl_risk.risk_id / project_id
Billable definition:      tbl_project_tasks.chargeable = 'Y'

── DECISION REQUIRED ──
Issue Severity direction:  [ ] adopt code mapping 1=Low 2=Medium 3=High
                           [ ] change the app to 1=High 2=Medium 3=Low
Severity value 0 label:
Same mapping for priority as severity?   Yes / No
"Critical issue" means:    [ ] status_id = 6   [ ] severity = high
Residual risk replaces original rating?  Yes / No
"Pending approval" task bucket:  [ ] drop  [ ] define as ______

── SERVER CONFIG VALUES ──
GLOBAL_PROJECT_STATUS =
MONTHLY_BILLING_HOURS =

── STILL OPEN — BUSINESS DECISIONS ──
Project Completion Formula (incl. subtask handling):
Weekly Capacity Hours:
Working Days Per Week:
Leave / Holiday Source:
Part-Time Resource Treatment:
Over-allocation Threshold (note: app currently caps at 100%):
Executive Attention Score — Final Indicators:
Executive Attention Score — Weights:
Executive Attention Score — Per-Indicator Thresholds:
Should stored project RAG affect the score?  Yes / No

── PROJECT PRIORITY (from tbl_project_priority) ──
0 =
2 =
3 =

── UAT IDs (numeric, not names) ──
- User ID:
- Project ID (with tasks + timesheets):
- Project ID (with issues):
- Project ID (with risks):
- Project ID (with executive summary):
- Project ID (with infrastructure cost):
- Project ID (with active allocated users):
- Task ID (with assignees):
- Task ID (with subtasks):
- Task ID (with timesheets):
- Risk ID (with history):
- Issue ID:
- Department ID:

── SIGN-OFF OWNERS (names) ──
Project status and lifecycle:
Task workflow statuses:
Issue workflow and severity:
Risk formula and thresholds:
Utilization and capacity:
Financial fields and deal value:
RBAC and "my" semantics:
KPI weights and executive score:
Database performance and indexes:

── DEFERRED ITEMS — confirm disposition ──
Milestones:                remain deferred / remove / reframe
Estimation versions:       remain deferred / remove / reframe
Team-name questions:       remain deferred / remove / reframe
Project-stage aging:       remain deferred / remove / reframe
Predictive probability:    remain deferred / remove / reframe
```
