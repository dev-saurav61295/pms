# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Not an application — a **data/SQL verification harness** for an existing PHP/MySQL project-management system (database `engagedb`, ~306 tables, all prefixed `tbl_`). The work is: take a spreadsheet of natural-language PMS questions mapped to SQL templates, run those templates against the live read-only database, and feed the results back so the spreadsheet can be corrected.

The loop looks like this:

```
engagedb.sql (offline schema)  ─┐
empty_tables_report.json       ─┤→  workbook (Q → SQL mapping)  →  pms sql verifier.py
                                │                                        │
                                └────────  fix mappings  ←───  pms_verification_results.json
```

## Commands

```bash
pip install pymysql                              # only dependency for the Python scripts

python3 "pms sql verifier.py"                    # note the spaces in the filename — quote it
python3 table_empty_report.py                    # regenerate empty_tables_report.json
```

Neither script takes arguments. Both read credentials from `.env` (copy from `.env.example`) via a hand-rolled `load_dotenv` that is duplicated in each file. Both fall back to hardcoded host/user defaults if env vars are absent, but exit early if `MYSQL_PASSWORD` is empty.

To run a single query instead of all of them, edit `TEST_PARAMS` / slice `QUERIES` in the verifier — there is no test framework or CLI filter.

## Key files

- **`PMS Questions and Query After Removing Empty Table.xlsx`** — the real source of truth. Sheet1, one question per row, 12 columns; **column L (index 11) holds the SQL template**, C = canonical intent, D = primary question, J = mapping status.
- **`PMS Questions and Query - Sheet1.csv`** — the working copy actually being iterated on (question, 2 alt phrasings, required params, SQL, testing parameter). Edited directly as bugs are confirmed and fixed — see the "Confirmed correctness rules" section below before touching it.
- **`pms sql verifier.py`** — the harness. Contains ~70 hardcoded query dicts, but at line 767 `load_queries_from_workbook()` **silently replaces the entire `QUERIES` list** if the workbook parses. Editing the inline dicts has no effect while the .xlsx is present.
- **`extract_test_params.sql`** — single-row query returning seed values for every `TEST_PARAMS` key. Run it through the MySQL MCP server, then paste the values in.
- **`engagedb.sql`** — phpMyAdmin dump (schema, structure-only — 0 data rows). Use for offline schema lookups, but **its nullability/type claims are not fully trustworthy** — see below. Column names/existence, ENUM value lists, indexes, and trigger definitions have held up under live verification so far; `NOT NULL` claims have not.
- **`empty_tables_report.json`** — 109 of 306 tables are empty (as of 2026-08-04). A query hitting an empty table technically PASSes with 0 rows, so this report is how you tell "wrong SQL" from "no data".
- **`2026-08-20-table-functionality-and-relationship-report.md`** — the definitive table/relationship/gotcha reference, generated from the codebase then corrected twice against the schema dump, the empty-table census, and live query testing. Read this before writing non-trivial SQL against an unfamiliar table.
- **`PMS — Pending Items for POC Review - Sheet1.csv`** — the developer's answers to the open contradictions/questions (`PMS_Contradictions_Requiring_Decision.md` IDs C-01..C-12, `PMS_Open_Items_Pending.md` IDs O-01..O-26). Several are still blank (C-01, C-09, C-12, O-22 through O-26) — check before assuming a business rule is settled.
- **`2026-08-26-allocation-and-department-findings-for-developer.md`** — open questions sent to the developer for the allocation-date and department-membership ambiguities below; not yet answered.

## Verifier mechanics

- Workbook parsing is **hand-rolled OOXML**: `zipfile` + `ElementTree`, no openpyxl. Cells are read positionally from `row.findall("a:c")`, so a blank cell mid-row shifts every later index — rows with fewer than 12 cells are skipped outright.
- Bind params are `:name` in the templates; `replace_bind_params()` rewrites them to pymysql's `%(name)s`. Params are discovered by regex from the SQL itself when loading from the workbook.
- Any query whose params are `None` in `TEST_PARAMS` is **SKIPPED**, not failed. A large SKIP count means unfilled test params, not broken SQL.
- `LIMIT 5` is appended unless the SQL already contains "LIMIT" anywhere (substring check, so a `LIMIT` in a subquery suppresses it).
- After the query run, a fixed `lookup_queries` block dumps status/priority/type master tables into `lookup_master_data` — these resolve the magic status IDs used throughout the templates.
- Output: `pms_verification_results.json` with per-query `status` (PASS/FAIL/SKIPPED), columns, row count, 2 sample rows, and `sql_executed`.

## Database access

### Running SQL the user provides — always via MCP

**When the user supplies a SQL query, run it through the `mysql` MCP server (`mcp__mysql__mysql_query`).** Do not paste it into a Python script, do not hand it back for the user to run manually, and do not answer it from `engagedb.sql` instead. They want results from the live database.

**If the MCP server is disconnected or erroring, say so and stop — ask before falling back to anything else.** Don't silently substitute the offline dump, don't spin up a one-off pymysql script, and don't quietly skip a query. A disconnected server is a thing to report, not to work around.

Run the queries the user actually gave, in the order given. If a query errors (wrong column, wrong table), report the error and the corrected version — running extra exploratory or label-resolution queries on top is a separate step to offer, not to assume. Queries against the big tables can take **30–60s**, so batching in speculative extras is expensive.

Read-only by construction and it must stay that way — the DB user is `engagedb_ro_usr`, and the MySQL MCP server in `.mcp.json` sets `ALLOW_INSERT/UPDATE/DELETE/DDL_OPERATION=false`. Never write to the live database; use `engagedb.sql` if you need to experiment against a schema.

### If the MCP server won't start

`.mcp.json` launches the server via **absolute paths**, and it sources `.env` and the node binary from those paths. They currently point at this directory (`/Users/sauravkaushik/Developer/pms/`), but they previously pointed at a since-deleted `/Users/sauravkaushik/Developer/AI/PMS/` — so **path drift is the first thing to check** if the server fails.

The failure mode is silent and misleading: the launcher is a `sh -c` that starts with `. <path>/.env`, and POSIX `sh` exits immediately when the `.` builtin can't open its file. Node never launches, the stdio pipe closes, and the client reports only `MCP error -32000: Connection closed`. To diagnose, run the `command`/`args` from `.mcp.json` by hand — a working server stays alive and silent; a broken one prints `sh: <path>: No such file or directory` and exits at once.

`.claude/settings.json` still lists the dead `/Users/sauravkaushik/Developer/AI/PMS` under `additionalDirectories`; harmless, but ignore it as a path reference.

## Schema conventions worth knowing before writing SQL

- `status = 1` means active; `archive = 0` means not archived. Most templates filter on both.
- Projects join to people via `tbl_projects.pm_user_id` / `project_owner_id` and `tbl_project_users`. Column J of the workbook flags several rows as "Not Mapped – Business Rule Required" precisely because "my projects" is ambiguous across those three — don't invent a definition, surface the ambiguity.
- Tasks/risks/issues are identified in questions by `reference_no`, projects by `title` or `project_unique_id`.
- Status/priority lookups live in separate tables (`tbl_project_status`, `tbl_project_task_status`, `tbl_risk_status`, `tbl_project_issue_status`, …) ordered by `status_order`.
- `tbl_users.email` is the login identity; `user_id` is only known internally. To parameterize a "my X" query by a person instead of a hardcoded `user_id`, resolve via `JOIN tbl_users u ON u.user_id = <fk>` and filter `WHERE u.email = :user_email` rather than requiring the caller to know the numeric ID.
- `tbl_users` also holds `password`, `salt`, and `session_id` — never `SELECT *` from it in a query whose results get echoed back; select named non-credential columns instead (`user_id, email, username, first_name, last_name, enabled`).
- Confirmed test identity: `saurav.kaushik@intglobal.com` → `user_id = 3066` (username `Saurav2527`, enabled=1).

## Confirmed correctness rules for writing/reviewing SQL (live-verified 2026-08-26)

These are not theoretical — each was confirmed either by reading `engagedb.sql`'s `CREATE TABLE`/`CREATE TRIGGER` blocks or by running the query live and observing the result. Apply them to every new or edited query in the workbook.

**Status resolution — never hardcode a status ID, and never assume one `status_type` vocabulary fits all tables:**
- Resolve "open"/"closed" via the relevant status master's `status_type` column, never via a specific `task_status_id`/`issue_status_id` value — those are configurable per deployment, `status_type` is not.
- The vocabulary differs per table — check which one you're in before writing the filter:
  - `tbl_project_task_status.status_type`: **1**=New, **2**=In Progress, **3**=Closed, **4**=UAT, **5**=Abandoned, **6**=Reopened. "Open" is `status_type IN (1,2,4,6)`, not `!= 3` (that would wrongly include Abandoned). Whether UAT/Reopened count as open for a given report is still a judgment call — flag it, don't assume silently.
  - `tbl_project_issue_status.status_type`: **1**=New, **2**=In Progress, **3**=Closed. `status_type != 3` is safe here (developer-confirmed, C-03).
  - `tbl_risk_status.status_type` and `tbl_pms_issue_status.status_type`: **1**=Open, **2**=Closed only. **`status_type = 3` matches nothing on these two** — use `= 2` for closed, `!= 2` for open.

**ENUM columns must always be quoted in comparisons — never compared as a bare number:**
- MySQL compares an ENUM column to a bare number by **ordinal position**, not by value. This silently inverts results on columns whose values look numeric.
- `tbl_project_tasks.priority` is `enum('High','Medium','Low','Default','In Staging')` — a string, not the int the PHP display layer's index implies. Filter with `priority = 'High'`, never `priority = 0`. There are 5 levels, not 3 — `'Default'`/`'In Staging'` exist in the schema.
- `tbl_rt_support.status` is `enum('0','1')` — `WHERE status = 1` matches the ordinal 1, which is the string `'0'` (the deleted rows). Always `status = '1'`.
- `tbl_risk.isvalid`, `tbl_pms_issues.isvalid`, `tbl_ehs.isvalid` are `enum('0','1')` too — same trap, quote the literal.
- `ORDER BY <enum column> DESC` sorts by declared ordinal, not by intended severity — e.g. `ORDER BY t.priority DESC` puts `'In Staging'` first and `'High'` last. Use an explicit `CASE WHEN priority='High' THEN 1 WHEN 'Medium' THEN 2 ... END` rank instead.

**Date-NULL checks — confirmed live to behave differently per column, don't assume:**
- `tbl_project_issues.date_closed` and `tbl_risk.date_closed`: confirmed live that `IS NULL`/`IS NOT NULL` gives wrong answers (zero-date `'0000-00-00 00:00:00'` stored instead of true NULL for genuinely-open rows — proven by a query returning 100% closure rate on every project, and a literal zero-date row labeled "Closed"). **Never use these columns' NULL-ness to determine open/closed — use the relevant `status_type` instead.**
- `tbl_project_tasks.due_date`: confirmed live to allow **real** NULLs (a query filtering `due_date IS NULL` returned genuine matching rows) — this one does *not* have the zero-date trap, don't "fix" it the same way.
- **The offline `engagedb.sql` dump's `NOT NULL` declarations are not fully trustworthy** — both columns above are declared `NOT NULL` in the dump, and live behavior contradicts that for at least `date_closed`/`due_date`. Column existence, names, ENUM lists, indexes, and triggers have held up under verification; nullability has not. Spot-check with a live `SHOW CREATE TABLE` before hard-coding logic around a NOT NULL assumption.

**Department membership — RESOLVED 2026-08-27: use `tbl_group_projects`, not the direct FK:**
- `tbl_group_projects.group_id` (the portfolio junction, joined to `tbl_groups`) is the **authoritative** path for "projects in department X" — confirmed by the developer. `tbl_projects.department_id = tbl_groups.group_id` (the direct FK the earlier C-05 decision pointed at) is **superseded** for this purpose; the two do not return the same project set (confirmed live: 553 vs. 635 on a test department) and the junction is the one to trust.
  ```sql
  SELECT p.project_id, ...
  FROM tbl_group_projects gp
  JOIN tbl_groups g ON gp.group_id = g.group_id AND g.status = 1
  JOIN tbl_projects p ON p.project_id = gp.project_id
  WHERE g.name = :department_name AND p.status = 1 AND p.archive = 0
    AND gp.project_id <> 0;   -- filter the sentinel row, see below
  ```
- The `department` table (no `tbl_` prefix) is keyed on **`group_id`** and **`name`** — it has **no** `department_id` or `department_name` column. A query joining `department d ON p.department_id = d.department_id` will error. (`department` is an optional enrichment source for HRBP/type/unit attributes, keyed the same way — `department.group_id = tbl_groups.group_id` — not the membership path itself.)
- `tbl_group_projects` can contain a `project_id = 0` sentinel row per group — filter it out of any count (`gp.project_id <> 0`). It also has no unique key, so duplicate `(group_id, project_id)` rows are possible.

**Allocation dates — RESOLVED 2026-08-27: not populated in this PMS instance, not a data-quality gap:**
- `tbl_project_users.allocation_from`/`allocation_to` exist as columns but **are not logged in practice** — confirmed by the developer, not just inferred from NULL rates. Consequence, applied throughout the workbook:
  - Questions that only need **current** allocation state (utilization, idle capacity, overallocation, availability) — **drop the date-range filter entirely** and report the present snapshot; a `:period`/`:start_date`/`:end_date` parameter on these is now vestigial, note it in a comment rather than pretending it's honored.
  - Questions that **require** a real date to mean anything (allocation ending/starting "in the next N days," forecast utilization, allocation-vs-deadline gap analysis) are **not answerable from this data** — treat as `Blocked - Data Not Available`, don't ship a query that will just silently return nothing.

**Join structure — never join multiple "many" child tables as flat siblings off one parent:**
- Joining e.g. `tbl_project_tasks`, `tbl_risk`, `tbl_project_issues`, `tbl_timesheets` all directly off `tbl_projects` in one query multiplies rows across every combination (confirmed live: a portfolio-summary query produced `open_tasks` > `total_tasks`, a mathematical impossibility). Pre-aggregate each dimension in its own subquery, then join the aggregates back to the parent.

**Two more unresolved items — don't silently resolve, ask first:**
- `tbl_projects.client_id` (`int`) joined to `tbl_clients.client_id` (`varchar(255)`) — type mismatch, not yet verified live whether it actually matches correctly.
- Risk-exposure "high" thresholds used ad hoc in some workbook queries (e.g. `rating >= 15`) don't match the app's own hardcoded banding (≥20 red / 12–19 amber / <12 green) — the correct banding model is still an open decision (C-12).
