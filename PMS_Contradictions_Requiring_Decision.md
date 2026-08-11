# PMS — Contradictions Requiring a Decision

Companion to [PMS_Inputs_Required_From_User.md](PMS_Inputs_Required_From_User.md) and [PMS_Answers_From_Codebase.md](PMS_Answers_From_Codebase.md).

**Scope of this file:** items where the application code and the answered questionnaire say **different things**. Every item here already has two candidate logics — nobody needs to invent anything. Someone must pick one, and in a few cases the "pick" is really "confirm the correction".

Genuinely undefined items live in [PMS_Open_Items_Pending.md](PMS_Open_Items_Pending.md).

## How to use this file

Each item states the **two competing logics**, the **SQL that changes**, and the **blast radius** if the wrong one is chosen. Record your decision in the Decision line and initial it.

| Class | Meaning | Count |
| ----- | ------- | ----: |
| 🔴 **Correctness** | One side is factually wrong. Choosing wrong produces incorrect answers, not just different ones. | 5 |
| 🟠 **Divergence** | Both are defensible. The app does X, we proposed Y. Pick one and record it. | 4 |
| 🟡 **Gap** | The questionnaire asked for a bucket the code has no concept of. Define or drop it. | 3 |

**Total: 12 decisions.** Items C-01 through C-05 block correct answers and should be settled first.

---

## 🔴 C-01 — Issue severity mapping is inverted

**Question affected:** §1.5 — "Please provide the business labels for severity/priority values 0–3"
**Also affects:** every §7.3 KPI, "high-severity issues", "critical issues by project"

### The two logics

```text
Logic A — what the application does
  Project/index.php:3197-3204
  $priority_arr = array('1'=>'Low','2'=>'Medium','3'=>'High');
  1 = Low        2 = Medium      3 = High        0 = renders blank

Logic B — what the questionnaire was answered with
  1 = High       2 = Medium      3 = Low         0 = unspecified
```

### Why this is correctness, not preference

The two are **exact inverses**. If Orbit adopts Logic B while the app renders Logic A, then:

```sql
-- User asks: "show me high severity issues"
-- Under Logic B, Orbit generates:
WHERE severity = 1
-- ...which the PMS UI displays as "Low". Every answer is precisely wrong,
-- and it will look plausible because rows are returned.
```

A wrong-but-empty result gets noticed. A wrong-but-populated result does not.

### What must be decided

1. **Direction** — adopt Logic A (change the questionnaire) or Logic B (change the app)? Changing the app means a data migration too, since existing rows are stored under Logic A.
2. **Value `0`** — the code hits an undefined array index and renders blank. Is `0` "Not Set", or should it be excluded from severity filters entirely?
3. **Does the same mapping govern `priority`?** The code uses **one array for both** `severity` and `priority`. Confirm that is intended rather than an oversight.

### Do not conflate three fields

`tbl_project_issues.severity`, `tbl_project_issues.priority`, and `impact_id` (FK → `tbl_project_impact`) are three separate things. The issue *report* uses `impact_id` as its priority axis (`Project_model.php:11316-11321`), not `priority`.

> **Decision:** ______________________  **Owner:** QA/Delivery Governance  **Date:** ________

---

## 🔴 C-02 — Task and issue status must resolve via `status_type`, not hardcoded IDs

**Question affected:** §1.3, §1.4 — "Please confirm which status IDs count as Open / Closed / Abandoned"
**Also affects:** most of the 50 mapped queries; every §7.2 and §7.3 KPI

### The two logics

```text
Logic A — what the application does (Project_model.php:10850 and 3 other places)
  Join to the status table, filter on the status_type classifier:
    status_type: 1 => New   2 => In Progress   3 => Closed   4 => UAT   5 => Abandoned

  Open              = status_type IN (1, 2, 4)
  Completed/Closed  = status_type = 3
  Abandoned         = status_type = 5

Logic B — what the questionnaire approved
  Open              = status_id IN (1,2,4,5,6,7,9,11,13)
  Completed/Closed  = status_id IN (3,8,12)
  Abandoned         = status_id = 10
```

### Why Logic B is unsafe even where it currently agrees

The ID list was reverse-engineered from one snapshot of one deployment. It breaks in three ways:

1. **A new status row** (e.g. "Blocked") is invisible to a hardcoded list — it silently falls out of both Open and Closed.
2. **Per-project status sets.** If `GLOBAL_PROJECT_STATUS = false` (see [O-01](PMS_Open_Items_Pending.md)), every project has its own status rows with its own IDs. The list is then wrong for all but one project.
3. **It misclassifies two rows today** — it omits `status_type = 4` (UAT) as a class of its own, and puts ID 10 (Abandon) in a bespoke bucket instead of `status_type = 5`.

### SQL that changes

```sql
-- Logic B (current mapped SQL)
WHERE t.status_id IN (1,2,4,5,6,7,9,11,13)

-- Logic A (required)
JOIN tbl_project_task_status ts ON ts.task_status_id = t.status_id
WHERE ts.status_type IN (1, 2, 4)
  AND ts.status = 1
  -- plus the project_id filter if GLOBAL_PROJECT_STATUS = false
```

### What must be decided

Approve rewriting all mapped SQL to join on `status_type`. This is a rework decision, not a semantics one — the code's meaning is unambiguous.

> **Decision:** ______________________  **Owner:** Delivery/PMS Product Owner  **Date:** ________

---

## 🔴 C-03 — "InProgress is treated as Closed by the app" is not true

**Question affected:** §1.4 — the answered per-ID issue mapping

### The two logics

```text
Logic A — what the code shows
  There is NO special case for issue status 2 anywhere in the codebase.
  openIssues() carries an explicit source comment:
      // 1=>NEW, 2=>IN_PROGRESS status type
      WHERE tbl_project_issue_status.status_type IN(1,2)
  (Project_model.php:9080-9086, repeated at :12247)
  Behaviour is driven purely by that row's status_type value.

Logic B — what the questionnaire asserts
  InProgress(2) — treated as CLOSED by the app despite the DB name
  Complete(3)   — treated as OPEN
```

### The likely explanation

If issue status ID 2 really does behave as closed in your environment, it is because **`tbl_project_issue_status.status_type = 3` in your data** — a data-quality problem in the status master, not application logic. The same would explain `Complete(3)` behaving as open.

That distinction matters: a data problem gets fixed by correcting one row, whereas an app-logic special case would have to be replicated in every Orbit query forever.

### Resolution path — this is a query, not a debate

```sql
SELECT issue_status_id, project_id, status_name, status_type, status, status_order
FROM tbl_project_issue_status
ORDER BY project_id, status_order;
```

If `status_name = 'InProgress'` returns `status_type = 3`, the master data is mislabelled. Decide whether to **correct the data** or **keep it and document the anomaly**.

> **Decision:** ______________________  **Owner:** QA/Delivery Governance  **Date:** ________

---

## 🔴 C-04 — Risk identifier points at the wrong table

**Question affected:** §2 — "Recommended rule: Risk → `project_risk_id` (note: NOT `risk_id`)"

### The two logics

```text
Logic A — what the code uses
  tbl_risk.risk_id
  The operational risk register. Every list, count, search and report query
  in Risk_model reads this table (Risk_model.php:198, 594, 709, 1236).
  Carries: reference_no, rating, rating_color_code, probability_id, impact_id, status_id

Logic B — what the questionnaire recommends
  tbl_project_risk.project_risk_id
  A separate VERSIONED register (has a `version` column).
  Touched only by a two-line versioned insert (Risk_model.php:209-214).
  Has NO reference_no column at all.
```

### Why Logic B breaks things

Everything decided in §1.10 — the `probability × impact` rating, the Red/Amber/Green thresholds, the open-status filter — lives on **`tbl_risk`**. A query keyed on `project_risk_id` cannot reach any of it, and cannot resolve a risk reference number, because that column does not exist on that table.

### What must be decided

Confirm the correction to `tbl_risk.risk_id`, and confirm that `tbl_project_risk` is out of scope for reporting (it appears to be a legacy or audit-versioning artefact). If it *is* in scope, we need to know what it is for — nothing in the code reads it.

> **Decision:** ______________________  **Owner:** PMO/Risk Owner  **Date:** ________

---

## 🔴 C-05 — Department query references a table that does not exist

**Question affected:** §5 — the department validation query; explains the 1 skipped query in the verification run

### The two logics

```text
Logic A — the real schema
  tbl_project_department
    department_id, company_id, department_name, post_date, post_ip, update_date, status

Logic B — the questionnaire's SQL
  FROM department d JOIN tbl_projects p ...
  No table named `department` exists. This query cannot run.
```

### Corrected SQL

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

### Two schema facts that affect the logic

- `tbl_projects.department_id` is a **plain int with no FK constraint** — orphaned department IDs are possible.
- `tbl_project_department` is scoped by **`company_id`**, so department names repeat across companies. Join on ID; for multi-company reporting group by `(company_id, department_id)`.

### What must be decided

This is a straight correction — confirm and run it. The only real decision is whether cross-company department names should be merged or kept separate in reporting.

> **Decision:** ______________________  **Owner:** DBA/Engineering  **Date:** ________

---

## 🟠 C-06 — "My Projects": accepted membership vs. union

**Question affected:** §1.1

### The two logics

```text
Logic A — what the application does (getUserProjects(), Project_model.php:6840)
  SELECT tbl_projects.*
  FROM tbl_projects
  LEFT JOIN tbl_project_users ON tbl_projects.project_id = tbl_project_users.project_id
  WHERE tbl_projects.status = 1
    AND tbl_project_users.request_status = 'A'   -- CHAR: A=Accepted, I=Invited, R=Rejected
    AND tbl_project_users.status = 1
    AND tbl_project_users.user_id = ?
  GROUP BY tbl_projects.project_id

Logic B — the questionnaire's code block
  Accepted membership OR pm_user_id = ? OR project_owner_id = ?
```

### What the code tells us about the gap

- **The owner is always also a member.** On creation the creator is auto-inserted into `tbl_project_users` with `request_status = 'A'` (`Project_model.php:609-618`). So the `project_owner_id` arm of the union adds nothing for normally-created projects.
- **The PM is a separate field** (`tbl_projects.pm_user_id`) with nothing enforcing membership. The MIS sync sets PM and owner to the same person and inserts a member row (`Api/index.php:788-789`, `:840`).
- **Net effect:** the union differs from the app only for **legacy or imported** projects where the member row is missing.

### The real trade-off

| Choose | Consequence |
| ------ | ----------- |
| Logic A | Orbit's "my projects" matches exactly what the user sees in Collab. Legacy projects with a missing member row stay invisible — same as today. |
| Logic B | Wider. Surfaces legacy projects, but Orbit and the PMS UI will disagree, and users will report it as a bug. |

The questionnaire's answer line said "accepted project member" while its code block said union — that is why this is still open.

> **Decision:** ______________________  **Owner:** Product Owner/Security  **Date:** ________

---

## 🟠 C-07 — Archived projects: always exclude vs. the app's toggle

**Question affected:** §1.1 — "confirm whether archived and inactive projects must always be excluded" → answered **Yes**

### The two logics

```text
Logic A — what the application does (chkHideArchiveProject(), Project_model.php:12192)
  if ($hide_archive == 'TRUE') { $sql .= ' AND archive = 0 '; }
  else                         { $sql .= ' AND archive = 1 '; }

  This is a SESSION TOGGLE, not an exclusion. It shows either non-archived
  OR archived — never both, and archived rows ARE reachable in the UI.

Logic B — the questionnaire's answer
  Always AND archive = 0. Archived projects are never returned.
```

### Why this needs recording rather than resolving

Logic B is a reasonable **reporting** rule and probably what leadership wants. But it is **stricter than the app**, which means a user who can see an archived project in Collab will be told by Orbit that it does not exist.

### What must be decided

Confirm Logic B as a deliberate divergence, **or** decide that Orbit should support an "include archived" qualifier when the user explicitly asks for one ("show me archived projects too").

> **Decision:** ______________________  **Owner:** Product Owner/Security  **Date:** ________

---

## 🟠 C-08 — Company-privacy filter is missing from every mapped query

**Question affected:** none — **the questionnaire never asked.** Surfaced by the code review.

### What the app does that our SQL does not

```text
chkPrivateProject() — Project_model.php:84
  If the user's company is flagged private:
      restrict results to company_id = <user's company>
  Otherwise:
      exclude projects belonging to private_company_ids
```

Every project-listing query in the application appends this. **None of our 50 mapped queries do.**

### Why this is listed as a contradiction rather than an open item

There is no ambiguity about the correct logic — the app defines it. The contradiction is between the app's access model and what our queries currently return, and the consequence is a **cross-company data leak**: a user from Company A can be shown Company B's projects by Orbit even though Collab would hide them.

### What must be decided

Approve adding the privacy filter to all project-scoped queries, and confirm which behaviour Orbit inherits — the caller's company context has to be passed in, which means Orbit needs the requesting user's `company_id`, not just their `user_id`.

> **Decision:** ______________________  **Owner:** Product Owner/Security  **Date:** ________

---

## 🟠 C-09 — Two task filters the app applies and our queries omit

**Question affected:** §1.3 — surfaced by the code review

### What the app does

```sql
AND task_id != parent_id      -- excludes self-referencing parent placeholder rows
                              -- (Project_model.php:10846)
AND ignore_report = 'N'       -- tbl_project_tasks.ignore_report = 'Y' means
                              -- "exclude from reports"; the app honours it
                              -- (Group/index.php:7640-7641)
```

### Effect of omitting them

Every task count, backlog figure and completion percentage is **inflated**. Placeholder parent rows are counted as real tasks, and tasks explicitly marked as excluded-from-reporting are included.

This interacts with [O-08](PMS_Open_Items_Pending.md) (subtask handling in the completion formula) — decide both together.

> **Decision:** ______________________  **Owner:** Delivery/PMS Product Owner  **Date:** ________

---

## 🟡 C-10 — "Pending approval" task bucket has no equivalent in the code

**Question affected:** §1.3 — the six requested buckets were Open / In progress / Completed / Closed / Abandoned / **Pending approval**

### The gap

The task `status_type` enum has exactly five values: New, In Progress, Closed, UAT, Abandoned. **There is no "pending approval" concept.**

Status ID 9 is named `Approve`, but a *name* is not a classifier — its `status_type` determines behaviour, and that value is unknown until [O-02](PMS_Open_Items_Pending.md) is run.

### What must be decided

| Option | Logic |
| ------ | ----- |
| Drop the bucket | Questions about "tasks pending approval" are answered as unsupported |
| Map to the named row | `WHERE ts.status_name = 'Approve'` — fragile, name-based, breaks per-project |
| Map to a `status_type` | Only viable if `Approve` has a distinct `status_type`; run O-02 first |

> **Decision:** ______________________  **Owner:** Delivery/PMS Product Owner  **Date:** ________

---

## 🟡 C-11 — "Critical issue" is ambiguous between status and severity

**Question affected:** §1.4 — the five requested buckets included **Critical issue**

### The gap

Two unrelated things could mean "critical":

```text
Reading A — a status
  tbl_project_issue_status row named 'Critical' (ID 6 in the observed data)
  WHERE i.status_id = 6

Reading B — a severity
  tbl_project_issues.severity at its highest value
  WHERE i.severity = <high>     -- and "high" depends on C-01!
```

These select different row sets, and an issue can be one without the other.

### Dependency

Reading B cannot be implemented until **C-01** is settled — under the two candidate mappings, "high severity" is either `severity = 3` or `severity = 1`.

> **Decision:** ______________________  **Owner:** QA/Delivery Governance  **Date:** ________

---

## 🟡 C-12 — Risk bands: 3-band model vs. the requested 4 bands

**Question affected:** §1.10 — "Thresholds for Low, Medium, High, and **Critical** exposure"

### The gap

```text
What the code implements (Risk/index.php:253-263)
  Red    : rating >= 20
  Amber  : rating 12–19
  Green  : rating < 12
  -- three bands, and the result is persisted to tbl_risk.rating_color_code

What the questionnaire asked for
  Low / Medium / High / Critical — four bands
```

The answer given was "keep the existing 3-band model", which resolves it — but the question's four-band framing is still in the document and in the KPI definitions in §7.3.

### What must be decided

Confirm that **Critical is dropped**, or define its threshold. If Critical is added, note the score is `probability_value × impact_value` with both factors defaulting to 1 when unset — so the achievable range depends on the master-table values, which should be checked before inventing a fourth cut-point.

> **Decision:** ______________________  **Owner:** PMO/Risk Owner  **Date:** ________

---

## Decision summary sheet

| ID | Item | Class | Blocks | Owner | Decided |
| -- | ---- | ----- | ------ | ----- | ------- |
| C-01 | Issue severity inverted | 🔴 Correctness | §7.3, all severity questions | QA/Delivery Governance | ☐ |
| C-02 | `status_type` vs hardcoded IDs | 🔴 Correctness | Most mapped SQL, §7.2, §7.3 | Delivery/PMS PO | ☐ |
| C-03 | "InProgress = Closed" claim | 🔴 Correctness | §1.4 final mapping | QA/Delivery Governance | ☐ |
| C-04 | Risk table `tbl_risk.risk_id` | 🔴 Correctness | §1.10, §7.3 | PMO/Risk Owner | ☐ |
| C-05 | Department table name | 🔴 Correctness | 1 skipped query, §3.3 | DBA/Engineering | ☐ |
| C-06 | My Projects: membership vs union | 🟠 Divergence | All "my" questions | Product Owner/Security | ☐ |
| C-07 | Archived: exclude vs toggle | 🟠 Divergence | All project listings | Product Owner/Security | ☐ |
| C-08 | Company-privacy filter missing | 🟠 Divergence | **Data leak** — all project queries | Product Owner/Security | ☐ |
| C-09 | `parent_id` / `ignore_report` filters | 🟠 Divergence | All task counts | Delivery/PMS PO | ☐ |
| C-10 | "Pending approval" bucket | 🟡 Gap | §1.3 | Delivery/PMS PO | ☐ |
| C-11 | "Critical issue" meaning | 🟡 Gap | §1.4, §7.3 | QA/Delivery Governance | ☐ |
| C-12 | Risk 3-band vs 4-band | 🟡 Gap | §1.10, §7.3 | PMO/Risk Owner | ☐ |

**Recommended order:** C-01 → C-02 → C-03 (they unblock the most KPIs), then C-08 (leak), then the rest.

Note **C-11 depends on C-01**, and **C-10 depends on** [O-02](PMS_Open_Items_Pending.md) being run first.
