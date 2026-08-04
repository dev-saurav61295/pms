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
- **`pms sql verifier.py`** — the harness. Contains ~70 hardcoded query dicts, but at line 767 `load_queries_from_workbook()` **silently replaces the entire `QUERIES` list** if the workbook parses. Editing the inline dicts has no effect while the .xlsx is present.
- **`extract_test_params.sql`** — single-row query returning seed values for every `TEST_PARAMS` key. Run it through the MySQL MCP server, then paste the values in.
- **`engagedb.sql`** — phpMyAdmin dump (schema + data). Use this for offline schema lookups rather than querying the live DB.
- **`empty_tables_report.json`** — 109 of 306 tables are empty. A query hitting an empty table technically PASSes with 0 rows, so this report is how you tell "wrong SQL" from "no data".

## Verifier mechanics

- Workbook parsing is **hand-rolled OOXML**: `zipfile` + `ElementTree`, no openpyxl. Cells are read positionally from `row.findall("a:c")`, so a blank cell mid-row shifts every later index — rows with fewer than 12 cells are skipped outright.
- Bind params are `:name` in the templates; `replace_bind_params()` rewrites them to pymysql's `%(name)s`. Params are discovered by regex from the SQL itself when loading from the workbook.
- Any query whose params are `None` in `TEST_PARAMS` is **SKIPPED**, not failed. A large SKIP count means unfilled test params, not broken SQL.
- `LIMIT 5` is appended unless the SQL already contains "LIMIT" anywhere (substring check, so a `LIMIT` in a subquery suppresses it).
- After the query run, a fixed `lookup_queries` block dumps status/priority/type master tables into `lookup_master_data` — these resolve the magic status IDs used throughout the templates.
- Output: `pms_verification_results.json` with per-query `status` (PASS/FAIL/SKIPPED), columns, row count, 2 sample rows, and `sql_executed`.

## Database access

Read-only by construction and it must stay that way — the DB user is `engagedb_ro_usr`, and the MySQL MCP server in `.mcp.json` sets `ALLOW_INSERT/UPDATE/DELETE/DDL_OPERATION=false`. Never write to the live database; use `engagedb.sql` if you need to experiment against a schema.

`.mcp.json` launches the server via absolute paths under `/Users/sauravkaushik/Developer/AI/PMS/` — a **different directory than this one**. It sources `.env` from there and runs the node binary from there. If MCP calls fail, that path drift is the first thing to check; `.claude/settings.json` also lists that directory under `additionalDirectories`.

## Schema conventions worth knowing before writing SQL

- `status = 1` means active; `archive = 0` means not archived. Most templates filter on both.
- Projects join to people via `tbl_projects.pm_user_id` / `project_owner_id` and `tbl_project_users`. Column J of the workbook flags several rows as "Not Mapped – Business Rule Required" precisely because "my projects" is ambiguous across those three — don't invent a definition, surface the ambiguity.
- Tasks/risks/issues are identified in questions by `reference_no`, projects by `title` or `project_unique_id`.
- Status/priority lookups live in separate tables (`tbl_project_status`, `tbl_project_task_status`, `tbl_risk_status`, `tbl_project_issue_status`, …) ordered by `status_order`.
