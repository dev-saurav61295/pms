# PMS Questionnaire — Answers Derived From Codebase Logic

Scope: every question in `PMS_Inputs_Required_From_User(3).md` was checked against the actual
application logic in this repository. Each answer below is either **ANSWERED FROM CODE** (with
file/line evidence) or flagged as **NOT IN CODE** (business decision or DB-data question).

Legend:
- ✅ **ANSWERED FROM CODE** — the app's behaviour is definitive; use this.
- ⚠️ **CODE CONTRADICTS THE DRAFT ANSWER** — the pencilled-in answer in the questionnaire is wrong.
- ❌ **NOT IN CODE** — no logic exists; needs a business decision or a DB query.

---

## 0. Three findings that change the whole document

These affect many of the 50 mapped queries and should be read before anything else.

### 0.1 Task and issue status IDs must never be hardcoded

`status_type` is a 5-value classifier column on each status row. The application **always** resolves
open/closed by joining to the status table and filtering `status_type` — it never hardcodes status IDs.

```text
status_type: 1 => New
             2 => In Progress
             3 => Closed
             4 => UAT
             5 => Abandoned/Deferred
```

Documented verbatim in the code at four places:
- [Project_model.php:10850](source/application/modules/Project/classes/Project_model.php#L10850)
- [Project_model.php:12011](source/application/modules/Project/classes/Project_model.php#L12011)
- [Task/index.php:2955](source/application/modules/Task/index.php#L2955)
- [Task/index.php:6809](source/application/modules/Task/index.php#L6809)

The same enum governs **both** `tbl_project_task_status` and `tbl_project_issue_status`.

### 0.2 Status rows are per-project (or global) — controlled by a constant

Both `tbl_project_task_status` and `tbl_project_issue_status` carry a `project_id` column. Every
status lookup in the app is wrapped in:

```php
if ( defined('GLOBAL_PROJECT_STATUS') && GLOBAL_PROJECT_STATUS == true ) {
    $cond .= ' AND project_id = 0';      // one global status set
} else if ( $project_id ) {
    $cond .= ' AND project_id = '.$project_id;  // per-project status set
}
```

`GLOBAL_PROJECT_STATUS` is defined in the **gitignored** site config, so its value must be read from
the server. The fact that your validation found a single clean list of IDs 1–13 suggests this
deployment runs `GLOBAL_PROJECT_STATUS = true` (statuses at `project_id = 0`) — **please confirm**,
because if it is `false` every project has its own status rows and any query filtering on status must
also filter `project_id`.

### 0.3 Timesheet hours are split across two columns

`tbl_timesheets` has **no** decimal hours column. It stores `hours` INT and `minutes` INT separately
([TableTimesheets.php](source/dbobjects/default/TableTimesheets.php)). Every hours calculation in the
app is:

```sql
SUM(hours) + (SUM(minutes) / 60)
```

Any query that reports `SUM(hours)` alone silently under-reports effort. There is also **no
`chargeable` column on timesheets** — chargeable is a `'Y'`/`'N'` flag on `tbl_project_tasks`.

---

## 1. Mandatory Business-Rule Confirmations

### 1.1 Meaning of "My Projects" — ✅ ANSWERED FROM CODE

The canonical implementation is `getUserProjects()`
([Project_model.php:6840](source/application/modules/Project/classes/Project_model.php#L6840)):

```sql
SELECT tbl_projects.*
FROM tbl_projects
LEFT JOIN tbl_project_users ON tbl_projects.project_id = tbl_project_users.project_id
WHERE tbl_projects.status = 1
  AND tbl_project_users.request_status = 'A'
  AND tbl_project_users.status = 1
  AND tbl_project_users.user_id = ?
GROUP BY tbl_projects.project_id
```

**The app's rule is accepted membership only — not a union.** Notes:

- `request_status` is a **CHAR**, not an int: `'A'` = Accepted, `'I'` = Invited, `'R'` = Rejected
  ([Project_model.php:3177](source/application/modules/Project/classes/Project_model.php#L3177),
  [:3320](source/application/modules/Project/classes/Project_model.php#L3320)).
- **The owner is always also a member.** On project creation the creator is auto-inserted into
  `tbl_project_users` with `access_type = 'ADMIN'`, `request_status = 'A'`
  ([Project_model.php:609-618](source/application/modules/Project/classes/Project_model.php#L609-L618)).
  `getUserOwnProjects()` ([:6876](source/application/modules/Project/classes/Project_model.php#L6876))
  *still* requires `request_status = 'A'` on top of `project_owner_id = ?`.
- **The project manager is a separate field, `tbl_projects.pm_user_id`** — distinct from
  `project_owner_id`. The MIS sync sets both to the same person
  ([Api/index.php:788-789](source/application/modules/Api/index.php#L788-L789)) and inserts a member
  row ([:840](source/application/modules/Api/index.php#L840)), but there is no constraint enforcing
  that a PM is a member. A union rule would therefore add rows only for legacy/imported data.

**Recommendation:** the union rule the draft approves is *wider than the app*. If Orbit answers "my
projects" with a union, its output will not match what the user sees in Collab. Use accepted
membership to match the UI, or accept the divergence knowingly.

#### Two RBAC filters the questionnaire omits entirely

Every project-listing query in the app appends two more filters:

1. **Company privacy** — `chkPrivateProject()`
   ([Project_model.php:84](source/application/modules/Project/classes/Project_model.php#L84)):
   if the user's company is flagged private, results are restricted to `company_id = <user company>`;
   otherwise projects belonging to `private_company_ids` are excluded. **Omitting this leaks projects
   across company boundaries.**
2. **Archive toggle** — `chkHideArchiveProject()`
   ([Project_model.php:12192](source/application/modules/Project/classes/Project_model.php#L12192)):

```php
if ($hide_archive == 'TRUE') { $sql .= ' AND archive = 0 '; }
else                         { $sql .= ' AND archive = 1 '; }
```

This is a **session toggle, not an exclusion** — it shows either non-archived *or* archived, never
both. So "always exclude archived" (the draft's answer) is a **new, stricter rule** than the app's.
That is a reasonable choice for reporting; just record it as a deliberate divergence.

### 1.2 Active Project Definition — ✅ ANSWERED FROM CODE (draft answer confirmed)

The executive dashboard's baseline is `getAllProjectSummary()`
([Dashboard_model.php:735-741](source/application/modules/Dashboard/classes/Dashboard_model.php#L735-L741)):

```sql
WHERE tbl_projects.status = 1
  AND groups.status = 1
  AND tbl_projects.start_date != '0000-00-00 00:00:00'
  AND tbl_projects.end_date   != '0000-00-00 00:00:00'
```

`project_status_id` is applied **only when the user explicitly picks a status filter**
([:742-744](source/application/modules/Dashboard/classes/Dashboard_model.php#L742-L744)).

**"Do not consider `project_status_id`" is correct, and here is the structural reason:**
`tbl_project_status` has **no `status_type` column** at all
([TableProjectStatus.php](source/dbobjects/default/TableProjectStatus.php)) — columns are
`status_id, group_id, color_code, project_type_id, status_name, status_order, status`. It is scoped
per **group** and **project type**, and carries no open/closed semantics. There is therefore no
code-derivable way to classify a `project_status_id` as "active".

Answers to the three sub-questions — all three are **unanswerable from code** and, given the above,
**moot**: `Approved`, `PendingApproval` and `0` carry no machine-readable meaning. Treat
`project_status_id` as a display label only.

```text
Active Project = tbl_projects.status = 1 AND tbl_projects.archive = 0
```

Note `status` is the soft-delete flag and `archive` is independent; `is_approved` is set to 1 by a
single approval action ([Project/index.php:8805](source/application/modules/Project/index.php#L8805))
and is not used in any listing filter.

### 1.3 Open Task Definition — ⚠️ CODE CONTRADICTS THE DRAFT ANSWER

The draft approves hardcoded ID lists (`Open: 1,2,4,5,6,7,9,11,13`). **The app never does this.**
Per §0.1 the correct rule is by `status_type`:

```text
Open              = status_type IN (1, 2, 4)   -- New, In Progress, UAT
Completed/Closed  = status_type = 3
Abandoned         = status_type = 5
```

Evidence:
- `checkTaskInProgress()` returns "in progress" when `status_type NOT IN (1,3)`
  ([Project_model.php:11918](source/application/modules/Project/classes/Project_model.php#L11918))
- `getClosedTask()` counts `status_type = 3`
  ([:11337](source/application/modules/Project/classes/Project_model.php#L11337))
- `getDefaultTaskStatus()` picks `status_type = 1` for a brand-new task
  ([:11657](source/application/modules/Project/classes/Project_model.php#L11657))
- `getOverdueTasks()` uses `status_type = 2`
  ([:3498](source/application/modules/Project/classes/Project_model.php#L3498))
- the Abandon status is fetched as `getProjectTaskStatus(0, $project_id, '', 5)`
  ([Project/index.php:9608](source/application/modules/Project/index.php#L9608))

**The draft's mapping is close but wrong in two ways:** it omits `status_type = 4` (UAT) as its own
class, and it places status ID `10 (Abandon)` in a bespoke bucket rather than `status_type = 5`.
More importantly, hardcoding IDs will break the moment a status is added or a second project gets its
own status set.

**Two further gotchas for any task-count query:**

1. `AND task_id != parent_id` — the app excludes self-referencing parent placeholder rows
   ([Project_model.php:10846](source/application/modules/Project/classes/Project_model.php#L10846)).
2. `ignore_report = 'N'` — `tbl_project_tasks.ignore_report = 'Y'` means "exclude from reports", and
   the app honours it ([Group/index.php:7640-7641](source/application/modules/Group/index.php#L7640-L7641)).
   KPI queries that skip this will over-count.

**Caveat to flag:** the app fetches the status for a type with `dbSelectSingle` — it assumes **exactly
one** status row per `status_type` per project. If your data has several (e.g. `QAPass` and `ReTest`
both `status_type = 2`), the app silently picks one and its own counts are already incomplete. Worth
verifying with a `GROUP BY status_type HAVING COUNT(*) > 1`.

### 1.4 Open Issue Definition — ⚠️ CODE CONTRADICTS THE DRAFT ANNOTATIONS

Same `status_type` mechanism, same enum (§0.1). The app's rule:

```text
Open              = status_type IN (1, 2, 4)
Resolved/Closed   = status_type = 3
Abandoned         = status_type = 5
```

Evidence — `openIssues()` carries an explicit comment:

```php
// 1=>NEW, 2=>IN_PROGRESS status type
... WHERE tbl_project_issue_status.status_type IN(1,2)
```
([Project_model.php:9080-9086](source/application/modules/Project/classes/Project_model.php#L9080-L9086),
repeated at [:12247](source/application/modules/Project/classes/Project_model.php#L12247)).
`getClosedIssue()` uses `status_type = 3`
([:11355](source/application/modules/Project/classes/Project_model.php#L11355));
`getLongestOpenIssues()` uses `status_type != 3`
([:3554](source/application/modules/Project/classes/Project_model.php#L3554)).

**On the annotation "InProgress(2) — ⚠ Treated as CLOSED by the app despite the DB name InProgress":**
there is **no such special case anywhere in the code**. The app's behaviour is driven purely by that
row's `status_type`. If issue status ID 2 behaves as closed, it is because
`tbl_project_issue_status.status_type = 3` **in your data** — a data-quality issue, not app logic.
Confirm with:

```sql
SELECT issue_status_id, project_id, status_name, status_type, status
FROM tbl_project_issue_status
ORDER BY project_id, status_order;
```

The same query against `tbl_project_task_status` will settle §1.3 definitively. **These two queries
are the single highest-value validation step remaining** — they replace all the guessed ID lists.

### 1.5 Issue Severity and Priority Mapping — ⚠️ CODE CONTRADICTS THE DRAFT ANSWER

Found at [Project/index.php:3197-3204](source/application/modules/Project/index.php#L3197-L3204):

```php
$priority_arr = array('1'=>'Low','2'=>'Medium','3'=>'High');
...
$priority  = $priority_arr[$issue_detail['priority']];
$severity  = $priority_arr[$issue_detail['severity']];
```

**One array serves both `severity` and `priority`:**

| Value | Label |
| ----: | ----- |
| 1 | Low |
| 2 | Medium |
| 3 | High |
| 0 | *no label* — undefined index, renders blank |

The handwritten answer in the questionnaire says `1 - High, 2 - Medium, 3 - Low`. **That is inverted
relative to the code.** If Orbit adopts it, every "high-severity issues" answer will return the
*lowest*-severity records. This needs an explicit decision: either correct the mapping to match the
app, or change the app.

Both columns exist on `tbl_project_issues` (`severity`, `priority`) alongside a separate `impact_id`
FK → `tbl_project_impact`, which the issue *report* uses as the priority axis
([Project_model.php:11316-11321](source/application/modules/Project/classes/Project_model.php#L11316-L11321)).
Don't conflate `severity`, `priority` and `impact_id` — they are three different fields.

### 1.6 Project Priority Mapping — ✅ ANSWERED FROM CODE (mechanism), ❌ values need a DB read

`tbl_projects.priority` is a **foreign key**, not an enum. The app resolves the label through the
master table:

```php
$priority_details = $this->objProject->getProjectPriorityDetailsByID( $project_details['priority'] );
$project_list[$i]['priority'] = $priority_details['priority_name'];
```
([Project/index.php:8196,8229 equivalent](source/application/modules/Project/index.php#L6436))

`tbl_project_priority` = `priority_id, project_type_id, priority_name, priority_order, status`
([TableProjectPriority.php](source/dbobjects/default/TableProjectPriority.php)).

**Why the master table looked "unreliable": it is scoped by `project_type_id`.** The same
`priority_id` can carry a different name per project type, and rows with `status != 1` are retired.
So there is no single global map — the correct approach is to **join, not hardcode**:

```sql
SELECT p.project_id, pr.priority_name
FROM tbl_projects p
LEFT JOIN tbl_project_priority pr ON p.priority = pr.priority_id
```

The draft answer (`1 Low / 2 Medium / 3 High`) is plausible — it matches the issue map — but must be
verified against actual rows:

```sql
SELECT priority_id, project_type_id, priority_name, status FROM tbl_project_priority ORDER BY priority_id;
```

Beware: there are **three mutually inconsistent hardcoded priority arrays** elsewhere in the code,
all used only for Excel-import validation, none authoritative:
`array('High','Low','Urgent','Strategic')` ([Project/index.php:132](source/application/modules/Project/index.php#L132)),
`array('High','Low','Medium')` ([Task/index.php:2541](source/application/modules/Task/index.php#L2541)),
`array('High','Medium','Low')` ([Task/index.php:4553](source/application/modules/Task/index.php#L4553)).

### 1.7 Utilization Formula — ✅ ANSWERED FROM CODE (the app implements Option A)

[Dashboard/index.php:2688](source/application/modules/Dashboard/index.php#L2688) (duplicated for the
Excel export at [:3746](source/application/modules/Dashboard/index.php#L3746)):

```php
$percentage = ($monthly_hours[$j]['hours'] + ($monthly_hours[$j]['minutes'] / 60))
              / MONTHLY_BILLING_HOURS * 100;
$percentage = $percentage > 100 ? 100 : $percentage;
```

Hours come from `userMonthlyHours()`
([Dashboard_model.php:858-876](source/application/modules/Dashboard/classes/Dashboard_model.php#L858-L876)) —
`SUM(hours)`, `SUM(minutes)` from `tbl_timesheets` grouped by `LEFT(timesheet_date, 7)`, i.e. **calendar
month**, all hours, **not** filtered by chargeable.

```text
Utilization % = (SUM(hours) + SUM(minutes)/60) / MONTHLY_BILLING_HOURS × 100, capped at 100
```

So **Option A is confirmed as what the app does**, with a monthly (not weekly) denominator.

Sub-questions:
- **Monthly capacity** = the constant `MONTHLY_BILLING_HOURS`. ❌ **It is not defined anywhere in this
  repository** — only consumed. It lives in the gitignored site config; read it from the server
  (`grep -rn "MONTHLY_BILLING_HOURS" config/` on the host).
- **Weekly capacity / working days per week** — ❌ no such constant or calculation exists.
- **Leave and holidays** — ❌ **no holiday, leave, or working-calendar table exists** in
  `source/dbobjects/`. Cannot be computed; must be deferred or sourced from HR.
- **Part-time resources** — ❌ no FTE or contracted-hours field on the user tables. `tbl_project_users`
  has `allocation_hrs`, `allocation_from`, `allocation_to`, `resource_type` — per-project allocation,
  not a person-level capacity.
- **Over-allocation threshold** — ❌ not answerable from code, and note the app **caps at 100%**, so it
  is structurally incapable of showing over-allocation today. Any >100% KPI is new behaviour.

The app's existing colour bands (usable as reporting bands):

| Utilization | Colour |
| ----------- | ------ |
| 100% | `#56f75d` |
| 90–99% | `#afe6b1` |
| 80–89% | `#c0d8a3` |
| 70–79% | `#debd58` |
| 60–69% | `#d8c791` |
| 50–59% | `#e0b34c` |
| 1–49% | `#f44336` |
| 0% | `#fffefe` |

**Option C (Allocated / Capacity) is feasible** from `tbl_project_users.allocation_hrs` — the app
already aggregates `SUM(allocation_hrs) AS tot_allocated_hrs`
([Project_model.php:12395](source/application/modules/Project/classes/Project_model.php#L12395)) — but
no capacity denominator exists, so it still needs the constant above.
**Option B (chargeable)** is feasible via `tbl_project_tasks.chargeable = 'Y'`
([Dashboard_model.php:908-909](source/application/modules/Dashboard/classes/Dashboard_model.php#L908-L909)).

### 1.8 Project Completion Formula — ❌ NOT IN CODE

**No project-completion percentage exists anywhere in the application.** Verified:

- `tbl_project_tasks.percent_complete` exists but is only ever **displayed per task** (three
  `fetchTaskDetail` field lists in `Task/index.php` and two Handlebars templates). It is never
  aggregated to project level.
- The dashboard's "project progress" (`adminProjectProgressInner`,
  [Dashboard/index.php:561](source/application/modules/Dashboard/index.php#L561)) is a **Gantt
  timeline**: start/end dates, `no_of_days`, plus a tooltip comparing `estimate` against
  `hours_used`. No percentage.

So Option C is a **greenfield definition** — there is no existing behaviour to match or contradict.
Fields available to build it: `tbl_project_tasks.estimate`, `estimate_complete`, `actual_hours`,
`percent_complete`; `tbl_projects.estimate`.

The draft's own fallback note is the right instinct, and the code supplies two extra exclusions the
formula must honour (per §1.3): `task_id != parent_id` and `ignore_report = 'N'`. Also decide how
subtasks are treated — the app rolls subtask hours into the master task
([Task/index.php:2949](source/application/modules/Task/index.php#L2949)), so summing all rows
double-counts.

**A cheaper alternative worth considering:** the app already treats *effort consumed vs. estimate* as
its progress signal. `SUM(timesheet hours) / tbl_projects.estimate` requires no new data entry,
whereas weighted completion depends on PMs populating `estimate` **and** `percent_complete` on every
task — data whose completeness you have not yet verified. Check coverage before committing:

```sql
SELECT COUNT(*) AS total,
       SUM(estimate IS NULL OR estimate = 0)         AS no_estimate,
       SUM(percent_complete IS NULL)                 AS no_pct
FROM tbl_project_tasks WHERE status = 1 AND ignore_report = 'N';
```

### 1.9 Project Health / Executive Attention Score — ❌ NOT IN CODE

No health, attention, or composite score exists. Specifically:

- **`tbl_projects.rag` is a manually-entered string**, not a computed value — `'Red'`, `'Amber'`,
  `'Green'`, `'Gray'` ([Project/index.php:135](source/application/modules/Project/index.php#L135)).
  Tasks and issues use a 3-value variant without `'Gray'`
  ([Issue/index.php:49](source/application/modules/Issue/index.php#L49)). It is stored as a **string,
  so filter on `rag = 'Red'`, not an ID.** The draft's caution that stored RAG is sparse and should
  not be the primary indicator is well-founded — nothing computes it.
- **`tbl_projects.overall_score` is not a health score.** It belongs to the EHS/audit module
  ([Ehs/index.php:452](source/application/modules/Ehs/index.php#L452),
  [:630](source/application/modules/Ehs/index.php#L630)) and is written only by project audits.
- **`attention_required` is not a health flag.** It is a delimited list of **user IDs** matched with
  `LIKE '%id%'` ([Project_model.php:2307](source/application/modules/Project/classes/Project_model.php#L2307),
  [:3710](source/application/modules/Project/classes/Project_model.php#L3710)) — i.e. "who must look
  at this". Do not use it as a severity signal.

The seven indicators, their weights, thresholds and the Green 0–25 / Amber 26–55 / Red 56–100 bands
are therefore **entirely new** and cannot be validated against anything. Every component still needs
its own definition — and note that two of them depend on §1.7 and §1.8, which are themselves unresolved.

### 1.10 Risk Exposure Formula — ✅ ANSWERED FROM CODE (draft answer confirmed exactly)

[Risk/index.php:253-263](source/application/modules/Risk/index.php#L253-L263), repeated identically at
[:1347](source/application/modules/Risk/index.php#L1347),
[:1887](source/application/modules/Risk/index.php#L1887),
[:2152](source/application/modules/Risk/index.php#L2152):

```php
$rating = (int) ($probability_value * $impact_value);

if      ($rating >= 20)                  { $rating_color_code = $red;   }
elseif  ($rating >= 12 && $rating < 20)  { $rating_color_code = $amber; }
elseif  ($rating < 12)                   { $rating_color_code = $green; }
```

```text
Risk Score = probability_value × impact_value   (integer cast)

Red    : rating >= 20
Amber  : rating 12–19
Green  : rating < 12
```

- `probability_value` ← `tbl_risk_probability.probability_value`; `impact_value` ←
  `tbl_risk_impact.impact_value`. **Both default to `1` when unset**
  ([Risk/index.php:247,251](source/application/modules/Risk/index.php#L247-L251)) — so a risk with no
  probability/impact scores 1 (Green), it is not null.
- The result is **persisted** to `tbl_risk.rating` and `tbl_risk.rating_color_code`. ✅ "Use stored
  rating" is correct and cheaper than recomputing.
- **Priority does not affect the score** ✅ — `risk_priority_id` is filter-only
  ([Risk_model.php:583-589](source/application/modules/Risk/classes/Risk_model.php#L583-L589)).
- **Open risks only** ✅ — but note there are **two different `status` concepts**:
  `tbl_risk_status.status_type` where **`1 => New, 2 => Closed`**
  ([Risk/index.php:1365](source/application/modules/Risk/index.php#L1365)), *and* `tbl_risk.status`
  which is the soft-delete flag. Correct filter:
  ```sql
  JOIN tbl_risk_status rs ON r.status_id = rs.status_id
  WHERE rs.status_type = 1   -- open
    AND r.status = 1         -- not deleted
  ```
  Note this enum is **only 2 values** — unlike the 5-value task/issue enum in §0.1. Do not reuse it.
- **Residual risk**: `tbl_risk` carries `revised_probability`, `revised_impact` and
  `after_mitigation_risk_score`, but **no code computes a revised rating** — `rating` is always from
  the original values. Substituting residual risk would be new behaviour. ❌ business decision.
- The 3-band model is confirmed as "the existing 3-band model from the app". There is **no
  Low/Medium/High/**Critical** 4-band model in the code** — if leadership wants Critical, that band is new.

---

## 2. Production Identifier Decisions — ✅ ANSWERED FROM CODE (with one correction)

**All four uniqueness annotations in the draft are correct.** Reference numbers are per-project
counters, generated as `COUNT(...) + 1`:

| Entity | Generation | Evidence |
| ------ | ---------- | -------- |
| Task | `getProjectWiseTaskCount($project_id) + 1` | [Task/index.php:253-254](source/application/modules/Task/index.php#L253-L254), [:303-304](source/application/modules/Task/index.php#L303-L304) |
| Issue | `getProjectWiseIsssueCount($project_id) + 1` | [Issue/index.php:157-158](source/application/modules/Issue/index.php#L157-L158) |
| Risk | `getProjectWiseRiskCount($project_id) + 1` | [Risk/index.php:223-224](source/application/modules/Risk/index.php#L223-L224) |
| RCA | `$projectwise_rca_count + 1` | [Rca/index.php:132](source/application/modules/Rca/index.php#L132) |

**Worse than the draft states:** because these are `COUNT + 1` rather than `MAX + 1` sequences, they
are **not reliably unique even within a project** — a deletion causes the next insert to reuse a
number, and two concurrent inserts collide. This strengthens the case for internal IDs considerably;
reference numbers should be treated as display text only, never as a lookup key.

⚠️ **One correction to the recommended rule.** The draft says:

> Risk → project_risk_id (globally unique — note: NOT "risk_id")

**This points at the wrong table.** There are two parallel risk tables:

| Table | PK | Role |
| ----- | -- | ---- |
| **`tbl_risk`** | **`risk_id`** | **The operational risk register the Risk module reads and writes.** Has `reference_no`, `rating`, `rating_color_code`, `probability_id`, `impact_id`, `status_id`. |
| `tbl_project_risk` | `project_risk_id` | A separate **versioned** register (`version` column) with `original_risk_score` / `after_mitigation_risk_score`. **Has no `reference_no`.** |

`Risk_model` loads both, but every list, count, search and report query uses `tbl_risk`
([Risk_model.php:198,594,709,1236](source/application/modules/Risk/classes/Risk_model.php#L198));
`tbl_project_risk` is touched only by a two-line versioned insert
([:209-214](source/application/modules/Risk/classes/Risk_model.php#L209-L214)). Everything in §1.10
(rating, thresholds, open-status) applies to **`tbl_risk`**.

**Corrected identifier rule:**

```text
Task    → tbl_project_tasks.task_id
Issue   → tbl_project_issues.issue_id
Risk    → tbl_risk.risk_id          ← not project_risk_id
Project → tbl_projects.project_id
User    → user_id
Dept    → tbl_project_department.department_id   (see §5)
```

**Project titles are not unique** ✅ — no unique constraint appears in the table object, and
`tbl_projects` additionally carries `project_unique_id`, `short_url` and `reference_no` as alternate
keys. `short_url` is explicitly de-duplicated at insert time
([Project_model.php:597](source/application/modules/Project/classes/Project_model.php#L597) →
`prepareShortUrl`), which is indirect evidence that titles collide in practice. Confirm the absence of
a unique index on the server with `SHOW INDEX FROM tbl_projects;`.

---

## 3. UAT Test Data Required — ❌ NOT IN CODE (DB read needed)

Not derivable from source. The draft names *Saurav Kaushik* and one Bandhan AMC project for several
slots and leaves eight blank. Resolve with queries rather than by hand — for example, for the six
project slots:

```sql
-- project with issues / risks / allocated users
SELECT p.project_id, p.title,
       (SELECT COUNT(*) FROM tbl_project_issues i WHERE i.project_id = p.project_id AND i.status = 1) AS issues,
       (SELECT COUNT(*) FROM tbl_risk r          WHERE r.project_id = p.project_id AND r.status = 1) AS risks,
       (SELECT COUNT(*) FROM tbl_project_users u WHERE u.project_id = p.project_id AND u.request_status = 'A' AND u.status = 1) AS members
FROM tbl_projects p
WHERE p.status = 1 AND p.archive = 0
HAVING issues > 0 AND risks > 0 AND members > 1
LIMIT 5;
```

Note the executive-summary and infrastructure-cost slots map to `tbl_project_executive_summary` and
the `tbl_project_infrastructure_*` tables, whose population you have not yet confirmed.
**Please also supply user IDs, not names** — per §2, names are not reliable keys.

---

## 4. MCP Usage — ❌ process decision, no code involvement

Nothing in the codebase governs this. The read-only allowlist (`SELECT`, `WITH … SELECT`, `SHOW`,
`DESCRIBE`, `EXPLAIN`) and the blocked-DDL list are sound as written. One addition worth making: the
app's own `MySQL` wrapper is MySQLi-based and this schema uses `'0000-00-00 00:00:00'` sentinel dates
extensively (see §1.2), so ensure the MCP connection does **not** run with `NO_ZERO_DATE`/strict mode,
or those rows will error rather than return.

---

## 5. Department Query Validation — ⚠️ THE QUESTIONNAIRE'S SQL REFERENCES A NON-EXISTENT TABLE

The table is **`tbl_project_department`**, not `department`
([TableProjectDepartment.php](source/dbobjects/default/TableProjectDepartment.php)):

```text
tbl_project_department: department_id, company_id, department_name, post_date, post_ip, update_date, status
```

The draft's query (`FROM department d JOIN tbl_projects p`) cannot run against this schema. Corrected:

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

Note `department_id` on `tbl_projects` is a plain int column with no FK constraint, and
`tbl_project_department` is scoped by `company_id` — so department names may repeat across companies.
Join on ID and, for multi-company reporting, group by `(company_id, department_id)`.

This is very likely why the department query was recorded as "skipped": the parameter was never
discoverable because the lookup table was being read under the wrong name.

---

## 6. Performance Review and Index Approval — partially answerable

Index approval needs the DBA and a live `SHOW INDEX`. Two concrete inputs from the codebase:

1. **A captured slow-query log already exists in the repo**:
   [source/application/modules/Risk/classes/Project-mysql-slow-queries](source/application/modules/Risk/classes/Project-mysql-slow-queries)
   — real slow statements from this app, including the task-listing queries with the
   `IF(t2.parent_id > 0, …)` self-join pattern. Start the index review here; it is evidence from
   production rather than from synthetic test queries.
2. **Prior optimisation work is already recorded** in this project's memory
   (`.claude/memory/perf_n1_fixes.md`): batch pre-fetch fixes for the issue/task listing pages and a
   `getTotalTasks` COUNT optimisation, **with `ALTER TABLE` statements still pending on the server**.
   Those pending indexes likely overlap the list in §6 — reconcile before proposing new ones so the
   DBA gets one combined change set.

The four recommended practices in the draft are all consistent with how the app behaves, and "prefer
IDs over names" is reinforced by §2.

---

## 7. Executive/KPI Questions — ❌ NOT IN CODE

None of the 21 KPIs in §7.1–7.5 exist as implemented calculations. They decompose into the primitives
above, and their feasibility follows directly:

| KPI group | Feasible today? | Blocking dependency |
| --------- | --------------- | ------------------- |
| 7.1 Portfolio Health | No | §1.9 undefined (and RAG is manual + sparse) |
| 7.2 Task Delivery | **Mostly yes** | overdue/priority/RAG all queryable; "effort vs work completed" needs §1.8 |
| 7.3 Risk & Issue Exposure | **Yes** | §1.10 fully defined; needs §1.5 severity fixed first |
| 7.4 Resource & Capacity | Partly | `allocation_from`/`_to`/`_hrs` support "ending soon" and demand; over/under-utilisation blocked on `MONTHLY_BILLING_HOURS` and the 100% cap (§1.7) |
| 7.5 Financial & Effort | Partly | `deal_value`, `estimate`, `total_hours_booked`, `total_chargable_hours` exist on `tbl_projects`; "unhealthy" needs §1.9 |

**Recommended sequencing:** ship **7.3 and 7.2** first — they rest on the two rules that are already
confirmed by code (§1.10 risk scoring, §1.3/§1.4 status types) and need no new formulas. Defer 7.1 and
the utilisation half of 7.4 until §1.7 and §1.9 are signed off.

Useful pre-computed fields on `tbl_projects` for 7.5: `deal_value`, `deal_type`, `business_type`,
`estimate`, `total_hours_booked`, `total_chargable_hours`, `combined_hours`, `grant_hours`,
`project_duration`. Verify these are maintained rather than legacy before relying on them.

---

## 8. Questions to Keep Deferred — ✅ table existence verified

| Deferred area | Table exists? | Recommendation |
| ------------- | ------------- | -------------- |
| Milestone progress / ownership | **Yes** — `TableProjectTaskMilestone`, `TableProjectTaskMilestoneMapping` | Tables exist but you report them empty → **remain deferred** (a feature-adoption gap, not a schema gap; may become viable without code change) |
| Milestone-based completion | as above | Remain deferred; §1.8 chooses effort-weighted instead |
| Project estimation versions | **Yes** — `TableProjectEstimation`, `…AuditTrails`, `…Lineitem` | Remain deferred pending population check |
| Team-name questions | **Yes** — `TableProjectTeam` (+ `tbl_projects.team_id`) | Remain deferred |
| Project-stage aging | Partly — `project_stage_id` exists, but **no stage-change history table** | **Reframe** using `tbl_projects.update_date`, or **remove**; exact aging is not reconstructible |
| Predictive probability | n/a | **Remove from first release** — no historical model, and no stage history to train one |
| Leave / holiday / capacity calendar | **No such table anywhere** | Add to this deferred list — §1.7 depends on it; must come from HR |
| Skills-based questions | **Yes** — `TableMasterSkills`, `TableUserSkills` | Viable; §3.1 already names a user with mapped skills |

---

## 9. Required Sign-Off Owners — ❌ organisational, not in code

Cannot be derived. The suggested owner table is sensible; the code only adds that §1.5 (severity
inversion) and §2 (risk table correction) are **factual corrections rather than preference choices**,
so they need an owner who can authorise a change to either the app or the questionnaire, not merely
approve a mapping.

---

## 10. Minimum Inputs — status after this analysis

| # | Input | Status |
| -: | ----- | ------ |
| 1 | Active-project definition | ✅ **Resolved from code** — `status = 1 AND archive = 0`; ignore `project_status_id` |
| 2 | Open/completed task status IDs | ✅ **Resolved as `status_type`** (1,2,4 / 3 / 5) — one DB query to list the rows |
| 3 | Open/closed issue status IDs | ✅ same mechanism — same DB query |
| 4 | Issue severity & priority mapping | ⚠️ **Code says 1=Low, 2=Medium, 3=High** — draft answer is inverted; needs a decision |
| 5 | Project priority mapping | ✅ mechanism resolved (FK join); ❌ row values need one DB query |
| 6 | Definition of "my projects" | ✅ **Resolved from code** — accepted membership + company-privacy filter |
| 7 | Utilization formula & capacity | ⚠️ formula resolved (Option A); ❌ `MONTHLY_BILLING_HOURS` from server, leave/holiday has no source |
| 8 | Project-completion formula | ❌ **No code exists** — genuine business decision; check estimate/percent_complete coverage first |
| 9 | Risk-score formula & thresholds | ✅ **Fully resolved** — `probability × impact`; Red ≥20, Amber 12–19, Green <12 |
| 10 | Executive-attention indicators & weights | ❌ **No code exists** — entirely new |
| 11 | Internal IDs in production | ✅ confirmed, with the `tbl_risk.risk_id` correction |
| 12 | Valid department sample | ⚠️ **table name was wrong** — corrected query in §5 will return it |
| 13 | Representative UAT IDs | ❌ needs DB queries (§3) |

**Net: 6 of 13 resolved from code, 3 partially, 4 remain genuine business decisions**
(#8, #10, and the capacity/leave half of #7, plus the #4 severity decision).

---

## 11. Optional Inputs — code-side notes

- **Billable vs non-billable** — ✅ already defined in code: `tbl_project_tasks.chargeable IN ('Y','N')`,
  applied at [Dashboard_model.php:908](source/application/modules/Dashboard/classes/Dashboard_model.php#L908).
  Note it is a **task-level** attribute, so a single timesheet entry inherits it from its task.
- **Expected working-hours calendar / holiday source** — ❌ no table; must come from HR (blocks §1.7).
- **Known duplicate/legacy conditions** — ✅ the codebase shows several, and they are worth recording
  formally: duplicate project titles (§2), `COUNT+1` reference-number collisions (§2), the
  `'0000-00-00 00:00:00'` sentinel dates (§1.2), two parallel risk tables (§2), and a large number of
  `*_bkp` / `_12-03-2025` / `modules_live_bkp` duplicate source files that must not be mistaken for
  live logic when tracing behaviour.
- Dashboard screenshots, PMO KPI definitions, SLA rules, retention, response-time targets — ❌ external.

---

## 12. Recommended Next Actions

**Highest value first:**

1. **Run two queries** — they close items #2, #3 and settle the §1.4 "InProgress is closed" anomaly:
   ```sql
   SELECT task_status_id,  project_id, status_name, status_type, status, status_order
   FROM tbl_project_task_status  ORDER BY project_id, status_order;

   SELECT issue_status_id, project_id, status_name, status_type, status, status_order
   FROM tbl_project_issue_status ORDER BY project_id, status_order;
   ```
2. **Read `GLOBAL_PROJECT_STATUS` and `MONTHLY_BILLING_HOURS`** from the server's site config
   (gitignored, not in this repo). The first decides whether status queries need a `project_id`
   filter; the second unblocks all utilisation KPIs.
3. **Resolve the §1.5 severity inversion.** It is a correctness bug in the questionnaire, not a
   preference — every "high severity" answer depends on it.
4. **Rewrite the mapped SQL to join on `status_type`** instead of hardcoded status IDs, and add the
   three filters the app applies but the drafts omit: company privacy (§1.1), `task_id != parent_id`
   and `ignore_report = 'N'` (§1.3).
5. **Correct the risk identifier to `tbl_risk.risk_id`** and re-point any query currently aimed at
   `tbl_project_risk` (§2).
6. **Fix the department query** to `tbl_project_department` (§5) and capture the UAT sample.
7. **Then** take the three genuine business decisions — §1.8 completion, §1.9 attention score, and
   the capacity assumptions in §1.7 — to their owners in §9.
