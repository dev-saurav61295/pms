# PMS — Open Items Pending

Companion to [PMS_Inputs_Required_From_User.md](PMS_Inputs_Required_From_User.md) and [PMS_Answers_From_Codebase.md](PMS_Answers_From_Codebase.md).

**Scope of this file:** items where **no logic exists yet** — nothing in the application defines them, so they cannot be resolved by reading code. Each entry states the question, what logic must be supplied, and the SQL skeleton waiting to be filled in.

Items where code and questionnaire **disagree** live in [PMS_Contradictions_Requiring_Decision.md](PMS_Contradictions_Requiring_Decision.md) — settle those first where noted.

## Categories

| Group | What it takes to close | Items | Effort |
| ----- | ---------------------- | ----: | ------ |
| **A. Lookups** | One query or one config read. No decision. | 8 | Minutes |
| **B. Formulas** | A rule must be invented and signed off. | 11 | Workshop |
| **C. Test data** | Identify representative rows for UAT. | 3 | Half a day |
| **D. Governance** | Names, dispositions, approvals. | 4 | Email round |

**Total: 26 tracked items** (several are containers — B-11 covers 21 KPIs, C-01 covers 12 IDs).

---

# Group A — Lookups (no decision needed)

These are blocking, but only because nobody has run them yet.

## O-01 🔴 `GLOBAL_PROJECT_STATUS` — server config value

**Why it blocks:** decides whether **every** status query in the system needs an extra `project_id` filter.

**The logic that depends on it:**

```php
// Every status lookup in the app is wrapped in this
if ( defined('GLOBAL_PROJECT_STATUS') && GLOBAL_PROJECT_STATUS == true ) {
    $cond .= ' AND project_id = 0';              // ONE global status set
} else if ( $project_id ) {
    $cond .= ' AND project_id = '.$project_id;   // PER-PROJECT status sets
}
```

**How to get it:** it lives in the **gitignored** site config, not the repo.

```bash
grep -rn "GLOBAL_PROJECT_STATUS" config/    # run on the application server
```

**What each answer means:**

| Value | Consequence |
| ----- | ----------- |
| `true` | One shared status set at `project_id = 0`. Our mapped SQL is structurally fine. |
| `false` | **Every project has its own status rows with its own IDs.** All status joins must add `AND project_id = :project_id`, and any cached ID list is wrong for all but one project. |

Our validation found a single clean list of IDs 1–13, which *suggests* `true` — but that is an inference, not a confirmation.

> **Value:** ____________  **Confirmed by:** ____________

---

## O-02 🔴 Task status master rows

**Why it blocks:** replaces every guessed status-ID list. Prerequisite for [C-02](PMS_Contradictions_Requiring_Decision.md) and [C-10](PMS_Contradictions_Requiring_Decision.md).

```sql
SELECT task_status_id, project_id, status_name, status_type, status, status_order
FROM tbl_project_task_status
ORDER BY project_id, status_order;
```

**What to check in the output:**

1. Which `status_type` each of the 13 names actually carries.
2. Whether `project_id` is uniformly `0` (confirms O-01 = `true`).
3. **Duplicate types per project** — the app fetches a status with `dbSelectSingle`, assuming exactly one row per `status_type` per project. If two rows share a type, the app silently picks one and its own counts are already incomplete:

```sql
SELECT project_id, status_type, COUNT(*) AS n
FROM tbl_project_task_status
WHERE status = 1
GROUP BY project_id, status_type
HAVING n > 1;
```

> **Run:** ☐  **Result attached:** ☐

---

## O-03 🔴 Issue status master rows

**Why it blocks:** settles [C-03](PMS_Contradictions_Requiring_Decision.md) — the "InProgress is treated as Closed" claim.

```sql
SELECT issue_status_id, project_id, status_name, status_type, status, status_order
FROM tbl_project_issue_status
ORDER BY project_id, status_order;
```

**Specifically look for:** does the row named `InProgress` carry `status_type = 3`? If yes, the master data is mislabelled and C-03 becomes a data-fix decision rather than a logic one.

> **Run:** ☐  **Result attached:** ☐

---

## O-04 🔴 `MONTHLY_BILLING_HOURS` — server config value

**Why it blocks:** it is the **denominator of every utilisation KPI**. Without it, §7.4 cannot ship.

The formula is already confirmed from code (`Dashboard/index.php:2688`):

```php
$percentage = ($monthly_hours['hours'] + ($monthly_hours['minutes'] / 60))
              / MONTHLY_BILLING_HOURS * 100;
$percentage = $percentage > 100 ? 100 : $percentage;   // note the cap
```

**How to get it:** gitignored site config, same as O-01.

```bash
grep -rn "MONTHLY_BILLING_HOURS" config/    # run on the application server
```

> **Value:** ____________  **Confirmed by:** ____________

---

## O-05 🟠 Project priority master rows

**Why it blocks:** `tbl_projects.priority` is a **foreign key, not an enum** — and the master is scoped by `project_type_id`, so the same `priority_id` can mean different things for different project types. There is no single global map to hardcode.

```sql
SELECT priority_id, project_type_id, priority_name, priority_order, status
FROM tbl_project_priority
ORDER BY project_type_id, priority_order;
```

**The logic to adopt regardless of the values — join, never hardcode:**

```sql
SELECT p.project_id, pr.priority_name
FROM tbl_projects p
LEFT JOIN tbl_project_priority pr ON p.priority = pr.priority_id
```

**Two things the output must resolve:**

- Observed data contains priority values `0, 2, 3`. What does **`0`** mean — unset, or a real row?
- The questionnaire answered `1 = Low, 2 = Medium, 3 = High`, but **`1` does not occur in the data.** Confirm whether that row exists in the master at all.

⚠️ Ignore the three **mutually inconsistent** hardcoded priority arrays elsewhere in the app — they are Excel-import validation only and none is authoritative: `('High','Low','Urgent','Strategic')`, `('High','Low','Medium')`, `('High','Medium','Low')`.

> **Run:** ☐  **Value of `0`:** ____________

---

## O-06 🟠 Department UAT sample

**Why it blocks:** the 1 skipped query in the verification run. Depends on [C-05](PMS_Contradictions_Requiring_Decision.md) (wrong table name), which is why it was never discoverable.

```sql
SELECT d.department_id, d.department_name, COUNT(*) AS project_count
FROM tbl_project_department d
JOIN tbl_projects p ON p.department_id = d.department_id
WHERE p.status = 1
  AND p.archive = 0
  AND d.status = 1
  AND d.department_name IS NOT NULL
  AND d.department_name <> ''
GROUP BY d.department_id, d.department_name
ORDER BY project_count DESC
LIMIT 10;
```

> **Department ID:** ________  **Name:** ____________________

---

## O-07 🟡 Confirm no unique index on project titles

**Why it matters:** §2 concluded project titles are not unique based on the absence of a constraint in the table definition. Confirm against the live schema before relying on it.

```sql
SHOW INDEX FROM tbl_projects;
```

Supporting evidence already found: `short_url` is explicitly de-duplicated at insert time (`Project_model.php:597` → `prepareShortUrl`), which implies titles collide in practice.

> **Unique index on `title` present?** Yes / No

---

## O-08 🟠 Task estimate and percent-complete data coverage

**Why it blocks:** the approved completion formula (§1.8, Option C) depends on PMs having populated **both** `estimate` and `percent_complete` on every task. That coverage has never been measured. If it is poor, the formula produces confident nonsense.

```sql
SELECT COUNT(*) AS total,
       SUM(estimate IS NULL OR estimate = 0)  AS no_estimate,
       SUM(percent_complete IS NULL)          AS no_pct
FROM tbl_project_tasks
WHERE status = 1
  AND ignore_report = 'N'
  AND task_id != parent_id;
```

**Decision trigger:** if `no_estimate` is a large fraction of `total`, switch to the cheaper alternative the app already implies — effort consumed vs. estimate:

```text
Progress ≈ (SUM(timesheet hours) + SUM(minutes)/60) / tbl_projects.estimate
```

This needs no new data entry, whereas weighted completion requires a data-discipline change.

> **Run:** ☐  **Coverage:** ______%  **Formula confirmed:** ____________

---

# Group B — Formulas and rules to define

Nothing in the application defines these. They must be invented, agreed and signed off.

## O-09 ❌ Weekly capacity per employee

**No such constant or calculation exists in the code.** The app works in calendar months only (`LEFT(timesheet_date, 7)`).

**Logic needed:**

```text
Weekly Capacity Hours = ______   (per employee, or per grade/role?)

Does it vary by:  [ ] role   [ ] grade   [ ] location   [ ] contract type   [ ] no, flat
```

**Dependency:** if a weekly figure is defined, confirm how it reconciles with `MONTHLY_BILLING_HOURS` ([O-04](#o-04--monthly_billing_hours--server-config-value)) — the app's only capacity constant is monthly, so two independent numbers will drift.

> **Answer:** ____________  **Owner:** Resource Management/HR

---

## O-10 ❌ Working days per week

**No such constant exists.** Required to convert between weekly and monthly capacity, and to compute "overdue by N working days".

**Logic needed:**

```text
Working days per week = ______
Standard working hours per day = ______
Do weekends vary by location/region?  Yes / No
```

> **Answer:** ____________  **Owner:** Resource Management/HR

---

## O-11 ❌ Treatment of leave and holidays

**There is no holiday, leave, or working-calendar table anywhere in the schema.** This cannot be computed from the PMS at all — it must be sourced externally or the KPI must be deferred.

**Logic needed:**

```text
Available Hours = Capacity Hours − Leave Hours − Holiday Hours

Leave source:     [ ] HR system export   [ ] manual calendar   [ ] not tracked → ignore
Holiday source:   [ ] HR system export   [ ] manual calendar   [ ] not tracked → ignore
Refresh cadence:  ______
Region-specific holiday calendars?   Yes / No
```

**If no source exists:** utilisation must be reported against **gross** capacity with a stated caveat, and §7.4's under-utilisation KPI will systematically flag people who were simply on leave.

> **Answer:** ____________  **Owner:** Resource Management/HR

---

## O-12 ❌ Treatment of part-time resources

**No FTE or contracted-hours field exists on the user tables.** `tbl_project_users` has `allocation_hrs`, `allocation_from`, `allocation_to`, `resource_type` — but those are **per-project allocation**, not person-level capacity.

**Logic needed:**

```text
Is person-level FTE tracked anywhere outside the PMS?   Yes / No

If yes:   Available Hours = Capacity × FTE       (source: ______)
If no:    [ ] treat everyone as 1.0 FTE and accept the distortion
          [ ] maintain a manual exceptions list
          [ ] derive from SUM(allocation_hrs) across active allocations
```

Note the third option is circular — allocation is what utilisation is measured against — so use it only as a rough proxy.

> **Answer:** ____________  **Owner:** Resource Management/HR

---

## O-13 ❌ Over-allocation threshold

**The app is structurally incapable of reporting over-allocation today** — it hard-caps utilisation at 100%:

```php
$percentage = $percentage > 100 ? 100 : $percentage;
```

Any ">100%" KPI is therefore **new behaviour**, not a report on existing behaviour.

**Logic needed:**

```text
Over-allocated when utilisation > ______%     (e.g. 100 / 110 / 120)
Under-utilised when utilisation < ______%
Measured over:  [ ] calendar month   [ ] rolling 30 days   [ ] quarter
Remove the 100% cap for reporting?   Yes / No
```

**Dependency:** blocked on [O-04](#o-04--monthly_billing_hours--server-config-value). Without the denominator, no threshold can be evaluated.

> **Answer:** ____________  **Owner:** Resource Management/HR

---

## O-14 ❌ Project completion — subtask handling

**Why it is open:** the app **rolls subtask hours into the master task** (`Task/index.php:2949`). Summing all task rows therefore **double-counts** every subtask's effort.

**Logic needed:**

```text
For the weighted completion formula, subtasks are:
  [ ] excluded — count only rows where parent_id = 0 (rolled-up values already include children)
  [ ] included — count only leaf rows, exclude parents
  [ ] included — count all rows (accepts double-counting; NOT recommended)
```

**Interacts with** [C-09](PMS_Contradictions_Requiring_Decision.md): the `task_id != parent_id` filter already removes self-referencing placeholders, but that is a different thing from parent/child rollup. Decide both together.

> **Answer:** ____________  **Owner:** Delivery/PMS Product Owner

---

## O-15 ❌ Executive attention score — final indicators

**No health, attention, or composite score exists anywhere in the application.** Three fields that look like candidates are all false leads:

| Field | What it actually is |
| ----- | ------------------- |
| `tbl_projects.rag` | A **manually-entered string** — `'Red'`, `'Amber'`, `'Green'`, `'Gray'` (`Project/index.php:135`). Nothing computes it. Filter as a string, not an ID. |
| `tbl_projects.overall_score` | Belongs to the **EHS/audit module** (`Ehs/index.php:452`). Written only by project audits. |
| `attention_required` | A **delimited list of user IDs** matched with `LIKE '%id%'` (`Project_model.php:2307`) — i.e. "who must look at this". Not a severity signal. |

**Logic needed** — confirm, amend or replace the seven proposed indicators:

| Indicator | Keep? | Data source | Currently computable? |
| --------- | ----- | ----------- | --------------------- |
| Overdue high-priority tasks | ☐ | `tbl_project_tasks.due_date`, `priority` | Yes |
| Red/Amber task concentration | ☐ | task `rag` string | Yes, but sparse |
| Open high risks | ☐ | `tbl_risk.rating` ≥ 20 | **Yes — fully defined** |
| Overdue unresolved issues | ☐ | issue `status_type`, due date | Yes, after [C-01](PMS_Contradictions_Requiring_Decision.md) |
| Effort overrun | ☐ | timesheets vs `tbl_projects.estimate` | Yes |
| End-date exposure | ☐ | `tbl_projects.end_date` | Yes |
| Stale project activity | ☐ | `tbl_projects.update_date` | Yes |

> **Final indicator list:** ____________  **Owner:** PMO/Leadership

---

## O-16 ❌ Executive attention score — weights

The proposed weights (20/15/20/15/15/10/5) sum to 100 but have no basis in anything measured.

**Logic needed:**

```text
Weight per confirmed indicator, summing to 100:
  ______ %  →  ______________
  ______ %  →  ______________
  (one line per indicator confirmed in O-15)
```

**Dependency:** blocked on O-15. Two of the proposed indicators (effort overrun, and any completion-based measure) additionally depend on [O-08](#o-08--task-estimate-and-percent-complete-data-coverage) and [O-14](#o-14--project-completion--subtask-handling).

> **Answer:** ____________  **Owner:** PMO/Leadership

---

## O-17 ❌ Executive attention score — per-indicator thresholds

Distinct from the score bands (already answered as Green 0–25 / Amber 26–55 / Red 56–100). Each **indicator** needs its own trigger point before it can contribute a score.

**Logic needed:**

```text
Overdue high-priority tasks   → scores when count > ______  (or > ______% of open tasks)
Red/Amber task concentration  → scores when > ______% of tasks are Red or Amber
Open high risks               → scores when count of rating >= 20 exceeds ______
Overdue unresolved issues     → scores when open beyond ______ days
Effort overrun                → scores when consumed / estimate > ______
End-date exposure             → scores when end_date within ______ days and completion < ______%
Stale project activity        → scores when no update for ______ days
```

Each also needs a **scale**: is the indicator binary (fires or not) or graded (0–100 within its weight)?

> **Answer:** ____________  **Owner:** PMO/Leadership

---

## O-18 ❌ Should stored project RAG affect the score?

`tbl_projects.rag` is manually entered and **sparsely populated**. The questionnaire's own caution — that it should not be the primary indicator — is well founded, since nothing computes it.

**Logic needed:**

```text
[ ] Exclude RAG entirely — score is fully computed
[ ] Include as one weighted indicator at ______%
[ ] Use as an override — a manual 'Red' forces Red regardless of computed score
[ ] Show alongside the computed score for comparison, but don't feed it in
```

The last option is worth considering: divergence between manual RAG and computed score is itself a useful signal about PM reporting quality.

> **Answer:** ____________  **Owner:** PMO/Leadership

---

## O-19 ❌ Residual risk substitution

`tbl_risk` carries `revised_probability`, `revised_impact` and `after_mitigation_risk_score`, but **no code computes a revised rating** — `tbl_risk.rating` is always derived from the original values.

**Logic needed:**

```text
[ ] No — always use the original rating (matches the app exactly)
[ ] Yes — use after_mitigation_risk_score where populated, fall back to rating
[ ] Report both — original exposure and residual exposure side by side
```

**Before choosing option 2, check population:**

```sql
SELECT COUNT(*) AS total,
       SUM(after_mitigation_risk_score IS NOT NULL AND after_mitigation_risk_score > 0) AS has_residual
FROM tbl_risk WHERE status = 1;
```

Also note both `probability_value` and `impact_value` **default to 1 when unset** (`Risk/index.php:247,251`), so a risk with no scoring reads as `1` (Green) rather than null — residual figures may be similarly defaulted.

> **Answer:** ____________  **Owner:** PMO/Risk Owner

---

## O-20 ❌ Executive/KPI sign-off — 21 KPIs × 6 confirmations

**None of the 21 KPIs exist as implemented calculations.** Each needs formula, threshold, reporting period, inclusion/exclusion criteria, drill-down fields, and expected visualisation.

Feasibility is already mapped, so this can be sequenced rather than tackled at once:

| Group | KPIs | Ship now? | Blocked on |
| ----- | ---: | --------- | ---------- |
| **7.3 Risk & Issue Exposure** | 4 | ✅ **Yes — do first** | Only [C-01](PMS_Contradictions_Requiring_Decision.md) (severity direction) |
| **7.2 Task Delivery** | 4 | ✅ **Mostly** | "Effort vs work completed" needs O-08/O-14 |
| 7.4 Resource & Capacity | 5 | Partly | "Ending soon" + demand are ready; utilisation blocked on O-04, O-09–O-13 |
| 7.5 Financial & Effort | 4 | Partly | `deal_value`, `estimate`, `total_hours_booked` exist; "unhealthy" needs O-15–O-18 |
| 7.1 Portfolio Health | 4 | ❌ No | Entirely dependent on O-15–O-18 |

**Recommended:** sign off 7.3 and 7.2 as a first release — eight KPIs resting on rules the code already confirms. Defer the rest.

🔍 Before relying on the §7.5 pre-computed fields (`deal_value`, `deal_type`, `estimate`, `total_hours_booked`, `total_chargable_hours`, `combined_hours`, `grant_hours`, `project_duration`), verify they are actively maintained rather than legacy.

> **7.3 signed off:** ☐  **7.2 signed off:** ☐  **Owner:** PMO/Leadership

---

# Group C — UAT test data

## O-21 🟠 User sample — numeric ID needed

All six user slots name *Saurav Kaushik*. Per §2, **names are not reliable keys** — supply the numeric `user_id`.

> **`user_id`:** ____________

---

## O-22 🟠 Project samples — 5 of 7 still blank

Two slots are filled with the Bandhan AMC project. The remaining five can be found with one query rather than by hand:

```sql
SELECT p.project_id, p.title,
       (SELECT COUNT(*) FROM tbl_project_issues i WHERE i.project_id = p.project_id AND i.status = 1) AS issues,
       (SELECT COUNT(*) FROM tbl_risk r          WHERE r.project_id = p.project_id AND r.status = 1) AS risks,
       (SELECT COUNT(*) FROM tbl_project_users u WHERE u.project_id = p.project_id
                                                   AND u.request_status = 'A' AND u.status = 1) AS members
FROM tbl_projects p
WHERE p.status = 1 AND p.archive = 0
HAVING issues > 0 AND risks > 0 AND members > 1
LIMIT 5;
```

| Slot | Project ID |
| ---- | ---------- |
| With issues | ________ |
| With risks | ________ |
| With executive-summary data (`tbl_project_executive_summary`) | ________ |
| With infrastructure-cost data (`tbl_project_infrastructure_*`) | ________ |
| With active allocated users | ________ |

🔍 The executive-summary and infrastructure-cost tables have **not been confirmed as populated** — check before assigning those two slots.

---

## O-23 🟠 Transaction samples — all 6 blank

| Slot | ID |
| ---- | -- |
| Task with assignees | ________ |
| Task with subtasks | ________ |
| Task with timesheet entries | ________ |
| Risk with history | ________ |
| Issue with a valid reference | ________ |
| Department linked to active projects | see [O-06](#o-06--department-uat-sample) |

⚠️ Use internal IDs, not reference numbers. Reference numbers are `COUNT + 1` counters and are **not reliably unique even within a project** — a deletion causes the next insert to reuse a number.

---

# Group D — Governance

## O-24 ❌ Sign-off owner names

Roles are suggested; **no person is named against any of the nine areas.** Nothing in Group B can be signed off until these exist.

| Decision Area | Suggested Owner | Named Person |
| ------------- | --------------- | ------------ |
| Project status and lifecycle | PMS Product Owner | ____________ |
| Task workflow statuses | Delivery/PMS Product Owner | ____________ |
| Issue workflow and severity | QA/Delivery Governance | ____________ |
| Risk formula and thresholds | PMO/Risk Owner | ____________ |
| Utilization and capacity | Resource Management/HR | ____________ |
| Financial fields and deal value | Finance/Commercial Team | ____________ |
| RBAC and "my" semantics | Product Owner/Security | ____________ |
| KPI weights and executive score | PMO/Leadership | ____________ |
| Database performance and indexes | DBA/Engineering | ____________ |

⚠️ [C-01](PMS_Contradictions_Requiring_Decision.md) and [C-04](PMS_Contradictions_Requiring_Decision.md) are **factual corrections, not preference choices** — they need an owner who can authorise a change to the application or the questionnaire, not merely approve a mapping.

---

## O-25 🟡 Deferred-item dispositions

Table existence has been verified for all eight areas. A disposition is still needed for each.

| Area | Table exists? | Recommendation | Disposition |
| ---- | ------------- | -------------- | ----------- |
| Milestone progress / ownership | Yes, but empty | Remain deferred — adoption gap, not schema gap | ____________ |
| Milestone-based completion | Yes, but empty | Remain deferred; O-14 uses effort-weighted instead | ____________ |
| Project estimation versions | Yes | Remain deferred pending population check | ____________ |
| Team-name questions | Yes (`TableProjectTeam`) | Remain deferred | ____________ |
| Project-stage aging | Partly — **no stage-change history table** | **Reframe** using `update_date`, or remove | ____________ |
| Predictive probability | n/a | **Remove from first release** — no model, no history to train one | ____________ |
| Leave / holiday calendar | **No table anywhere** | Add to deferred list — blocks O-11 | ____________ |
| Skills-based questions | Yes (`TableMasterSkills`, `TableUserSkills`) | **Viable — promote out of deferred** | ____________ |

---

## O-26 🟡 DBA index review

Eight index areas need review, but two inputs should be gathered first so the DBA receives **one combined change set** rather than a second uncoordinated request:

1. **A captured slow-query log already exists in the application repo** — `source/application/modules/Risk/classes/Project-mysql-slow-queries`. Real production statements, including the task-listing query with the `IF(t2.parent_id > 0, …)` self-join. Start here rather than with synthetic tests.
2. **Prior optimisation work is recorded** in `.claude/memory/perf_n1_fixes.md` — batch pre-fetch fixes and a `getTotalTasks` COUNT optimisation, **with `ALTER TABLE` statements still pending on the server.** These likely overlap the list below.

Areas flagged for review: project title/status filters · task reference number · task project/status/due-date · timesheet user/date · timesheet task/date · project-user user/status/request-status · risk reference number · issue reference number.

⚠️ Several of these index the **wrong access path** if [C-02](PMS_Contradictions_Requiring_Decision.md) is adopted — joining on `status_type` changes which columns need covering indexes. **Settle C-02 before the DBA designs indexes.**

> **Combined change set prepared:** ☐  **DBA review booked:** ☐

---

# Tracking summary

| ID | Item | Group | Blocks | Owner |
| -- | ---- | ----- | ------ | ----- |
| O-01 | `GLOBAL_PROJECT_STATUS` | A | All status queries | DBA/Engineering |
| O-02 | Task status rows | A | C-02, C-10 | DBA/Engineering |
| O-03 | Issue status rows | A | C-03 | DBA/Engineering |
| O-04 | `MONTHLY_BILLING_HOURS` | A | All of §7.4 | DBA/Engineering |
| O-05 | Project priority rows | A | Priority questions | DBA/Engineering |
| O-06 | Department sample | A | 1 skipped query | DBA/Engineering |
| O-07 | Project title unique index | A | §2 assumption | DBA/Engineering |
| O-08 | Estimate/pct coverage | A | O-14, §1.8 | Delivery/PMS PO |
| O-09 | Weekly capacity | B | §7.4 | Resource Mgmt/HR |
| O-10 | Working days per week | B | §7.4 | Resource Mgmt/HR |
| O-11 | Leave and holidays | B | §7.4 | Resource Mgmt/HR |
| O-12 | Part-time resources | B | §7.4 | Resource Mgmt/HR |
| O-13 | Over-allocation threshold | B | §7.4 | Resource Mgmt/HR |
| O-14 | Subtask handling | B | §1.8, §7.2 | Delivery/PMS PO |
| O-15 | Attention score indicators | B | §7.1, §7.5 | PMO/Leadership |
| O-16 | Attention score weights | B | §7.1 | PMO/Leadership |
| O-17 | Per-indicator thresholds | B | §7.1 | PMO/Leadership |
| O-18 | RAG in the score | B | §7.1 | PMO/Leadership |
| O-19 | Residual risk | B | §7.3 | PMO/Risk Owner |
| O-20 | 21 KPI sign-offs | B | §7 delivery | PMO/Leadership |
| O-21 | User ID | C | UAT | You |
| O-22 | 5 project IDs | C | UAT | You |
| O-23 | 6 transaction IDs | C | UAT | You |
| O-24 | 9 sign-off owners | D | **All of Group B** | You |
| O-25 | 8 deferred dispositions | D | Scope of release 1 | Product Owner |
| O-26 | DBA index review | D | Production readiness | DBA/Engineering |

## Critical path

```text
O-24 (name the owners)
   └─> C-01 severity direction  ──> 7.3 KPIs shippable (4 KPIs)
   └─> C-02 status_type rewrite ──> 7.2 KPIs shippable (4 KPIs)
                                     └─> O-26 index review (needs C-02 first)

O-01 + O-02 + O-03 + O-04 + O-05 + O-06  (one session on the server — closes 6 items)

O-04 ──> O-09..O-13 ──> 7.4 utilisation KPIs
O-08 ──> O-14 ──────> §1.8 completion ──> 7.2 "effort vs work completed"
O-15 ──> O-16 ──> O-17 ──> O-18 ──> 7.1 Portfolio Health (last)
```

**Fastest meaningful progress:** one server session closes O-01 through O-06 (six items), and C-01 alone unblocks four shippable KPIs.
