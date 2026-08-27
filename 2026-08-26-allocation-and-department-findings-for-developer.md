# Allocation Date & Department-Membership Findings — RESOLVED

**Found:** 2026-08-26, via live testing against `engagedb` (test case: department "BFS", `tbl_groups.group_id = 95`)
**Resolved:** 2026-08-27, per developer clarification.
**Status:** Both findings below are now answered. This doc is kept as the evidence record; the resolutions are applied directly in `PMS Questions and Query - Sheet1.csv` and in `CLAUDE.md`'s "Confirmed correctness rules" section.

## Resolutions

1. **Allocation dates**: `tbl_project_users.allocation_from`/`allocation_to` exist as columns but are **not populated** in this PMS instance — not a partial data-quality gap, a feature that isn't in use. Consequence: any question that *requires* a real date to answer (allocations ending/starting "in the next N days," forecast utilization, allocation-vs-deadline gap analysis) is genuinely unanswerable from this data and has been reclassified `Blocked - Data Not Available` in the workbook. Questions that only need *current* allocation state (utilization, idle capacity, overallocation, availability) have been rewritten to drop the date-range filter and report the present snapshot instead of a period — `:period`/`:start_date`/`:end_date`-style parameters are effectively unused on those now, which is called out in an SQL comment on each one.
2. **Department membership**: `tbl_group_projects` (joined to `tbl_groups`) is the authoritative path for "projects in department X" — supersedes the direct `tbl_projects.department_id` FK that the earlier C-05 decision pointed at. Both department queries in the workbook have been rewritten accordingly.

---

## Finding 1: `tbl_project_users.allocation_from`/`allocation_to` are unset for a large share of real, active allocations — every query filtering on them under-reports

### Evidence

Same department (BFS), same join, same active-membership filters (`pu.status = 1 AND pu.request_status = 'A'`) — only the allocation date-range filter changed:

| Query variant | Users | Projects | Hours |
|---|---|---|---|
| **With** `allocation_from <= '2026-08-31' AND allocation_to >= '2026-08-01'` | 0 | 0 | 0 (no rows at all) |
| **Without** the date filter | 236 | 533 | 25,265.00 |

Removing only the date-range filter took the result from **zero rows to hundreds of real allocations**. That's only possible if a large share of `allocation_from`/`allocation_to` values fail a range comparison — almost certainly because they're `NULL` (or `0000-00-00`) rather than a real date, consistent with the MIS resource-allocation sync writing `NULL`/`0.00` into these columns on most of its sync paths.

### Question for the developer — RESOLVED

Confirmed: these columns are not logged in this PMS instance — expected, not a gap to backfill. Applied: date-range filters dropped where the question can survive becoming "current state"; questions that inherently need a real date reclassified `Blocked - Data Not Available`.

### Questions in the workbook affected

All nine below filter on `allocation_from`/`allocation_to` in a `WHERE` or `ON` clause and will under-report until Finding 1 is resolved.

**1. Whose project allocation ends in the next :days days?**
```sql
SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, p.project_id, p.title AS project_title, pu.allocation_to, pu.allocation_hrs, pu.resource_type
FROM tbl_project_users pu
JOIN tbl_projects p ON p.project_id = pu.project_id
JOIN tbl_users u ON u.user_id = pu.user_id
WHERE pu.status = 1 AND pu.request_status = 'A'
  AND pu.allocation_to >= CURRENT_DATE
  AND pu.allocation_to < DATE_ADD(CURRENT_DATE, INTERVAL :days + 1 DAY)
ORDER BY pu.allocation_to, employee_name;
```

**2. Whose project allocation starts in the next :days days?**
```sql
SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, p.project_id, p.title AS project_title, pu.allocation_from, pu.allocation_to, pu.allocation_hrs, pu.resource_type
FROM tbl_project_users pu
JOIN tbl_projects p ON p.project_id = pu.project_id
JOIN tbl_users u ON u.user_id = pu.user_id
WHERE pu.status = 1 AND pu.request_status IN ('A','I')
  AND pu.allocation_from >= CURRENT_DATE
  AND pu.allocation_from < DATE_ADD(CURRENT_DATE, INTERVAL :days + 1 DAY)
ORDER BY pu.allocation_from, employee_name;
```

**3. Who with skill :skill_name is available between :start_date and :end_date?** — note this one uses the date range inside a `LEFT JOIN ... ON` as an anti-join (finding people with *no* overlapping allocation), so a NULL-dated real allocation would make that person incorrectly look "available":
```sql
SELECT u.user_id, u.username, CONCAT(u.first_name, ' ', u.last_name) AS user_name, us.skill_id, pu.allocation_from, pu.allocation_to, pu.allocation_hrs
FROM tbl_users u
INNER JOIN tbl_user_skills us ON u.user_id = us.user_id
LEFT JOIN tbl_project_users pu
    ON u.user_id = pu.user_id
    AND pu.status = 1
    AND pu.request_status = 'A'
    AND pu.allocation_from <= :end_date
    AND pu.allocation_to >= :start_date
WHERE u.enabled = 1 AND u.verified = 1 AND u.is_block = 0
  AND us.status = '1' AND us.skill_id = :skill_id
  AND pu.user_id IS NULL
ORDER BY user_name;
```

**4. Who has allocations exceeding available capacity?**
```sql
SELECT u.user_id, CONCAT(u.first_name, ' ', u.last_name) AS employee_name,
    SUM(pu.allocation_hrs) AS total_allocated_hours,
    COUNT(DISTINCT pu.project_id) AS total_projects
FROM tbl_project_users pu
INNER JOIN tbl_users u ON pu.user_id = u.user_id
WHERE pu.status = 1 AND pu.request_status = 'A'
  AND pu.allocation_from <= '2026-08-31'
  AND pu.allocation_to >= '2026-08-01'
GROUP BY u.user_id, employee_name
ORDER BY total_allocated_hours DESC;
```

**5. How much idle capacity is available in :period?**
```sql
SELECT u.user_id, CONCAT(u.first_name, ' ', u.last_name) AS employee_name,
    COUNT(DISTINCT pu.project_id) AS total_projects,
    COALESCE(SUM(pu.allocation_hrs), 0) AS total_allocated_hours
FROM tbl_users u
LEFT JOIN tbl_project_users pu
    ON u.user_id = pu.user_id
    AND pu.status = 1
    AND pu.request_status = 'A'
    AND pu.allocation_from <= :period_end
    AND pu.allocation_to >= :period_start
WHERE u.enabled = 1 AND u.verified = 1 AND u.is_block = 0
  AND (:population_scope = 'ALL' OR u.company_id = :population_scope)
GROUP BY u.user_id, employee_name
ORDER BY total_allocated_hours ASC;
```

**6. Show utilization by project role for :period.**
```sql
SELECT pu.role_id,
    COUNT(DISTINCT pu.user_id) AS total_users,
    COUNT(DISTINCT pu.project_id) AS total_projects,
    SUM(pu.allocation_hrs) AS total_allocated_hours
FROM tbl_project_users pu
WHERE pu.status = 1 AND pu.request_status = 'A'
  AND pu.allocation_from <= :period_end
  AND pu.allocation_to >= :period_start
GROUP BY pu.role_id
ORDER BY total_allocated_hours DESC;
```

**7. Show utilization for department :department_name in :period.** — the query that surfaced this whole investigation. Also carries the separate schema bug described in Finding 2 below.
```sql
SELECT d.department_name,
    COUNT(DISTINCT pu.user_id) AS total_users,
    COUNT(DISTINCT pu.project_id) AS total_projects,
    SUM(pu.allocation_hrs) AS total_allocated_hours
FROM tbl_project_users pu
INNER JOIN tbl_projects p ON pu.project_id = p.project_id
INNER JOIN department d ON p.department_id = d.department_id
WHERE pu.status = 1 AND pu.request_status = 'A'
  AND d.department_name = :department_name
  AND pu.allocation_from <= :period_end
  AND pu.allocation_to >= :period_start
GROUP BY d.department_name
ORDER BY total_allocated_hours DESC;
```

**8. What is forecast utilization for :future_period?**
```sql
SELECT u.user_id, CONCAT(u.first_name, ' ', u.last_name) AS employee_name,
    COUNT(DISTINCT pu.project_id) AS total_future_projects,
    SUM(pu.allocation_hrs) AS forecast_allocated_hours
FROM tbl_project_users pu
INNER JOIN tbl_users u ON pu.user_id = u.user_id
WHERE pu.status = 1 AND pu.request_status = 'A'
  AND pu.allocation_from <= '2026-09-30'
  AND pu.allocation_to >= '2026-09-01'
GROUP BY u.user_id, employee_name
ORDER BY forecast_allocated_hours DESC;
```

**9. Which resource allocations end before their assigned open tasks or project delivery dates?** — this one already guards with `IS NOT NULL`, which confirms the column is known to sometimes be NULL, but it means allocations *without* an end date are silently excluded from this "at risk" list too. Worth confirming whether that's the intended definition (an open-ended allocation arguably can't "end before" a due date, so excluding it may in fact be correct here — unlike the other eight, which are excluding rows unintentionally).
```sql
SELECT u.user_id, CONCAT(u.first_name,' ',u.last_name) AS employee_name,
    p.project_id, p.title AS project_name,
    pu.allocation_from, pu.allocation_to,
    pt.task_id, pt.title AS task_name, pt.priority, pt.rag, pt.due_date, p.end_date,
    DATEDIFF(pt.due_date, pu.allocation_to) AS task_gap_days,
    DATEDIFF(p.end_date, pu.allocation_to) AS project_gap_days
FROM tbl_project_users pu
INNER JOIN tbl_users u ON pu.user_id = u.user_id
INNER JOIN tbl_projects p ON pu.project_id = p.project_id
INNER JOIN tbl_project_task_users ptu ON pu.user_id = ptu.user_id
INNER JOIN tbl_project_tasks pt ON ptu.task_id = pt.task_id AND pt.project_id = pu.project_id
WHERE pu.status = 1 AND pu.request_status = 'A'
  AND p.status = 1 AND p.archive = 0
  AND pu.allocation_to IS NOT NULL
  AND pu.allocation_to <= DATE_ADD('2026-08-11', INTERVAL 30 DAY)
  AND (pt.due_date > pu.allocation_to OR p.end_date > pu.allocation_to)
ORDER BY pu.allocation_to, pt.due_date;
```

*(Four more questions — "What projects am I allocated to?", "Show allocations for :employee_name.", "Who is allocated to :project_name?", "Show allocated hours by user for :project_name." — display `allocation_from`/`allocation_to` as output columns but don't filter on them, so they're lower severity: affected rows will just show a blank/NULL date rather than silently disappearing from the result set. Query text omitted here since no fix/decision is needed on these unless Finding 1 changes how the columns should be interpreted for display too.)*

---

## Finding 2: two different, both-real answers for "which projects belong to department X"

### Evidence

Also from the BFS test case:

| Path | Projects matched |
|---|---|
| `tbl_projects.department_id = tbl_groups.group_id` (the direct FK — this is what was confirmed as the correct join in the earlier C-05 decision) | 553 |
| `tbl_group_projects.group_id = tbl_groups.group_id` (the group↔project portfolio junction) | 635 |

Both are real, substantial, non-zero. Neither is a data error — they're two different mechanisms that both exist in the schema and don't agree. The junction consistently returns more than the direct FK (projects portfolio-linked to BFS without `department_id` being set to match), which lines up with the schema having no constraint tying the two together.

### Question for the developer — RESOLVED

Confirmed: `tbl_group_projects` (joined to `tbl_groups`) is authoritative. Both affected queries below have been rewritten to use it; the `department_id`-based version is no longer used for project-membership resolution.

### Questions in the workbook affected

**Show active projects for department :department_name.** — uses the direct-FK path:
```sql
SELECT p.project_id, p.project_unique_id, p.project_key, p.title, p.start_date, p.end_date, p.rag, d.name AS department_name
FROM tbl_projects p
JOIN department d ON d.group_id = p.department_id
WHERE d.name = :department_name AND p.status = 1 AND p.archive = 0
ORDER BY p.end_date, p.title;
```

**Show utilization for department :department_name in :period.** — also uses the direct-FK path; full query shown under Finding 1, item 7.

### Separate, unrelated bug in the utilization query — needs fixing regardless of the above decision

The utilization query (Finding 1, item 7) joins:
```sql
INNER JOIN department d ON p.department_id = d.department_id
```
`department` has no `department_id` or `department_name` column (its columns are `group_id` and `name` — see how the *other* department query, "Show active projects for department," already joins it correctly above). This will error outright on execution. It needs `INNER JOIN department d ON p.department_id = d.group_id` and `d.name AS department_name` instead, independent of which membership definition (Finding 2) ends up being authoritative.
