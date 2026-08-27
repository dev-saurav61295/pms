# Table Functionality & Relationship Report — Int-PMS (Collab), database `engagedb`

**Written:** 2026-08-20 · **Revised:** 2026-08-26 (rev 2) · **Source of truth:** code as checked out on branch `v24042025` (HEAD `a3948ccb`), plus the physical schema dump and the live empty-table census
**Purpose:** definitive guide for constructing accurate SQL against the *active* PMS data.

---

## 0. Scope, Method, and Known Gaps — read this first

### 0.1 Rev 2: the two missing inputs are now in hand, and they change the report

Rev 1 was written without `engagedb.sql` and `empty_tables_report.json`. Both are present in `/Users/sauravkaushik/Developer/pms/`, and reconciling them against rev 1 produced material corrections. **Where this section contradicts the body of the report, this section wins.**

| Input | What it is | What it settled |
|---|---|---|
| `engagedb.sql` | phpMyAdmin **structure-only** dump: 306 tables + 1 view + 19 triggers, 0 rows (the only `INSERT` statements are inside trigger bodies) | data types, nullability, defaults, **ENUM value lists**, indexes, `status_type` semantics from column comments, absence of FKs |
| `empty_tables_report.json` (census 2026-08-04) | 306 tables → **109 empty / 197 non-empty** | which tables actually carry data |

**The corrections that change SQL you would otherwise write:**

1. **`status_type` is not a universal 1/2/3 axis.** Column comments give four *different* vocabularies. `tbl_project_task_status` has **six** values (4=UAT, 5=Abandoned, 6=Reopened); `tbl_risk_status` and `tbl_pms_issue_status` have only **1=Open, 2=Closed** — there is no `status_type = 3` on either. See the corrected §D.3.
2. **`tbl_project_tasks.priority` is `enum('High','Medium','Low','Default','In Staging')`, not an integer.** Rev 1's `0=High, 1=Low, 2=Medium` map is the PHP array index, not the stored value, and its order does not even match the ENUM's. Project priority *is* an int; issue `severity`/`priority` *are* ints.
3. **Comparing an ENUM column to a bare number matches by ordinal, not by value.** `tbl_rt_support.status` is `enum('0','1')`, so `WHERE status = 1` returns the rows where status is the string `'0'` — the deleted ones. Same trap on `tbl_risk.isvalid`, `tbl_ehs.isvalid`. Always quote: `status = '1'`. This makes the Slim API's `Ticket.php` query (`WHERE status = 1`) inverted.
4. **19 triggers exist** and rev 1 missed all of them — including ones that rewrite `search_status` on `tbl_projects`/`tbl_project_issues` during `UPDATE`, and one that clears `tbl_users.online_status` on session delete. See §D.9.
5. **Only one DB view exists: `view_project_tasks_combined`.** `view_timesheet_report`, `view_get_all_tasks_new`, `view_project_tasks`, `view_project_master_tasks`, `view_support_report` and the `view_rt_*` family are referenced in code but are **not in this database**. Rev 1 told you to prefer them; queries using them will fail. See §B.14.
6. **The `tbl_` prefix is *not* universal.** Four non-empty tables have no prefix: **`department`**, `project_infrastructure_requirements`, `project_infrastructure_requirements_audit_trails`, `project_requirements_lineitem` (plus empty `temp_all_task`). `department` is a real, populated table keyed on **`group_id`** and has no Table Object — which is why rev 1 never saw it, and it is the key to the department question (§B.3, C-05).
7. **A whole module was missing: chat.** `tbl_chat_messages`, `tbl_chat_groups`, `tbl_chat_group_messages`, `tbl_chat_group_users`, `tbl_chat_status` are all non-empty and appear nowhere in rev 1 (no Table Objects → invisible to a code-only sweep). See §B.17.
8. **Several tables rev 1 documented as live are empty**, most consequentially `tbl_project_documents`, `tbl_project_risk`, `tbl_project_priority`, `tbl_project_department`, `tbl_project_team`, `tbl_task_insights`, `tbl_client_summary_report`, and all three `tbl_weekly_*` snapshot tables. See §B.16.
9. **Fourteen tables named in rev 1 do not exist at all**, including `tbl_pms_issue_comment_users`, `tbl_rca_team_member`, `tbl_rca_date_history`, `tbl_project_document_history`, `tbl_estimation_assumption`, and four `tbl_project_estimation_*` satellites. Full list in §B.16.
10. **Rev 1's §B.16 "candidate-dormant" list was substantially wrong** in the other direction too: `tbl_qa*`, `tbl_events`, `tbl_albums`/`tbl_photos`, `tbl_interests`, `tbl_discussion`, `tbl_ehs`, `tbl_jobs`, `tbl_homepage`, `tbl_subscriptions` all carry data.

Rev 1's *inferences* held up well where they were about code: no FK constraints (confirmed — zero `FOREIGN KEY` clauses in the dump), the `tbl_project_users` two-gate rule, the `activity_id` spine, `chkPrivateProject()`, and the absence of `tbl_projects.attention_required` (confirmed absent; it is on `tbl_project_tasks`, `tbl_project_issues`, `tbl_pms_issues`).

### 0.1a Rev 2.1 (2026-08-26): the dump's DDL is not fully trustworthy either — confirmed live, not just suspected

While manually verifying mapped queries from `PMS Questions and Query - Sheet1.csv` against the live database, two columns this report describes as `datetime NOT NULL` — **`tbl_project_tasks.due_date`** and **`tbl_project_issues.date_closed`** — returned real rows for an `IS NULL` filter when run live. A genuinely `NOT NULL` MySQL column cannot store `NULL`, so this proves the **live server's schema differs from `engagedb.sql`** for at least these two columns; the dump is either stale or was taken from a different environment than the one the MCP server connects to.

**Practical consequence: do not treat `engagedb.sql` as authoritative for nullability, defaults, or types when the conclusion matters** (deciding a query is broken, writing a filter that depends on NOT NULL semantics, etc.). It remains reliable for column *existence*, column *names*, ENUM value lists, index lists, and trigger definitions — nothing in the live-verification pass so far has contradicted those — but every `NOT NULL` claim in §B and §D of this report, including the "zero-date trap" guidance in §D.6, should be spot-checked with a live `SHOW CREATE TABLE` before being used to justify a fix.

### 0.2 The physical schema, confirmed

- Every Table Object hardcodes `private $db_name = 'engagedb';` and `private $table_name = 'tbl_<name>';`.
- `getTableName()` returns `` `engagedb`.`tbl_x` `` — so **all queries are database-qualified**. The `tbl_` prefix covers 301 of 306 tables; see §0.1 item 6 for the five exceptions.
- `__loadTable('project_tasks', 'alias')` maps the *unprefixed* name to `TableProjectTasks` → `tbl_project_tasks`. **The name passed to `__loadTable` is the table name minus `tbl_`.**
- **Zero foreign-key constraints in the physical schema** — confirmed, not inferred. Every relationship in this report comes from JOIN clauses and column naming. Nothing in the database prevents orphans, and several join pairs are **type-mismatched**, which suppresses index use and can force implicit casts:

  | Join | Left type | Right type |
  |---|---|---|
  | `tbl_projects.project_id` ↔ `tbl_group_projects.project_id` | `bigint` | `int` |
  | `tbl_groups.group_id` ↔ `tbl_group_projects.group_id` | `bigint` | `int` |
  | `tbl_projects.department_id` ↔ `tbl_groups.group_id` | `int` | `bigint` |
  | `tbl_projects.client_id` ↔ `tbl_clients.client_id` | `int` | `varchar(255)` |

  The last one is not just slow, it is suspect — see §B.3.
- A Table Object column list is a *subset* guarantee, not an equality: it lists what the app reads/writes. The dump shows real columns rev 1 could not see (`tbl_projects.source`, `tbl_project_tasks.parent_project_id`, `tbl_project_tasks.acceptance_criteria`), and rev 1 listed `tbl_users.department_id`, which **does not exist**.

### 0.3 Usage ranking method

I counted `__loadTable()` call sites across `source/application/modules/**` and `cron-job/**` and built a table→module index. Top of the distribution:

```
users 96 · activities 55 · comments 51 · groups 49 · projects 45 · group_projects 44
project_tasks 43 · timesheets 42 · attachment 42 · group_users 37
project_task_comment_users 25 · menu_settings 25 · roles 23 · rt_support 19
project_issues 18 · project_documents 18 · project_users 17 · project_issue_comment_users 17
```

**Rev 2 caveat: do not use this as an emptiness proxy.** The census disagrees with it in both directions — `tbl_project_documents` has 18 load sites and no rows, while `tbl_chat_*`, `department`, `tbl_tags` and `tbl_project_tasks_prompt` have zero load sites and plenty of rows. Load-site count measures how much *code* touches a table, which in a codebase with this much dead feature surface is a different question from whether the table holds data. Use §B.16.

### 0.4 The Slim REST API is effectively vestigial — do not model relationships from it

The task brief assumed Eloquent models with `hasMany`/`belongsTo` in `api/src/models/`. In reality:

- `api/src/models/` contains exactly **two** files.
- `api/src/models/User.php` is the only Eloquent model. It declares `protected $table = 'users'` — **note: no `tbl_` prefix**, which does not match any legacy table. It defines a `$hidden` list and **zero relationships**.
- `api/src/models/Ticket.php` is not Eloquent at all — it is raw PDO: `SELECT * FROM tbl_rt_support WHERE status = 1`.
- `api/src/routes.php` registers only three routes: `POST /api/v1/user/login`, `POST /api/v1/user/register`, `GET /api/v1/user/lists`. The `Ticket` controller has **no route bound to it**.

**Conclusion: there are no Eloquent-declared relationships in this codebase.** Every relationship documented below comes from the legacy app's hand-built SQL. Do not treat the Slim API as a schema authority.

The **legacy `Api` module** (`source/application/modules/Api/`) is the API that actually matters for data provenance — see §B.1.4.

---

## A. Executive Summary

Int-PMS is a project-delivery platform whose data model has three layers stacked on top of each other, each added in a later era and none of them removed.

**Layer 1 — a social-network core (oldest).** `tbl_users`, `tbl_activities`, `tbl_comments`, `tbl_attachment`, `tbl_groups`, `tbl_follow`, plus photo/video/album/poll/Q&A/bulletin tables. `tbl_activities` is the **polymorphic hub of the entire application**: nearly every business entity carries an `activity_id`, and comments, attachments and notifications hang off that `activity_id` rather than off the entity's own primary key. Understanding this is the single most important prerequisite for querying this database correctly.

**Layer 2 — the PMS proper (the working system).** A portfolio hierarchy of **Group → Project → Task**, with `tbl_group_projects` and `tbl_project_users` as the load-bearing junctions, and satellite registers for issues, risks, RCAs, releases, documents, and timesheets. This is where essentially all reporting demand lives.

**Layer 3 — later bolt-ons.** Support ticketing (`tbl_rt_*`), pre-sales estimation (`tbl_project_estimation*`, `tbl_lineitem_*` — mostly **empty**, see §B.16), infrastructure/requirements planning (partly **unprefixed** tables), a second issue register (`tbl_pms_issues`), repositories, an EHS module (`tbl_ehs`, populated), and an **instant-messaging layer** (`tbl_chat_*`, populated) that has no Table Objects and is therefore invisible to code-only analysis — see §B.17.

**Also outside the ORM: the `department` table.** Unprefixed, populated, keyed on `group_id`, carrying HRBP owner, department type, unit, production status and enterprise flags. It is the department master that `tbl_projects.department_id` actually points into — via `tbl_groups.group_id`. The prefixed `tbl_project_department` and `tbl_project_team` are **empty legacy**.

The primary tables that drive the working system:

| Entity | Table | Junction to users |
|---|---|---|
| Portfolio / department | `tbl_groups` | `tbl_group_users` |
| Project | `tbl_projects` | `tbl_project_users` |
| Task | `tbl_project_tasks` | `tbl_project_task_users` |
| Issue (project) | `tbl_project_issues` | `tbl_project_issue_users` |
| Time booked | `tbl_timesheets` | direct `user_id` |
| Support ticket | `tbl_rt_support` | `tbl_rt_support_owner` |

The `Project` module is the centre of gravity: `Project_model.php` is **539 KB / ~11 200 lines** and loads over 60 tables. Contrary to what the module list suggests, `Task_model.php` (20 KB) holds almost no task logic — **task queries live in `Project_model.php`.** Look there first.

---

## B. Module-by-Module Table Mapping

Notation: `PK` = primary key (inferred), `FK→` = foreign key by naming/JOIN evidence. "Managed by" = the module(s) whose model loads the table.

---

### B.1 Identity, Organisation & Access

#### `tbl_users` — the master person record
- **Functionality:** every human in the system: employees, PMs, clients, and guest users. Also holds profile/social fields inherited from Layer 1.
- **Managed by:** `Users`, `Profile`, `Access`, and read by **45+ modules** — the most-joined table in the database.
- **Key fields (72 columns; verified against the dump):** `user_id` (PK), `email`, `username`, `password`+`salt`, `company_id` FK→`tbl_companies`, `job_id` FK→`tbl_jobs`, `role_id` FK→`tbl_roles`, `area_work_id`, `enabled`, `verified`, `guest_user`, `is_block`, `is_default`, `admin_access`, `online_status`, `login_status`, `session_id`, `signup_date`, `lastlogin_date`, `lastactivity`, `country_id`, `region_id`, `hometown_id`, `current_location_id`, `first_name`, `last_name`, `designation`, `language_id`, `hide_archive`, `intern_status`, `source`, `color_code`.
- **Relationships:** joined into practically every listing query on `user_id`. Canonical filters seen in code: `verified = 1`, `guest_user = 0`, `enabled = 1`.
- **Corrections (rev 2):**
  - **There is no `department_id` on `tbl_users`.** Rev 1 listed one; the dump has none. A person's department is reached through group membership (`tbl_group_users` → `tbl_groups` → `department`), not from the user row.
  - **`hide_archive` is `enum('TRUE','FALSE') DEFAULT 'TRUE'`**, not 0/1 — compare against the strings.
  - **`source` is `enum('I','T','P','V')`** = INT / Techshu / Prime / VLoka (same enum on `tbl_projects`). This is the tenant-of-origin marker and is the cleanest way to segment the estate; rev 1 missed it on both tables.
  - `intern_status enum('I','N')`, `email_notification`, `is_default`, `is_block` are all `tinyint UNSIGNED`.
- **Gotcha:** there is **no `status` column** on `tbl_users` — use `enabled` / `verified` / `is_block`. Do not assume the `status = 1` convention here.
- **Trigger side effects:** `user_master_insert` writes a `tbl_site_search` row only when `enabled = 1 AND verified = 1`; `user_master_update` and `user_master_delete` maintain it. `resetOnlineStatus` on `tbl_sessions` DELETE zeroes `online_status` and blanks `session_id`. So `online_status` is session-derived, not a reporting fact — see §D.9.

#### `tbl_companies`, `tbl_jobs`, `tbl_roles`, `tbl_project_department`, `tbl_project_team`
- `tbl_companies`: `company_id` (PK), `company_name`, `domain_name`, `theme`, **`is_private`**, `status`. The `is_private` flag drives the multi-tenant visibility filter — see §D.4.
- `tbl_jobs`: `job_id` (PK), `job_title`, `level_id`, `admin_access`, `status`. Designation/grade lookup.
- `tbl_roles`: `role_id` (PK), `default_role`, `role_slug`, `role_name`, `access_permission`, `display_order`, `status`. `access_permission` is a serialised permission blob, not a scalar. Joined from `tbl_project_users.role_id` and `tbl_group_users.role_id`.
- `tbl_project_department`: `department_id` (PK), `company_id`, `department_name`, `status`. **EMPTY — do not use.**
- `tbl_project_team`: `team_id` (PK), `company_id`, `department_id`, `parent_id`, `team_name`, `status`. **EMPTY — do not use.** `tbl_projects.team_id` therefore resolves to nothing.

#### `department` (**no `tbl_` prefix**) — the real department master
- **Non-empty. No Table Object, no Eloquent model** — reached only by raw SQL or not at all from the app; rev 1 could not see it.
- **Columns:** **`group_id`** (the key — it *is* a `tbl_groups.group_id`), `hrbp_id`, `owner_id`, `name`, `department_type enum('Department',…)`, `unit enum('Not Applicable',…)`, `production_status enum('Yes',…)`, `short_url`, `org_dept_type enum('Production',…)`, `sbu_type varchar(150) DEFAULT 'Centralize'`, `department_function`, `showinpf`, `is_enterprise enum('Yes',…)`, `last_updated_date timestamp ON UPDATE CURRENT_TIMESTAMP`.
- **This is the table that resolves the department question (C-05).** A department is a `tbl_groups` row with an extra `department` row hanging off the same `group_id`. So:
  ```sql
  SELECT p.project_id, p.title,
         g.group_id AS department_id, g.name AS department_name,
         d.department_type, d.org_dept_type, d.hrbp_id
  FROM tbl_projects p
  LEFT JOIN tbl_groups g ON g.group_id = p.department_id AND g.status = 1
  LEFT JOIN department d ON d.group_id = g.group_id          -- optional enrichment
  WHERE p.status = 1;
  ```
  The developer-confirmed form (C-05) is the first two joins; `department` is what you add when the question asks for department *type*, unit, HRBP or production status. Note the `int` ↔ `bigint` mismatch on the join key (§0.2).
- **Rev 2.2 (2026-08-26), confirmed live: `department_id` is not the only path to "projects in a department," and it disagrees with the other one.** For group 95 (BFS): `tbl_projects.department_id = 95` matches **533** projects; `tbl_group_projects.group_id = 95` (the portfolio junction, §C) matches **613**. Both are real, non-trivial populations — this is not a data error on either side, it's two legitimate, overlapping-but-not-identical definitions of departmental membership, structurally the same ambiguity as C-06 ("My Projects"). A query answering "which projects belong to department X" must pick one explicitly:
  ```sql
  -- Path 1: direct FK (what C-05 confirmed)
  SELECT p.project_id FROM tbl_projects p
  JOIN tbl_groups g ON p.department_id = g.group_id AND g.status = 1
  WHERE g.name = :department_name AND p.status = 1 AND p.archive = 0;

  -- Path 2: portfolio junction (more inclusive — also catches projects placed
  -- in the department's portfolio without department_id being set to match)
  SELECT gp.project_id FROM tbl_group_projects gp
  JOIN tbl_groups g ON gp.group_id = g.group_id AND g.status = 1
  WHERE g.name = :department_name AND gp.project_id <> 0;   -- filter the project_id=0 sentinel row
  ```
  Note `tbl_group_projects` can contain a `project_id = 0` sentinel/placeholder row per group — filter it out or it inflates any `COUNT(DISTINCT project_id)` by one.
- **Rev 2.3 (2026-08-27), RESOLVED per developer clarification: Path 2 (`tbl_group_projects`) is authoritative.** The ambiguity above is settled, not just flagged — for "which projects belong to department X," use the portfolio-junction join, not the direct `department_id` FK. **This supersedes C-05's original SQL** (which used the direct-FK join); C-05's identification of `tbl_groups`/`department` as the department entity itself still stands, only the *membership* join changes. Every query in the workbook using the direct-FK path for project-department membership has been rewritten to use `tbl_group_projects` instead (see `PMS Questions and Query - Sheet1.csv` and `CLAUDE.md`).
- **Rev 2.2, confirmed live: the allocation date-range filter silently drops real rows.** A "utilization for department X in period Y" query filtering `pu.allocation_from <= :period_end AND pu.allocation_to >= :period_start` returned **zero rows** for BFS despite 533–613 real projects and hundreds of active allocations existing. Removing only the date filter (same joins, same department, same `pu.status=1 AND pu.request_status='A'` gates) produced 236 users / 533 projects / 25,265 hours. This confirms, with live evidence rather than just the code-reading in §B.3, that a large share of `tbl_project_users.allocation_from`/`allocation_to` fail the range comparison. **Rev 2.3 (2026-08-27), RESOLVED per developer clarification: these columns are not populated in this PMS instance at all — not a partial NULL-rate issue, the feature isn't in use.** Every workbook query needing only *current* allocation state now drops the date filter and reports the present snapshot; every query that inherently requires a real date (ending/starting "in the next N days," forecast utilization, allocation-vs-deadline gap) is reclassified `Blocked - Data Not Available` — not a bug to fix, just unanswerable from this data.
- **Careful:** `p.department_id` is `NOT NULL` with no default, so unset rows are `0`, not NULL — the LEFT JOIN yields NULLs for them either way, but `COUNT(p.department_id)` will count them.

#### `tbl_user_company` — user ↔ company junction (multi-company membership)
- `id` (PK), `user_id`, `company_id`, `post_date`, `update_date`, `status`. Written by the MIS resource sync.

#### `tbl_user_skills` / `tbl_master_skills`
- `tbl_user_skills`: `id` (PK), `user_id`, **`project_id`**, `skill_id` FK→`tbl_master_skills.id`, `status`, `created_at`, `updated_at`. Note skills are recorded **per project**, not globally per user.
- `tbl_master_skills`: `id` (PK), `name`, `status`.

#### B.1.4 The MIS sync path — how `tbl_users`, `tbl_projects`, `tbl_clients`, `tbl_project_users` are actually populated

`source/application/modules/Api/` (legacy, **not** the Slim API) ingests master data from the upstream MIS. `Api_model.php` loads exactly: `users`, `group_users`, `clients`, `projects`, `group_projects`, `project_users`, `user_skills`, `user_company`, `test_api_data`.

| Endpoint (`Api/index.php`) | Writes to |
|---|---|
| `resourceSynch` / `resourceSynchCsv` | `tbl_users`, `tbl_user_skills`, `tbl_user_company`, `tbl_group_users` |
| `clientSynch` / `clientSynchCsv` | `tbl_clients` |
| `projectSynch` / `projectSynchCsv` | `tbl_projects`, `tbl_group_projects`, default document folders |
| `resourceAllocSynch` / `resourceAllocSynchInit` | `tbl_project_users` (allocation rows) |
| `taskSync` | `tbl_project_tasks` |

Matching keys are **business keys, not surrogate ids**: users match on `email`, projects on `project_unique_id`, clients on `client_id`. Upsert logic is "select, then update-or-insert" (`updateData`, `updateProject`, `updateClient`), so duplicates are possible where the business key is null or reused.

#### `tbl_clients`
- `id int` (PK, autoinc), **`client_id varchar(255)`** (the MIS business key), `client_name`, `business_name`, `poc_name`, `poc_email`, `poc_phone_no`, `status tinyint(1) DEFAULT 1`, `created_date date`, `update_date datetime`.
- **Gotcha, sharpened in rev 2:** `tbl_clients` has *two* id columns, and the types now argue against rev 1's reading. `tbl_projects.client_id` is **`int`**, while `tbl_clients.client_id` is **`varchar(255)`** and `tbl_clients.id` is `int`. An `int` FK pointing at a `varchar` business key would work only by implicit cast and would break on any non-numeric client code. **Treat the join target as unresolved**: check both
  ```sql
  SELECT COUNT(*) FROM tbl_projects p JOIN tbl_clients c ON c.id        = p.client_id;
  SELECT COUNT(*) FROM tbl_projects p JOIN tbl_clients c ON c.client_id = p.client_id;
  ```
  and use whichever matches the project count. Until that is run, do not report client names off `tbl_projects`.

#### Session & audit: `tbl_sessions`, `tbl_login_history`, `tbl_login_attempts`, `tbl_password_histories`, `tbl_user_account_history`, `tbl_user_journey`
- `tbl_sessions`: `id`, `data`, `expires` — PHP session store. High-churn, not a reporting table.
- `tbl_login_history`: `session_id`, `user_id`, `post_ip`, `browser`, `login_time`, `logout_time`, `platform_*`. Use for login/usage reporting.

---

### B.2 Groups — the portfolio / department layer

#### `tbl_groups`
- **Functionality:** the container above projects. Depending on deployment it represents a department, a delivery unit, or a client portfolio. Also still serves the Layer-1 social "group" feature.
- **Managed by:** `Group` (`Group_model.php`, 183 KB); read by `Dashboard`, `Project`, `File`, `Qa`, `Rt`, `Search`, `Bulletin`, `Home`, `Record`, `Users`, `Locations`, `Ip`, `Subscription`, `Wordfilter`.
- **Key fields:** `group_id` (PK), `owner_id` FK→`tbl_users`, `activity_id`, `company_id`, `group_type_id`, `name`, `description`, `short_url`, `settings`, **`status`**, **`group_status`**, `group_privacy`, `request_join`, **`archive`**, `search_status`, `post_date`, `update_date`.
- **Gotcha:** `status` **and** `group_status` **and** `archive` are three separate flags. `status` is the soft-delete; `archive` hides from active listings; `group_status` is a workflow state. Filter all three deliberately.

#### `tbl_group_projects` — **the critical junction**
- Exactly two columns: `group_id int`, `project_id int`. No surrogate key, no status, no timestamps.
- This is how a project is placed in a portfolio, and it appears in **44** load sites — the second-most-used junction in the system.
- **There is no UNIQUE constraint** — four overlapping non-unique indexes (`TGP_indexing`, `idx_tgp_project`, `idx_tgp_group`, `idx_project_group`) and nothing else. So **duplicate `(group_id, project_id)` rows are physically possible**, and any join through this table can fan out and double-count. If a project count comes out higher than expected, check `SELECT group_id, project_id, COUNT(*) FROM tbl_group_projects GROUP BY 1,2 HAVING COUNT(*) > 1` before anything else. Rev 1 flagged multi-group membership but not duplicate rows.
- Both columns are `int` while their targets are `bigint` (§0.2).
- **Nothing prevents a project from belonging to multiple groups, and nothing prevents an orphan project** (a `tbl_projects` row with no `tbl_group_projects` row). Dashboard queries defend against this with `WHERE pg.project_id IS NOT NULL` after a LEFT JOIN. Decide explicitly whether your query should use INNER (portfolio-scoped) or LEFT (all projects).

#### `tbl_group_users` — group membership
- `group_id`, `user_id`, `role_id` FK→`tbl_roles`, `access_type enum('NORMAL','ADMIN') DEFAULT 'NORMAL'`, **`request_status enum('A','R','I') DEFAULT NULL`**, `post_date`, `update_date`, `post_ip`.
- **`request_status` letters mean something different here than in `tbl_project_users`** — the column comments are explicit and they disagree:
  | Table | Enum order | `'R'` means |
  |---|---|---|
  | `tbl_group_users` | `('A','R','I')` | **Request(ed)** — "A = approve, R = Request, I = Invited" |
  | `tbl_project_users` | `('A','I','R')` | **Rejected** — "A => Accepted, I => Invited, R => Rejected" |
  Rev 1 wrote "requested/rejected" for both. Do not write a query that treats `'R'` uniformly across the two tables, and never compare either column to a number (§D.10).
- **`request_status` is NULLABLE with `DEFAULT NULL` here**, so `request_status = 'A'` silently drops rows where it was never set. If group membership counts look low, count the NULLs first.
- **Note:** unlike `tbl_project_users`, this table has **no `status` column** — `request_status` is the only membership gate.
- **Trigger:** `group_user_insert` / `_update` / `_delete` maintain the `tbl_site_search.info1` member counter for `stype = '3'`, incrementing only when `request_status = 'A'`. That counter is trigger-derived and will be wrong for rows inserted with a NULL status and approved later by a path the trigger does not cover.

#### `tbl_group_role`, `tbl_group_types`(+`_desc`), `tbl_group_domain`, `tbl_group_topics`, `tbl_group_files`, `tbl_group_release`, `tbl_group_task_income_var`
- `tbl_group_role`: `group_id`, `role_id`, `access_permission` — per-group permission overrides.
- `tbl_group_topics`: `group_topic_id` (PK), `user_id`, `group_id`, `activity_id`, `title`, `description`, `reference_no`, `status`, `search_status` — discussion topics at group level (mirrors `tbl_project_topics`).
- `tbl_group_release`: group-level release register, same shape as `tbl_project_release` but keyed on `group_id`.

---

### B.3 Projects — the core entity

#### `tbl_projects`
- **Managed by:** `Project` (`Project_model.php`); read by `Dashboard`, `Group`, `Task`, `Risk`, `Rca`, `Release`, `Rt`, `Estimation`, `Infrastructure`, `Requirements`, `Lineitem`, `Record`, `Tview`, `Profile`, `Users`, `Subscription`, `Api`.
- **Full column list** (order as declared):
  `project_id` (PK), `parent_id`, `activity_id`, `client_id`, `project_unique_id`, `master_project_id`, `pm_user_id`, `requestor_email`, `project_type`, `business_model`, `title`, `description`, `short_url`, `project_key`, `project_parent_type_id`, `project_type_id`, `subscription_id`, `start_date`, `end_date`, `project_status_id`, `project_stage_id`, `priority`, `rag`, `company_id`, `department_id`, `team_id`, `project_owner_id`, `sponsor`, `post_date`, `update_date`, `post_ip`, `status`, `due_notification`, `settings`, `reference_no`, `archive`, `change_owner`, `estimate`, `total_hours_booked`, `total_chargable_hours`, `combined_hours`, `grant_hours`, `is_approved`, `search_status`, `category_type`, `deal_type`, `business_type`, `deal_value`, `complience_report`, `project_duration`, `overall_score`, `pm_note`, `audit_status`, `discovery_phase`, `project_initiation`, `project_execution`, `project_closure`, `updated_by`, `merge_comment`.
- **Rev 2 corrections to that list:** the dump shows **60 columns**, not 57. Missing from rev 1: **`source enum('I','T','P','V')`** (tenant of origin: INT / Techshu / Prime / VLoka) — sits between `updated_by` and `merge_comment`. Physical order of the hours block is `estimate, total_hours_booked, total_chargable_hours, grant_hours, combined_hours` (rev 1 transposed the last two). Confirmed enums: `project_type enum('Internal','Business','eGov','Billing On Actual','Presale') DEFAULT 'Business'`, `category_type enum('high','simple','complex','medium')`, `audit_status enum('review','pending','confirm')`. `priority` **is** a plain `int`; `rag` is `varchar(20)`. `project_id` is `bigint AUTO_INCREMENT`; most FK columns are `int`.
- **Confirmed absent: `attention_required`.** It is not on `tbl_projects` in the dump — only on `tbl_project_tasks`, `tbl_project_issues`, `tbl_pms_issues`, `tbl_rt_support`. Any executive-attention indicator built on `tbl_projects.attention_required` must be dropped (this is what O-15 concluded from code; the schema confirms it).
- **Key FKs:** `client_id`→`tbl_clients` (**target column unresolved — see §B.1**); `company_id`→`tbl_companies`; `project_status_id`→`tbl_project_status.status_id`; `project_stage_id`→`tbl_project_stages.stage_id`; `project_type_id`→`tbl_project_types`; `pm_user_id`/`project_owner_id`→`tbl_users`; `activity_id`→`tbl_activities`; `parent_id`/`master_project_id`→ self; **`department_id`→`tbl_groups.group_id`** (developer-confirmed, C-05 — *not* `tbl_project_department`, which is empty); `team_id`→`tbl_project_team`, which is **empty**, so `team_id` currently resolves to nothing.
- **Indexes (all non-unique except the PK):** `PRIMARY(project_id)`, `idx_projects_archive(project_id, archive, short_url, project_owner_id)`, `idx_project_id`, `idx_project_unique_id`, `idx_tp_archive(archive)`, `idx_project_master(master_project_id)`, `idx_project_parent(parent_id)`, `idx_archive_project(project_id, archive)`. **There is no unique index on `title` and none on `project_unique_id`** — which answers O-07: **project titles are not unique, and neither is the MIS business key**. Any question that identifies a project by title must expect multiple hits, and the MIS upsert (§B.1.4) can produce duplicate `project_unique_id` rows because nothing at the schema level stops it.
- **Observed JOIN patterns** (from `Project_model.php` / `Dashboard_model.php`):
  ```sql
  tbl_projects p
    LEFT  JOIN tbl_group_projects gp ON p.project_id = gp.project_id
    LEFT  JOIN tbl_groups g          ON gp.group_id  = g.group_id
    INNER JOIN tbl_project_users pu  ON p.project_id = pu.project_id
    LEFT  JOIN tbl_project_status  ps ON p.project_status_id = ps.status_id
    LEFT  JOIN tbl_project_stages psg ON p.project_stage_id  = psg.stage_id
  ```
- **Cached rollups:** `total_hours_booked`, `total_chargable_hours`, `combined_hours` are **denormalised aggregates** maintained by application code. They can drift from `SUM(tbl_timesheets.hours)`. For anything auditable, aggregate the timesheet table; use the rollups only for fast dashboards.

#### `tbl_project_users` — **allocation junction, and the most error-prone table in the schema**
- `project_id`, `user_id`, `access_type enum('ADMIN','PARTICIPANT','SUBSCRIBER') DEFAULT 'PARTICIPANT'`, `role_id` FK→`tbl_roles`, `allocation_from date`, `allocation_to date`, **`allocation_hrs decimal(9,2) NOT NULL DEFAULT 0.00`**, `resource_type enum('D','P','S') DEFAULT 'P'` (D=Dedicated, P=Part-Time, S=Support), **`request_status enum('A','I','R')`** (A=Accepted, I=Invited, R=**Rejected**), `post_ip`, `post_date`, `update_date`, **`status tinyint(1) NOT NULL DEFAULT 1`**.
- **`UNIQUE KEY project_user (project_id, user_id)`** — rev 2 addition, and it matters: **a person can have at most one row per project.** There is no allocation history in this table; a re-allocation overwrites `allocation_from`/`allocation_to`/`allocation_hrs` in place, and the only trail is `tbl_project_users_log`. So "who was allocated to project X in Q1" **cannot** be answered from this table — only "who is allocated now". The second index `idx_project_request_status (project_id, request_status, status, user_id)` already exists in the dump, which covers the two-gate filter below.
- **`resource_type` is the closest thing in the schema to a part-time marker** (O-12 asked for an FTE field: there is none, but `resource_type = 'P'` distinguishes part-time from dedicated). It is a category, not a fraction — it cannot substitute for FTE in a capacity calculation.
- **Two independent gates.** `request_status = 'A'` means the membership was approved. `status = 1` means the resource is *currently allocated*. **A de-allocated resource keeps `request_status = 'A'` and gets `status = 0`.**
- This was only fixed on **2026-07-02** (commit `40153d55` "Deallocated resource should not access the project"), and the fix was applied to just a handful of call sites. In `Project_model.php` today: **30 references filter `request_status`, only 8 also filter `status`.** Any query you write must include **both**:
  ```sql
  WHERE pu.request_status = 'A' AND pu.status = 1
  ```
  Queries copied from older code paths will silently include de-allocated people.
- `allocation_hrs` is **hours (DECIMAL(9,2)), not a percentage**, with no cap and no mandatory validation (the validation is commented out at `Project/index.php:9748`). The MIS sync writes `NULL`/`0.00` in three of its four paths — so allocation-based utilisation KPIs will under-report. *(Code-confirmed 2026-08-12; see `.claude/notes/2026-08-12-pms-poc-38-item-decisions.md`.)*

#### `tbl_project_status` / `tbl_project_stages` — **per-project-type lookups, not global**
- `tbl_project_status`: `status_id` (PK), `group_id`, `color_code`, **`project_type_id`**, `status_name`, `status_order`, `status`.
- `tbl_project_stages`: `stage_id` (PK), `group_id`, `color_code`, **`project_type_id`**, `stage_name`, `status_order`, `status`.
- **Gotcha:** both are scoped by `project_type_id` *and* `group_id`. The same human-readable status name can exist several times with different `status_id`s. Code joins them as `PT.project_type_id = PS.project_type_id`. **Never hardcode a `project_status_id`** — resolve by `(project_type_id, status_name)` or by `status_order`.

#### Project satellites
| Table | Purpose | Key fields |
|---|---|---|
| `tbl_project_types` | project type lookup | `project_type_id` (PK), `parent_type_id`, `group_id`, `project_type`, `status` |
| `tbl_project_priority` | priority lookup **per project type** — **EMPTY**, so `tbl_projects.priority` is definitively not an FK into it; use the PHP label map in §D.3 (settles O-05) | `priority_id`, `project_type_id`, `priority_name`, `priority_order`, `status` |
| `tbl_project_topics` | discussion topics on a project | `project_topic_id` (PK), `user_id`, `project_id`, `activity_id`, `title`, `reference_no`, `status`, `search_status` |
| `tbl_project_sponsors` | project ↔ sponsor junction — **EMPTY**; `tbl_projects.sponsor` (int) is the only sponsor data | `project_id`, `sponsor_id`, `post_date` |
| `tbl_project_status_history` | status change audit — **EMPTY**. There is **no project-status history anywhere**; project status trend questions are unanswerable | `id`, `project_id`, `status_id`, `activity_id`, `user_id`, `post_date` |
| `tbl_project_users_log` | allocation change audit — **non-empty, and the only allocation history that exists** (see the UNIQUE key above) | `id`, `project_id`, `user_id`, `action_by`, `action_mode`, `created_at` |
| `tbl_project_executive_summary` | weekly PM exec summary | `executive_id`, `project_id`, `group_id`, `user_id`, `summary`, `stage`, `client_mood`, `live_issues`, `dev_issues`, `resource`, `dev`, `test`, `issues`, `risks`, `pm`, `post_date`, `save_date` |
| `tbl_project_audit_fields` | configurable audit checklist | — |
| `tbl_project_initiation_records` / `_areas` / `_check_points` | project initiation checklist | — |
| `tbl_project_impact` | impact lookup (shared with issues) | `impact_id`, `impact_name`, `status` |
| `tbl_notes`, `tbl_save_search` | PM notes; saved filter sets | `tbl_save_search`: `search_id`, `user_id`, `type`, `main_type`, `main_type_id`, `search_parameter` (JSON) |

---

### B.4 Tasks

#### `tbl_project_tasks`
- **Managed by:** `Project` (**not** `Task` — see §A); also `Dashboard`, `Group`, `Release`, `Risk`, `Task`.
- **Full column list:** `task_id` (PK), `parent_id`, `activity_id`, `task_owner`, `project_id`, `type_id`, `title`, `description`, `comments`, `start_date`, `due_date`, `post_date`, `task_status_id`, `release_id`, `priority`, `chargeable`, `invoice`, `invoice_date`, `requirement_complete`, `released`, `ignore_report`, `ignore_release_note`, `ref_task_id`, `rag`, `update_date`, `last_updated_by`, `post_ip`, `reference_no`, `release_reference_no`, `estimate`, `estimate_complete`, `actual_hours`, `percent_complete`, `comment`, `release_note`, `bespoke_item`, `bespoke_code`, `reference_type`, `reference_id`, `status`, `archive`, `search_status`, `client_reference`, `client_sequence`, **`attention_required`**, `size`, `dependent_task_id`.
- **Hierarchy:** `parent_id` → self. Sub-tasks are rows in the same table. Code aliases the parent as `` `master_task` ``:
  `LEFT JOIN tbl_project_tasks AS master_task ON master_task.task_id = pt.parent_id`.
- **Observed JOIN patterns:**
  ```sql
  tbl_project_tasks t
    LEFT JOIN tbl_project_task_status pts ON t.task_status_id = pts.task_status_id
    LEFT JOIN tbl_project_task_users ptu  ON t.task_id    = ptu.task_id
    LEFT JOIN tbl_group_projects gp       ON t.project_id = gp.project_id
    LEFT JOIN tbl_task_release tr         ON t.task_id    = tr.task_id
    LEFT JOIN tbl_project_release pr      ON tr.release_id = pr.release_id
    LEFT JOIN tbl_timesheets ts           ON t.task_id    = ts.task_id
    RIGHT JOIN tbl_projects p             ON t.project_id = p.project_id
  ```
- **`attention_required` is a delimited string, not an id.** It is matched with `LIKE '%u::<user_id>%'` for a user and `LIKE '%r::<role_id>%'` for a role (see `Task_model::getAttentionRequiredTask`). It lives on **`tbl_project_tasks`, not `tbl_projects`**.
- **`ignore_report` / `ignore_release_note` / `chargeable` are CHAR `'Y'`/`'N'`, not 0/1.** The bulk-update path also uses a sentinel `'YN'` meaning "leave unchanged".
  Precisely: `chargeable`, `invoice`, `requirement_complete`, `released`, `ignore_report`, `ignore_release_note`, `bespoke_item` are all `enum('Y','N') NOT NULL DEFAULT 'N'`. Because they are ENUMs, `WHERE chargeable = 1` matches `'Y'` only by accident of ordinal (`'Y'` is ordinal 1) — quote them (§D.10).

##### Rev 2 corrections to `tbl_project_tasks`

1. **`priority` is `enum('High','Medium','Low','Default','In Staging') DEFAULT NULL` — a string, not an integer.** This invalidates rev 1's `0=High, 1=Low, 2=Medium` mapping as a *storage* description; that triple is the PHP display array at `Task/index.php:2541`, and its order does not even match the ENUM's. Consequences:
   - Filter with strings: `WHERE pt.priority = 'High'`. Never `priority = 0` — for a MySQL ENUM that is the invalid-value ordinal and matches nothing (or the `''` error value).
   - **There are five levels, not three.** `'Default'` and `'In Staging'` exist in the schema and are absent from the PHP array, so the UI cannot render them — expect rows the app displays blank. Get the real distribution before defining a priority KPI: `SELECT priority, COUNT(*) FROM tbl_project_tasks WHERE status = 1 GROUP BY priority;`
   - `NULL` is allowed and is the default, so `priority <> 'High'` drops the NULL rows.
2. **`actual_hours` is `tinyint NOT NULL`** — maximum 127. A denormalised effort column that physically cannot hold a realistic task total. Treat it as unusable and always aggregate `tbl_timesheets` (§D.5 already said prefer the aggregate; the column type makes it mandatory).
3. **Two columns rev 1 did not list:** `parent_project_id bigint DEFAULT NULL` (a second, wider parent-project pointer alongside `project_id int` — check which is populated before using it) and `acceptance_criteria longtext`.
4. `estimate` and `estimate_complete` are `float(11,…)`, `percent_complete` is `float NOT NULL DEFAULT 0`, `status` is `int DEFAULT 1`, `archive` is `tinyint DEFAULT 0`, `attention_required` is `varchar(100) DEFAULT NULL`. All four columns O-08 asks about exist and are typed as expected.
5. **No search trigger on this table** — unlike `tbl_projects`, `tbl_project_issues`, `tbl_project_topics`, `tbl_group_topics` and `tbl_comments`, `tbl_project_tasks` has no `*_search_update`/`_delete` trigger. `search_status` on tasks is maintained by application code only (§D.9).
6. **Indexes present** (relevant to §D.7): `idx_tasks_status_parent_post(task_id, project_id, parent_id, task_status_id, post_date, status)`, `idx_only_parent(parent_id)`, `idx_date(start_date)`, `idx_project_status_task_parent(project_id, status, task_id, parent_id)`, `idx_task_project_status(project_id, …)` and more. The N+1 work's task-side indexes **are** in this dump, so rev 1's "two `ALTER TABLE`s still not applied" note is stale for at least the task and task-user tables — re-verify against the live server rather than trusting either statement.

#### `tbl_project_task_status`
- `task_status_id int UNSIGNED` (PK), **`project_id int UNSIGNED DEFAULT 0`**, `status_name varchar(255)`, `color_code`, **`status_type mediumint NOT NULL DEFAULT 0`**, `status_order`, `status`, `post_date`, `update_date`, `post_ip`.
- **`status_type` is the stable semantic axis — and it has SIX values here, not three.** The column comment in the dump is authoritative:
  ```
  1 => New, 2 => In Progress, 3 => Closed, 4 => UAT, 5 => Abandoned, 6 => Reopened
  ```
  Rev 1 documented only 1/2/3. This matters directly for the "open tasks" definition (C-03 answered `status_type != 3` for **issues**, where 1/2/3 is the whole vocabulary):
  - For **tasks**, `status_type != 3` sweeps in **5 = Abandoned**, which is not open work. Use `status_type IN (1, 2, 4, 6)` for open-and-active, and decide explicitly whether UAT (4) counts as open.
  - `DEFAULT 0` means a status row can exist with `status_type = 0` — unmapped. `status_type != 3` also catches those.
  - `status_name` and `task_status_id` are configurable per deployment; `status_type` is not. Used in ~41 places in `Project_model.php`. Resolver: `getProjectTaskStatusIdByType($project_id, $status_type)` (`Project_model.php:11139`).
- **Global vs per-project statuses:** with `GLOBAL_PROJECT_STATUS = true` (which is set in **all** site configs), the resolver forces `project_id = 0`. So the live status rows are the **global rows with `project_id = 0`**, and per-project rows (`project_id > 0`) are legacy. Filter accordingly:
  ```sql
  WHERE pts.project_id = 0 AND pts.status_type = 3   -- completed
  ```

#### `tbl_project_task_users`
- `task_id`, `user_id`, `allot_percentage`, **`status`**, `post_date`. Assignment junction; active rows are `status = 1`. Re-assigning a previously removed user **updates the existing row back to `status = 1`** rather than inserting (`Task_model::updateTaskUsers`), so there is at most one row per (task, user).

#### Task satellites
| Table | Purpose | Key fields |
|---|---|---|
| `tbl_project_task_types` | task type lookup | `type_id`, `type_name`, `display_order`, `status` |
| `tbl_tasktype` | *second*, newer task-type lookup | `id`, `task_type_name`, `status`, `created_date` |
| `tbl_project_tasks_history` | status-change history | `task_id`, `user_id`, `activity_id`, `task_status`, `task_status_id`, `post_date` |
| `tbl_task_date_history` | start/due date changes | `history_id`, `user_id`, `task_id`, `start_date`, `due_date`, `post_date` |
| `tbl_project_tasks_move_history` | task moved between projects | `task_id`, `user_id`, `activity_id`, `previous_project_id`, `present_project_id`, `post_date` |
| `tbl_project_tasks_audit_trails` | generic field-level audit | `id`, `project_id`, `task_id`, `user_id`, `type`, `type_value`, `post_date` |
| `tbl_project_tasks_chargeable_logs` | chargeability changes | — |
| `tbl_project_task_comment_users` | @-mention junction on task comments | `id`, `task_id`, `comment_id`, `user_id`, `status`, `post_date` |
| `tbl_project_task_dependent_comment` | dependency commentary | — |
| `tbl_project_task_milestone` / `_mapping` | milestones ↔ tasks | `milestone_id`, `milestone`, `start_date`, `end_date` / `milestone_id`, `project_id`, `task_id`, `task_start_date`, `task_end_date` |
| `tbl_task_insights` | precomputed task metrics | `id`, `group_id`, `project_id`, `task_id`, `bugs`, `issues`, `reopened`, `effort_variance`, `schedule_variance`, `bugs_values`, `update_date` |

#### TView — configurable task list views (`Tview` module)
- `tbl_tview_list`: `list_id`, `list_name`, `list_type` (`'P'` project / `'G'` group), `list_type_id`, `callback_params`, `show`, `user_id`.
- `tbl_tview_list_settings`: `setting_id`, `list_type`, `list_type_id`, `settings` (**JSON**), `user_id`.
- `tbl_tview_saved_search`: `save_search_id`, `user_id`, `list_type`, `list_type_id`, `saved_search` (JSON), `post_date`.
- `tbl_tview_release_settings`: release-view configuration.
- **`list_type_id = 0` means "applies to all"** — the list query is `list_type_id = 0 OR list_type_id = <id>`.

---

### B.5 Issues — **two independent registers, do not conflate them**

#### B.5.1 `tbl_project_issues` — the project issue/defect tracker (`Issue` + `Project` modules)
- **Full column list:** `issue_id` (PK), `activity_id`, `project_id`, `user_id`, `type_id`, `title`, `description`, `impact_id`, `date_raised`, `date_closed`, `issue_status_id`, `update_date`, `post_ip`, `reference_no`, `status`, `search_status`, `task_reference`, `client_reference`, `attention_required`, `external_defect_id`, `defect_origination_phase`, `defect_detection_phase`, **`severity`**, **`priority`**, `impact`, `external_defect`, `planned_closure_date`, `overdue_status`, `rca`, `correction`, `corrective_action`.
- **Note there is no `due_date`** — the closure target is `planned_closure_date`, and the raise timestamp is `date_raised` (not `post_date`). Order-by clauses in code use `date_raised DESC`.
- **JOINs:**
  ```sql
  tbl_project_issues pi
    LEFT  JOIN tbl_project_issue_status pis ON pi.issue_status_id = pis.issue_status_id
    LEFT  JOIN tbl_project_issue_users piu  ON pi.issue_id   = piu.issue_id
    LEFT  JOIN tbl_group_projects gp        ON pi.project_id = gp.project_id
    LEFT  JOIN tbl_project_impact           ON pi.impact_id  = impact_id
    RIGHT JOIN tbl_projects p               ON pi.project_id = p.project_id
    INNER JOIN tbl_project_issue_comment_users piu2 ON piu2.issue_id = pi.issue_id
  ```
- `tbl_project_issue_status`: `issue_status_id int UNSIGNED` (PK), `project_id int UNSIGNED DEFAULT 0`, `status_name`, `color_code`, **`status_type smallint NOT NULL DEFAULT 0`**, `status_order`, `status`. The column comment is **`1 => New, 2 => In Progress, 3 => Closed`** — only three values, unlike the task table's six. So **`status_type != 3` is a safe "open issue" filter here** (as the developer answered in C-03), with the one caveat that `DEFAULT 0` rows would also be swept in. Same `GLOBAL_PROJECT_STATUS → project_id = 0` rule as task status. Resolver: `getProjectIssueStatusIdByType()`.
- `tbl_project_issue_users`: `issue_id`, `user_id`, `status`, `post_date`.
- `tbl_project_issue_comment_users`: `id`, `issue_id`, `comment_id`, `user_id`, `status`, `post_date`.
- `tbl_project_issue_types`: `type_id`, `type_name`, `display_order`, `status`.
- History: `tbl_project_issue_history` (`issue_id`, `user_id`, `activity_id`, `issue_status`, `issue_status_id`, `post_date`), `tbl_project_issue_impact_history`, `tbl_project_issue_move_history`, `tbl_project_issue_views`.

#### B.5.2 `tbl_pms_issues` — the PMS-level issue register (`Issuepms` module)
- A **separate, parallel** issue system with its own status/type/user/audit tables. `Issuepms/index.php` is 1 670 lines, so this is live code, not dead weight.
- **Columns:** `issue_id` (PK), `activity_id`, **`group_id`**, `project_id`, `user_id`, `title`, `description`, `date_raised`, `date_closed`, `issue_status_id`, `update_date`, `post_ip`, `status`, `attention_required`, `date_analyzed`, `analysis_plan`, `estimated_effort`, `estimated_duration`, `estimated_cost`, `planned_resolution_date`, `issue_type_id`, `action_taken`, `actual_effort`, `actual_cost`, `remarks`, `date_resolved`, `reject_details`, `isvalid`.
- Distinctive shape: it carries **estimate vs actual effort/cost** and an analysis phase — it is a management issue register, whereas `tbl_project_issues` is a defect tracker.
- Satellites: `tbl_pms_issue_status`, `tbl_pms_issue_types`, `tbl_pms_issue_users`, `tbl_pms_issue_audit_trails` — all non-empty. **`tbl_pms_issue_comment_users` does not exist** (rev 1 named it, including in §C; it is not in the 306-table schema).
- **`tbl_pms_issue_status` has no `project_id`** — it is genuinely global, unlike `tbl_project_issue_status`. Columns: `status_id`, `status_name`, `color_code`, `status_order`, **`status_type mediumint`**, `post_date`, `post_ip`, `update_date`, `status`.
- **Its `status_type` vocabulary is `1 => Open, 2 => Closed` — two values, not three.** Rev 1 claimed "same `status_type` 1/2/3 semantics"; that is wrong. **`status_type = 3` matches nothing here, so a closed-PMS-issue filter written as `= 3` returns zero rows and a "no closed issues" answer that looks plausible.** Closed is `status_type = 2`.
- `tbl_pms_issues` columns are mostly NULLable (`activity_id`, `date_raised`, `date_closed`, `planned_resolution_date`, `date_resolved`, `issue_type_id`) unlike `tbl_project_issues`, where the equivalents are `NOT NULL` and use zero-dates instead. Date predicates must handle both idioms (§D.6). `estimated_effort`/`estimated_cost`/`actual_effort`/`actual_cost` are **`varchar(255)`, not numeric** — they need casting and will contain free text.
- Note `Issuepms_model` also writes `tbl_project_issue_history` and `tbl_project_tasks_audit_trails` — the two registers share some history tables. Filter by the id space you actually mean.
- Also referenced by the `Ehs` module.

---

### B.6 Time Tracking & To-Dos

#### `tbl_timesheets`
- **Columns:** `timesheet_id` (PK), **`todo_id`** FK→`tbl_todo_list`, `task_id` FK→`tbl_project_tasks`, `user_id`, `project_task_type_id`, `timesheet_date`, **`hours`**, **`minutes`**, `note`, `post_ip`, `post_date`.
- **Managed by:** `Project`, `Group`, `Dashboard`. 42 load sites.
- **Gotchas:**
  - Effort is split across **two columns**: `hours` *and* `minutes`. Total effort is `SUM(hours) + SUM(minutes)/60` — not `SUM(hours)`. Check actual data before assuming `minutes` is always 0.
  - **There is no `status` column** — timesheet rows are hard-deleted, so there is no soft-delete filter to apply here.
  - Entries can arrive via a to-do (`todo_id`) or directly against a task (`task_id`). Rows where `task_id = 0`/NULL will vanish from task-joined reports; join through `tbl_todo_list` to catch them.
  - `timesheet_date` (the day worked) differs from `post_date` (when it was entered). Period reporting must use `timesheet_date`.
- **Observed JOIN:**
  ```sql
  tbl_timesheets ts
    INNER JOIN tbl_project_tasks pt ON ts.task_id = pt.task_id
    INNER JOIN tbl_projects p       ON p.project_id = pt.project_id
    LEFT  JOIN tbl_todo_list t      ON ts.todo_id = t.todo_id
  ```
- ~~`view_timesheet_report` is a DB view over this join — prefer it where it exists.~~ **Rev 2: `view_timesheet_report` does not exist in `engagedb`.** The only view in the database is `view_project_tasks_combined`. Write the join out (§B.14).
- Rev 2 type confirmations: `hours int NOT NULL DEFAULT 0`, `minutes int NOT NULL DEFAULT 0` — both integers, so `SUM(hours) + SUM(minutes)/60` is exact, and nothing constrains `minutes` to < 60. `task_id int NOT NULL DEFAULT 0` (never NULL — test `task_id = 0`, not `IS NULL`), `todo_id int NOT NULL`, `timesheet_date date` (no time component). Indexes: `PRIMARY(timesheet_id)`, `taskID(task_id)`, `todoID(todo_id)`, `idx_user_date_todo(user_id, timesheet_date, todo_id)` — a per-user/per-period aggregate is well covered; a per-**project** aggregate is not, and must reach through `tbl_project_tasks`.

#### `tbl_todo_list` / `tbl_sub_todo_list`
- `tbl_todo_list`: `todo_id` (PK), `user_id`, `task_id`, `title`, `activity_id`, `note`, `original_file_name`, `rename_file_name`, `start_date`, `due_date`, `post_date`, `update_date`, `post_ip`, `status`, **`is_completed`**, `completion_date`.
- `tbl_sub_todo_list`: `subtodo_id` (PK), `todo_id`, `title`, `user_id`, `note`, `sort_order`, `start_date`, `end_date`, `status`, **`done`**.
- **Two different completion flags:** `is_completed` on todos, `done` on sub-todos. Both tables *also* have `status` (soft-delete). A "complete" filter is `status = 1 AND is_completed = 1`.
- **Rev 2: `tbl_sub_todo_list` is EMPTY** — the `done` flag has no data behind it, and sub-todos can be ignored entirely. `tbl_todo_list` is non-empty and remains the path to timesheet rows with `task_id = 0`.
- When a task's dates change, `Task_model::updateTaskInBulk` cascades `start_date`/`due_date` into `tbl_todo_list` — so todo dates mirror task dates and are not independently authoritative.

---

### B.7 Releases

| Table | Key fields | Notes |
|---|---|---|
| `tbl_project_release` | `release_id` (PK), `parent_id`, `title`, `release_note`, `release_owner`, `project_id`, `release_status_id`, `rag`, `release_date`, `status` | project-scoped releases |
| `tbl_group_release` | same shape but `group_id` instead of `project_id` | group/portfolio-scoped releases |
| `tbl_task_release` | `release_id`, `task_id` — **junction, 2 columns only** | many-to-many task ↔ release |
| `tbl_release_status` | status lookup | |
| `tbl_release_activity` | release activity log | |

- **Gotcha:** `tbl_project_tasks` *also* has its own `release_id` column **and** `release_reference_no` and a `released` flag, in parallel with the `tbl_task_release` junction. Code joins via **`tbl_task_release`**:
  ```sql
  LEFT JOIN tbl_task_release tr    ON pt.task_id    = tr.task_id
  LEFT JOIN tbl_project_release pr ON tr.release_id = pr.release_id
  LEFT JOIN tbl_group_release  gr  ON tr.release_id = gr.release_id
  ```
  Note the same `tr.release_id` is joined to **both** `tbl_project_release` and `tbl_group_release` — the two release tables share an id space by convention only. Treat `tbl_project_tasks.release_id` as unreliable/denormalised; prefer the junction.

---

### B.8 Risk — **two registers, and the names are misleading**

#### `tbl_risk` — the live risk register (`Risk` module)
- `risk_id` (PK), `activity_id`, `category_id`, `title`, `description`, `cause`, `consequence`, `controls`, `update_risk`, `action`, **`reference_no`**, `group_id`, `project_id`, `probability_id`, `impact_id`, `risk_priority_id`, `mitigation_action_plan`, `contingency_action_plan`, `action_plan_cost`, `provision_for_risk_management`, `responsibility`, `revised_probability`, `revised_impact`, `mitigation_action_taken`, **`rating`**, **`rating_color_code`**, `response_id`, `status_id`, `owner_id`, `target_closure_date`, `revised_target_closure_date`, `closure_details`, `reject_details`, `isvalid`, `process_responsibility`, `process_reason`, `transfer_thirdparty_details`, `review_date`, `date_raised`, `date_closed`, `post_date`, `post_ip`, **`after_mitigation_risk_score`**, `update_date`, `status`.
- **Risk rating = `probability_value × impact_value`**, banded **≥ 20 red / 12–19 amber / < 12 green**. This banding is hardcoded in **three separate places** in `Risk/index.php` and is *not* stored as a band — only `rating` and `rating_color_code` are persisted. Band thresholds also feed the `rating_color_code` Registry value. *(Code-confirmed 2026-08-12.)*
- Lookups: `tbl_risk_category`, `tbl_risk_probability`, `tbl_risk_impact`, `tbl_risk_priority`, `tbl_risk_response`, `tbl_risk_status`, `tbl_risk_history` — all non-empty. **Empty (do not use): `tbl_risk_action`, `tbl_risk_mitigation_actions`, `tbl_risk_update`, `tbl_opportunity`** (plus `tbl_opportunity_history`, `tbl_opportunity_tangible`). The narrative mitigation text lives in `tbl_risk.mitigation_action_plan` / `.mitigation_action_taken`, not in a satellite table.
- **`tbl_risk_status.status_type` is `1 => Open, 2 => Closed`** — two values, per the column comment. Rev 1 grouped it with the 1/2/3 tables. **A closed-risk filter must be `status_type = 2`; `= 3` returns nothing.** Note also `tbl_risk.status_id DEFAULT 1` and that `tbl_risk.status` (tinyint) is the separate soft-delete flag.
- **`isvalid` is `enum('0','1') NOT NULL DEFAULT '0'`** — a string enum. `isvalid = 1` matches the rows where the value is `'0'` (§D.10). Write `isvalid = '1'`. Same on `tbl_ehs.isvalid`.
- Rev 2 confirms the columns O-19 depends on: `rating int NOT NULL`, `after_mitigation_risk_score int DEFAULT NULL`, `revised_probability int DEFAULT 0`, `revised_impact int DEFAULT 0`. Because `after_mitigation_risk_score` is nullable and the revised inputs default to `0`, `COALESCE(after_mitigation_risk_score, rating)` is the right expression, but **`0` is a real stored value, not a null** — `COALESCE` will happily return a residual score of 0. Use `COALESCE(NULLIF(after_mitigation_risk_score, 0), rating)` if a zero residual should mean "not assessed".

#### `tbl_project_risk` — the **estimation-side, versioned** risk table
- `project_risk_id` (PK), **`version`**, `project_id`, `risk_category_id`, `source_of_risk`, `title`, `date_identified`, `priority`, `probability_of_occurrence`, `impact`, `risk_exposure`, `risk_management_strategy_id`, `mitigation_action_plan`, `contingency_action_plan`, `provision_for_risk_management`, `responsibility`, `mitigation_action`, `revised_probability`, `revised_impact`, `residual_risk_exposure`, `project_risk_status_id`, `resolution_date`, `comment`, `original_risk_score`, `after_mitigation_risk_score`, `created_by`, `created_date`.
- **Has no `reference_no` and no `status` column** — it is versioned via `version`, so a project has *multiple rows per risk*, one per version. Any query must pick the max version per logical risk or it will double-count.
- Satellites: `tbl_project_risk_status` (**empty**), `tbl_project_risk_users` (non-empty), `tbl_project_risk_audit_trails` (non-empty).
- **Rev 2: `tbl_project_risk` is EMPTY.** The whole versioning discussion above is therefore moot for querying — there is no estimation-side risk data. Its `_users` and `_audit_trails` satellites hold rows while the parent does not, which means orphaned junction data; ignore it.

> **Rule of thumb, settled:** **use `tbl_risk`.** It is the only populated risk table, which is exactly the developer's C-04 answer ("correction confirmed — `tbl_risk` is the actual table"), now corroborated by the data census. `tbl_project_risk` is not an alternative to weigh; it is empty.

---

### B.9 RCA — Root Cause Analysis (`Rca`, `Record` modules)

- `tbl_project_rca`: `rca_id` (PK), `incident_no`, `activity_id`, `project_id`, `reference_no`, `user_id`, `reported_by_type`, `reported_by`, `comments`, **`severity_level`**, `incident_date`, `rca_status_id`, `update_date`, `last_updated_by`, `post_ip`, `comment`, `status`, `archive`, `search_status`, `issue_type`, `issue_description`, `timeline`, `repeat_incident`, `advise_original_event`, `business_impact`, `troubleshooting_steps_taken`, `root_cause_analysis`, `roadblocks`, `corrective_preventive_action`, `key_takeaway`, `follow_ups`.
- Satellites, corrected in rev 2: `tbl_project_rca_status`, `tbl_project_rca_owners`, `tbl_project_rca_internal_users`, `tbl_project_rca_audit_trails`, `tbl_rca_severity` — all non-empty. **`tbl_project_rca_users` is empty** (use `_owners` / `_internal_users` for RCA people). **`tbl_rca_date_history` and `tbl_rca_team_member` do not exist** — rev 1 named both, and the claim that `tbl_rca_team_member` is shared with `Estimation`/`Infrastructure`/`Lineitem` should be disregarded.
- Note both a `comments` and a `comment` column exist — check which one is populated before relying on either.

---

### B.10 RT — Support Ticketing (`Rt` module)

- `tbl_rt_support`: `ticket_id` (PK), `activity_id`, `reference_id`, **`type`**, **`type_id`** (polymorphic subject pointer), `category_id`, **`ticket_status`**, `priority`, `posted_by`, `requestor`, `post_date`, `update_date`, `closed_date`, `merge_id`, `merge_tickets`, `status`, `search_status`, `client_reference`, `attention_required`, `client_priority`.
- **Naming trap:** the status FK is called **`ticket_status`**, not `status_id`, and it joins to `tbl_rt_status.status_id`. Meanwhile `tbl_rt_support.status` is the ordinary soft-delete flag. Getting these two confused is the easiest mistake to make in this module:
  ```sql
  LEFT JOIN tbl_rt_status rs ON rt.ticket_status = rs.status_id
  WHERE rt.status = 1          -- soft-delete gate, NOT the workflow status
  ```
- `tbl_rt_support_thread`: `thread_id` (PK), `parent_id`, `activity_id`, `ticket_id`, `mail_id`, `user_id`, `cc`, `subject`, `description`, `post_date`, `status` — threaded conversation, self-referencing via `parent_id`.
- `tbl_rt_support_owner`: `ticket_id`, `owner_id`, `status`, `post_date` — assignment junction.
- Lookups/history: `tbl_rt_status` (`status_id`, `title`, `color_code`, `status_order`, `status`), `tbl_rt_priority` (`priority_id`, `title`, `priority_order`, `default`, `status`), `tbl_rt_category`, `tbl_rt_status_history` (`history_id`, `user_id`, `ticket_id`, `status_id`, `post_date`), `tbl_rt_env_details`, `tbl_rt_file`, `tbl_rt_merge_history`, `tbl_rt_merge_thread_notification`, `tbl_rt_notifications`(+`_types`, `_types_desc`).
- **Note `tbl_rt_status.title`**, not `status_name` — the naming convention breaks here relative to every other status table.
- ~~DB views exist for this module: `view_rt_first_thread`, `view_rt_first_reply_thread`, `view_rt_latest_resolved_status`, `view_rt_owner`, `view_support_report`.~~ **Rev 2: none of those views exist in `engagedb`.** They are referenced in code but absent from the schema (see §B.14), so SLA/first-response logic has to be re-derived from `tbl_rt_support_thread` — `MIN(post_date)` per `ticket_id` for the first thread, first row with a different `user_id` than the requestor for first reply, and `tbl_rt_status_history` for the resolved timestamp.
- **`tbl_rt_support.status` is `enum('0','1') NOT NULL DEFAULT '1'` — the single most dangerous filter in this module.** `WHERE status = 1` compares against the **ordinal**, and ordinal 1 is the value `'0'`: the query returns exactly the deleted tickets. Write `WHERE status = '1'`. This is what `api/src/models/Ticket.php` gets wrong (`SELECT * FROM tbl_rt_support WHERE status = 1`), though no route is bound to it. `tbl_rt_support.type` is `varchar(50)` (P = Project, G = Group), and `ticket_status` is a plain `int` FK → `tbl_rt_status.status_id`.
- Empty in this module (do not use): **`tbl_rt_env_details`, `tbl_rt_file`**. Non-empty: `tbl_rt_status`, `tbl_rt_priority`, `tbl_rt_category`, `tbl_rt_status_history`, `tbl_rt_support_owner`, `tbl_rt_support_thread`, `tbl_rt_merge_history`, `tbl_rt_merge_thread_notification`, `tbl_rt_notifications`(+`_types`, `_types_desc`). RT attachments therefore live in `tbl_attachment`, not `tbl_rt_file`.

---

### B.11 Documents, Files & Attachments — four parallel storage tables

This is the most fragmented area of the schema. Four different tables store uploads, and they are **not** interchangeable.

| Table | Used by | Key fields |
|---|---|---|
| `tbl_attachment` | `Project`, `Task`, `Issue`, `Rt`, `Rca`, `Documents`, `Group`, `Home`, … (42 sites) | `file_id` (PK), `folder_id`, **`type`**, **`type_id`**, `activity_id`, `ori_file_name`, `sys_file_name`, `file_size`, `file_type`, `starred`, `post_date`, `update_date`, `post_ip`, **`status`**, **`deleted`** |
| `tbl_project_documents` | `Project`/`Documents` | `document_id` (PK), `project_id`, `activity_id`, `user_id`, `file_sys_name`, `file_ori_name`, `post_date`, `update_date`, `post_ip`, `status`, `visibility` |
| `tbl_files` | `File`, `Home`, `Group`, `Profile` (social-era) | `file_id` (PK), `user_id`, `activity_id`, `group_id`, `event_id`, `company_id`, `project_id`, `caption`, `file_key`, `file_name`, `ori_name`, `file_size`, `tagged`, `privacy`, `status` |
| `tbl_project_files` / `tbl_group_files` | `Project` / `Group`, `Event` | `file_id` (PK), `type`, `type_id`, `ori_file_name`, `sys_file_name`, `file_size`, `file_type`, `status` |

- **`tbl_attachment` is polymorphic** via `(type, type_id)`, and rev 2 replaces rev 1's guessed code list with the **authoritative ENUM from the schema**:
  ```
  enum('G','GD','GT','P','PD','PT','PI','PR','C','E','PMSI','PRCA','PICA')
  ```
  Per the column comment: `GD` = Group Discussion, `GT` = Group Ticket, `PD` = Project Discussion, `PT` = Project Task, `PI` = Project Issue, `PR` = Project Risk, `C` = Comment, `E` = Event; `G`/`P` = Group/Project itself, `PMSI` = PMS issue, `PRCA` = project RCA, `PICA` = project issue corrective action. **`'RT'` and `'TASK'` are not valid values** — rev 1 listed both; RT attachments are stored under `'GT'`. `type_id` is the id in whichever table `type` names. Always filter on `type` before joining on `type_id`, or you will match rows across entity families.
- **`tbl_attachment` has two deletion flags:** `status tinyint(1)` *and* `deleted tinyint(1) DEFAULT 0`. Both are real tinyints (safe to compare numerically). Check both.
- **`tbl_project_documents` is EMPTY.** Rev 1 gave it 18 load sites and a whole S3-migration narrative; there is no document data in it. Project file data lives in `tbl_attachment` (non-empty), `tbl_files` (non-empty) and `tbl_project_files` (non-empty). `tbl_starred_files` and `tbl_onlyoffice_file_logs` are also empty, and **`tbl_project_document_history` does not exist** — only `tbl_document_history` (non-empty).
- Folders: `tbl_folder` (`folder_id` (PK), `parent_id`, `folder_name`, `status`), `tbl_document_folder` (**`activity_id`, `folder_id`** — junction, 2 columns), `tbl_folder_mapping`, `tbl_document_history` (**`tbl_project_document_history` does not exist**), `tbl_starred_files` (**empty**), `tbl_attachment_relation` (`relation_id`, `file_id`, `caption`, `description`, `tagged`, `privacy`, `image_inline_id`, `disposition`), `tbl_attachment_dl_log`, `tbl_onlyoffice_file_logs`.
- **Documents link to folders through `activity_id`, not `document_id`:**
  ```sql
  LEFT JOIN tbl_document_folder pdf ON pd.activity_id = pdf.activity_id
  ```
- **Storage location caveat (as of 2026-06-11):** `Documents`-module uploads live on **S3**; `Home`-module uploads are still on local disk and were never migrated. The DB rows look identical — the path convention is the only difference. 12 standard folders are auto-created on `projectSynch`; those folders are **DB-only rows, not S3 prefixes**, and the one-time backfill endpoint had still not been run on the server as of the last check. *(See `.claude/memory/project_s3_documents.md` and `project_doc_folders.md`.)*

---

### B.12 Activity Stream, Comments & Notifications — the polymorphic spine

#### `tbl_activities` — **the hub**
- `activity_id` (PK), `parent_id`, **`activity_type_id`** FK→`tbl_activity_types`, `share_status`, `user_id`, `company_id`, `profile_id`, `question_id`, `group_id`, `event_id`, `follow_id`, **`project_id`**, `parameters`, `related_activity`, `user_ids`, `activity_time`, `file_operation`, `file_operation_type`, `files`, `post_ip`, `group_operation`, `privacy_status`, `update_time`, `activity_privacy`, `delete_time`, `status`, `activity_severity`, `process_read_status`.
- **Managed by:** loaded in 21 modules; 55 load sites.
- **Why it matters for querying:** `tbl_projects`, `tbl_project_tasks`, `tbl_project_issues`, `tbl_pms_issues`, `tbl_project_rca`, `tbl_risk`, `tbl_rt_support`, `tbl_project_topics`, `tbl_group_topics`, `tbl_project_documents`, `tbl_todo_list`, `tbl_files`, `tbl_groups` **all carry an `activity_id`**. That column is how the entity connects to its comments, attachments and feed entries. To get the comments on a task you go **task → activity_id → comments**, never task_id → comments.
- `tbl_activity_types`: `activity_type_id` (PK), `activity_type`, `related_activity`, `parameters`, `section`, `module_read_flag`, `ref_path`, `icon_img`, `description`, `display_at`, `group_operation`, `status`, `group_activity_type`, `vote_status`, `mail_recipients`. This table is what makes the feed renderable — `parameters` and `ref_path` are templates.
- Also: `tbl_activity_tags`, `tbl_activity_privacy_settings`, `tbl_activity_types_desc`.
- **Note `delete_time` and `update_time`** — this table uses `*_time`, while nearly every other table uses `post_date`/`update_date`.

#### `tbl_comments`
- `comment_id` (PK), `parent_id`, `depth`, **`activity_id`**, `company_id`, `user_id`, `comment`, `like_status`, `post_date`, `post_ip`, `status`, `attach_flag`, `activity_severity`, `search_status`.
- **Threaded** via `parent_id` + `depth`. **Linked to entities only through `activity_id`** — confirmed at `Project_model.php:8013, 8408, 8446`.
- Canonical join:
  ```sql
  tbl_comments c
    INNER JOIN tbl_activities a ON c.activity_id = a.activity_id
    LEFT  JOIN tbl_users u      ON c.user_id     = u.user_id
  WHERE (a.status = 1 OR a.status = ...) AND c.status = 1
  ```
- @-mentions are stored in the per-entity junctions `tbl_project_task_comment_users` and `tbl_project_issue_comment_users`, each `(id, <entity>_id, comment_id, user_id, status, post_date)` — both non-empty. **There is no `tbl_pms_issue_comment_users`** (rev 1 listed one; it does not exist), so PMS-issue comments cannot carry mentions. These junctions are how "my mentions" dashboards are built:
  ```sql
  tbl_project_task_comment_users tc
    INNER JOIN tbl_project_tasks t ON tc.task_id = t.task_id
  WHERE tc.user_id = ? ORDER BY t.post_date DESC
  ```
- `tbl_comment_likes`, `tbl_comment_privacy` are satellites.

#### Notifications & mail
- `tbl_notifications`: `notification_id` (PK), `notified_by`, `notified_to`, `notification_type_id`, `post_date`, `post_ip`, **`status`** (read/unread), `notification_url`, `parameters_value`.
- `tbl_notification_types`(+`_desc`), `tbl_notification_settings`, `tbl_batch_notifications`.
- `tbl_log_mails` (id, …), `tbl_log_comment_mail` (`log_mail_id` → `tbl_log_mails.id`, `type_id`, **`type`** where `'c'` = comment, `'th'` = thread), `tbl_log_external_mails`, `tbl_mails`(+`_desc`) = mail templates, `tbl_fetched_mails`(+`_attachments`) = IMAP inbound (`Fetchmail`, feeds RT).

---

### B.13 Estimation, Line Items, Infrastructure & Requirements (pre-sales / planning)

- **Estimation:** only `tbl_project_estimation_status`, `tbl_estimation_complexity` and `tbl_estimation_assumption_map` hold data. **Empty:** `tbl_project_estimation`, `tbl_project_estimation_audit_trails`, `tbl_project_estimation_lineitem_map`, `tbl_estimation_summary`, `tbl_estimation_deliverables`, `tbl_estimation_risks`, `tbl_estimation_asumption`. **Do not exist:** `tbl_project_estimation_category`, `tbl_project_estimation_priority`, `tbl_project_estimation_techstack`, `tbl_project_estimation_lineitem` (rev 1 named all four).
  - **The two-spellings question is settled:** `tbl_estimation_asumption` (misspelled, the one `Estimation_model` loads) exists and is **empty**; `tbl_estimation_assumption` (correctly spelled) **does not exist in the database at all**, despite `TableEstimationAssumption.php` being present. Assumption data, such as it is, is in `tbl_estimation_assumption_map`.
  - Net: **the estimation module has effectively no data.** Treat pre-sales estimation questions as unanswerable.
- **Line items:** `tbl_project_lineitem`, `tbl_lineitem_category`, `tbl_lineitem_priority`, `tbl_lineitem_techstack`, `tbl_lineitem_assumption` (`Lineitem`, `Estimation`) — all non-empty.
- **Infrastructure:** `tbl_project_infrastructure_planning`, `tbl_project_infrastructure_planning_status`, `tbl_project_infrastructure_audit_trails` (`Infrastructure`) — all non-empty.
- **Requirements — note the missing prefix.** The real table names are **`project_infrastructure_requirements`** and **`project_infrastructure_requirements_audit_trails`** and **`project_requirements_lineitem`** (no `tbl_`), all non-empty; the status lookup *is* prefixed: `tbl_project_infrastructure_requirements_status`. Rev 1 spelled the first three with the prefix — those names do not exist and any query using them errors.
- **Repositories:** `tbl_project_repositories`, `tbl_project_repository_access` (`Repositories`) — both non-empty.
- These are all low-traffic (1–2 load sites each); §B.16 now records exactly which are empty.

---

### B.14 Reporting & Aggregates

**Rev 2 rewrote this section: almost every pre-aggregated table here is empty, and almost every view is missing.** Treat reporting as "derive from the live tables", not "read a rollup".

| Table | Census | Purpose / verdict |
|---|---|---|
| `tbl_project_executive_summary` | **non-empty** | weekly PM exec summary, project-scoped. The only populated narrative-summary table — use this one. |
| `tbl_client_summary_report` | **EMPTY** | group-scoped weekly client summary. Rev 1's "filter `latest = 1`" advice is moot; there is nothing to filter. |
| `tbl_task_insights` | **EMPTY** | precomputed per-task bugs/reopened/effort-variance/schedule-variance. **Every metric rev 1 suggested reading from here must be computed from `tbl_project_tasks` + `tbl_project_tasks_history` instead.** |
| `tbl_weekly_task_status`, `tbl_weekly_issue_status`, `tbl_weekly_ticket_status` | **ALL EMPTY** | cron-written weekly snapshots. Rev 1 called them "the correct source for trend lines" — the cron has evidently never populated them (or was never enabled). **There is no historical snapshot data in this database.** Trend-over-time questions must be answered from event history tables (`tbl_project_tasks_history`, `tbl_project_issue_history`, `tbl_rt_status_history`, `tbl_risk_history`, `tbl_task_date_history`) — all of which are non-empty — or not at all. |
| `tbl_url_tracks` | non-empty | page-view tracking (`Reports`) |
| `tbl_project_tasks_prompt` | **non-empty, undocumented in rev 1** | `prompt_id`, `task_id`, `project_id`, `user_id`, `prompt longtext`, `prompt_response longtext`, `created_at`. An LLM prompt/response log against tasks — no Table Object, so rev 1 never saw it. Relevant if this POC is expected to coexist with an existing AI feature. |

#### Views — there is exactly one

`SHOW FULL TABLES` in the dump yields a single view:

| View | Status |
|---|---|
| **`view_project_tasks_combined`** | **exists** |
| `view_get_all_tasks_new`, `view_project_tasks`, `view_project_master_tasks`, `view_timesheet_report`, `view_support_report`, `view_rt_first_thread`, `view_rt_first_reply_thread`, `view_rt_latest_resolved_status`, `view_rt_owner` | **absent from `engagedb`** — referenced in application code but not present in the schema. Any query against them errors out. |

The one that exists is worth understanding, because it encodes the project's own answer to the subtask double-count problem (O-14):

```sql
CREATE VIEW view_project_tasks_combined AS
SELECT IF(t2.parent_id > 0, t2.task_id, t1.task_id) AS task_id,
       IF(t2.parent_id > 0, t2.title,   t1.title)   AS title,
       …  -- same IF() for description, start_date, due_date, rag, priority,
          --                task_status_id, task_owner, reference_no, release_id,
          --                chargeable, project_id
       tbl_projects.title AS project_name,
       tbl_group_projects.group_id, tbl_groups.name AS group_name,
       tbl_group_release.release_date
FROM tbl_project_tasks t1
LEFT JOIN tbl_project_tasks t2 ON t1.task_id = t2.parent_id
LEFT JOIN tbl_group_projects  ON t1.project_id = tbl_group_projects.project_id
LEFT JOIN tbl_group_release   ON t2.release_id = tbl_group_release.release_id
LEFT JOIN tbl_groups          ON …
```

- **The `IF(t2.parent_id > 0, subtask, parent)` pattern is the anti-double-count rollup** the developer's O-14 answer refers to: a parent with subtasks contributes one row *per subtask* (showing the subtask), and a childless task contributes one row (itself). For a two-level hierarchy that is exactly a leaf-task list.
- **Caveats before reusing it:** (a) with three levels, a mid-level task appears both as a leaf substitute and as a parent row, so the leaf identity breaks; (b) it applies **no `status`/`archive` filter at all** — deleted and archived tasks are included, so you must filter outside the view; (c) it joins releases via `tbl_group_release` only, ignoring `tbl_project_release`; (d) it goes through `tbl_group_projects`, which has no unique key, so a duplicated mapping row multiplies output (§B.2).

---

### B.15 Platform / Configuration tables

| Table | Purpose |
|---|---|
| `tbl_menu_settings` | navigation definition (25 load sites) — `id`, `type`, `position`, `title`, `slug`, `module`, `action`, `permission`, `menu_order`, `privacy_module`, `privacy_section`, `status` |
| `tbl_user_settings` | ~60 per-user privacy/notification toggles, one column each, keyed by `user_id` |
| `tbl_static_text`, `tbl_static_modules`, `tbl_tooltip`, `tbl_cms`/`tbl_contents`(+`_desc`) | CMS/labels |
| `tbl_form_fields` / `tbl_form_fields_value` | **dynamic custom fields** — `element_id`, `element_type`, `element_type_id`, `label`, `field_name`, `field_value`, `mandatory`, `formvisible`, `processvisible`, `targettype`, `order` / `element_id`, `type_id`, `element_value`, `element_file_type`, `visible_on`. Used by `Project`, `Qa`, `Form`. **Custom project data lives here as EAV**, joined `ffv.element_id = ff.element_id` and `ffv.type_id = <entity id>`. |
| `tbl_short_url` | `id`, `code`, `url`, `views`, `post_date` — vanity URLs (see commit `7630812a` "Fix the duplicate short_url issue": duplicates are a known historical problem) |
| `tbl_countries`(+`_desc`), `tbl_regions`, `tbl_locations`(+`_desc`), `tbl_languages`, `tbl_genders`(+`_desc`) | reference data; `*_desc` tables hold the per-language labels keyed by `language_id` |
| `tbl_ipfilter`, `tbl_iplist`, `tbl_ipignorelist`, `tbl_ipignore_event` | IP access control |
| `tbl_global_settings`, `tbl_settings`, `tbl_admin_groups`, `tbl_admin_sections`, `tbl_admin_group_settings`, `tbl_admins` | admin/config |

**The `*_desc` pattern:** any table with a sibling `*_desc` stores language-neutral rows in the base table and translated labels in `_desc`, joined on the base id + `language_id`. Always join the `_desc` table to get a human-readable name.

---

### B.16 The census, applied — what is empty, what is missing, what rev 1 got wrong

`empty_tables_report.json` (2026-08-04): **306 tables, 109 empty, 197 non-empty.** Rev 1's guesses are replaced below by the actual result. Rev 1's usage ranking (§0.3) turned out to be a poor proxy for emptiness in both directions.

#### B.16.1 Tables rev 1 documented as live that are **EMPTY** — the corrections that matter

| Table | Why it matters |
|---|---|
| **`tbl_project_documents`** | 18 load sites in rev 1, plus an S3-migration narrative. No data. Use `tbl_attachment`/`tbl_files`/`tbl_project_files`. |
| **`tbl_project_risk`** (+ `tbl_project_risk_status`) | settles C-04: `tbl_risk` is the only risk register with data |
| **`tbl_project_priority`** | settles O-05: `tbl_projects.priority` cannot be an FK into it |
| **`tbl_project_department`**, **`tbl_project_team`** | settles C-05 from the data side; `tbl_projects.team_id` resolves to nothing |
| **`tbl_task_insights`** | all precomputed task metrics must be derived instead |
| **`tbl_client_summary_report`** | the `latest = 1` advice is moot |
| **`tbl_weekly_task_status`, `tbl_weekly_issue_status`, `tbl_weekly_ticket_status`** | **no historical snapshots exist anywhere** |
| **`tbl_project_status_history`** | **no project-status history exists**; task/issue/risk/ticket history tables *are* populated |
| **`tbl_project_sponsors`** | only `tbl_projects.sponsor` (int) carries sponsor data |
| **`tbl_sub_todo_list`** | the `done` flag has no data |
| **`tbl_project_task_milestone`, `tbl_project_task_milestone_mapping`** | no milestone data — milestone KPIs are unanswerable |
| **`tbl_notes`** | PM notes live in `tbl_projects.pm_note` |
| **`tbl_project_estimation`, `_audit_trails`, `_lineitem_map`, `tbl_estimation_asumption`, `tbl_estimation_summary`, `tbl_estimation_deliverables`, `tbl_estimation_risks`** | the estimation module is effectively unpopulated. Only `tbl_project_estimation_status`, `tbl_estimation_complexity`, `tbl_estimation_assumption_map` and the `tbl_lineitem_*` lookups have rows. Rev 1's "which spelling holds data" question is answered: **neither** — the misspelled `tbl_estimation_asumption` exists and is empty, and `tbl_estimation_assumption` does not exist at all. |
| **`tbl_project_initiation_records`** | `_areas` and `_check_points` are non-empty, the records table is not |
| **`tbl_risk_action`, `tbl_risk_mitigation_actions`, `tbl_risk_update`, `tbl_opportunity`(+`_history`, `_tangible`)** | risk narrative is on `tbl_risk` itself |
| **`tbl_project_rca_users`** | `tbl_project_rca_owners` and `tbl_project_rca_internal_users` are non-empty — use those for RCA people |
| **`tbl_rt_env_details`, `tbl_rt_file`** | RT attachments are in `tbl_attachment` (`type = 'GT'`) |
| **`tbl_project_issue_move_history`, `tbl_project_issue_views`, `tbl_project_task_views`** | no move/view telemetry for issues or tasks |
| **`tbl_starred_files`, `tbl_onlyoffice_file_logs`, `tbl_comment_likes`, `tbl_batch_notifications`** | features present in code, unused in data |
| **`tbl_settings`, `tbl_admins`, `tbl_admin_groups`, `tbl_admin_group_settings`** | config lives in `tbl_global_settings` (non-empty) and the gitignored PHP config files |
| **`tbl_ipfilter`, `tbl_iplist`, `tbl_ipignorelist`** | IP access control is not in use |
| **`tbl_user_journey`, `tbl_user_account_history`, `tbl_read_histories`, `tbl_reminder`** | no per-user audit trail beyond `tbl_login_history` (non-empty) |
| **`tbl_support`, `tbl_support_category`, `tbl_support_details`, `tbl_support_reply`** | confirms RT superseded the old support module |
| **`tbl_group_types`(+`_desc`), `tbl_group_task_income_var`, `tbl_regions`, `tbl_process_issue_analysis`, `tbl_project_process_issue`, `tbl_privacy_rules`, `tbl_privacy_settings`, `tbl_activity_privacy_settings`, `tbl_meta`(+`_desc`), `tbl_cms`, `tbl_contents`(+`_desc`)** | assorted dormant config/lookup |
| Social-era, confirmed empty | `tbl_follow`, `tbl_videos`, `tbl_photos_users`, `tbl_user_photos`, `tbl_visitors`, `tbl_review`, `tbl_venue`, `tbl_agenda`, `tbl_announcements`, `tbl_promotion`(+`_desc`, `_ignore_user`), `tbl_bulletin` (all 7), `tbl_qa_attachment`, `tbl_qa_category_group`, `tbl_qa_category_noty_users`, `tbl_ims`(+`_desc`), `tbl_available_for_info`(+`_desc`), `tbl_qualifications`(+`_desc`), `tbl_work_education_types`(+`_desc`), `tbl_work_edu_mapping`, `tbl_area_of_work`, `tbl_word_group`, `tbl_user_subscriptions`, `tbl_chat_broadcast_messages` |
| Non-production, empty | `tbl_mails_backup`, `tbl_mails_live`, `tbl_mails_desc_live`, `temp_all_task` |

#### B.16.2 Tables rev 1 flagged as "candidate-dormant" that are actually **populated**

Rev 1 would have had you exclude these. Do not.

`tbl_albums`, `tbl_album_photos`, `tbl_photos`, `tbl_qa`, `tbl_qa_questions`, `tbl_qa_category`, `tbl_qa_process`, `tbl_qa_votes`, `tbl_qa_answer_votes`, `tbl_qa_status_history`, `tbl_events`, `tbl_event_dates`, `tbl_event_users`, `tbl_interests`(+`_desc`), `tbl_discussion`, `tbl_ehs`, `tbl_ehs_status`, `tbl_jobs`, `tbl_homepage`, `tbl_subscriptions`, `tbl_site_search`, `tbl_search`, `tbl_save_search`, `tbl_test_api_data`.

Note `tbl_discussion` is a polymorphic discussion table (`type enum('G',…)`, `type_id` = group or project id, `activity_id`, `reference_no`) that rev 1 listed only as a dormant name — it is a live, populated sibling of `tbl_project_topics`/`tbl_group_topics` and should be considered whenever "discussions" are in scope.

#### B.16.3 Tables rev 1 named that **do not exist** in `engagedb`

`tbl_pms_issue_comment_users` · `tbl_project_document_history` · `tbl_rca_team_member` · `tbl_rca_date_history` · `tbl_estimation_assumption` · `tbl_project_estimation_category` · `tbl_project_estimation_lineitem` · `tbl_project_estimation_priority` · `tbl_project_estimation_techstack` · `tbl_friends` · `tbl_polls` · `tbl_poll_answers` · `tbl_poll_votes` · `tbl_messages` · `tbl_message_senders` · `tbl_wordfilter*` · `tbl_temp_all_task` (real name `temp_all_task`) · `tbl_temp_users` · `tbl_activity_types_live` · `tbl_external_event*` · `tbl_ipignore_event`.

Also **rename these four** — they exist without the `tbl_` prefix: `project_infrastructure_requirements`, `project_infrastructure_requirements_audit_trails`, `project_requirements_lineitem`, and `department` (§B.1). Rev 1's §B.13 spelled the first three with the prefix; queries using those names will fail.

#### B.16.4 Populated backup/snapshot tables — the live-query hazard

These are non-empty, look like real tables, and will quietly serve stale data to anyone who greps for a table name and picks the wrong hit:

`tbl_project_tasks_bkp` · `tbl_project_tasks_17_07_25` · `tbl_projects_archive` · `tbl_projects_backup_n` · `tbl_risk_bkp` · `tbl_risk_history_old` · `tbl_users_backup` · `tbl_roles_back` · `tbl_master_skills_back` · `tbl_ehs_status_old` · `tbl_test_api_data`.

**Rule: no query in the POC should reference a table whose name ends in `_bkp`, `_back`, `_backup`, `_backup_n`, `_old`, `_archive`, or a date suffix.** Note the trap in `tbl_projects_archive`: archived projects are *not* there — they are `tbl_projects` rows with `archive = 1`.

**Files to ignore entirely in `source/dbobjects/default/`** (checkout artefacts, not real tables): `TableProjectTasks-BCk.php`, `TableProjectTasks.php----`. Likewise ignore the dated model backups `Project_model_12-03-2025.php` and `index_12-03-2025.php` — they contain divergent copies of the logic described here.

---

### B.17 Chat / instant messaging — the module rev 1 missed entirely

Five populated tables with **no Table Object and no Eloquent model**, so a code-only sweep cannot see them. They are presumably driven by a separate socket service. All use **UNIX-epoch integers** for time, not `datetime` — the only place in the schema that does.

| Table | Columns | Notes |
|---|---|---|
| `tbl_chat_messages` | `id`, **`from`**, **`to`**, `message text`, `sent int` (epoch), `token`, `read tinyint`, `direction tinyint`, `group_read`, `leave_group` | 1:1 messages. **`from`, `to` and `read` are MySQL reserved words — they must be backticked in every query.** |
| `tbl_chat_groups` | `id`, `name`, `last_activity int` (epoch), `created_by`, `type tinyint` | chat rooms, unrelated to `tbl_groups` |
| `tbl_chat_group_messages` | `id`, `user_id`, `chat_group_id`, `message`, `sent int` (epoch) | room messages |
| `tbl_chat_group_users` | `user_id`, `chat_group_id`, `last_activity`, `chat_status int` (1 = LEFT, 2 = REMOVED, 3 = …) | room membership; **membership state is `chat_status`, not `status`** |
| `tbl_chat_status` | `user_id`, `messages`, `status enum('online',…)`, `last_activity int` | presence |
| `tbl_chat_broadcast_messages` | — | **EMPTY** |

Chat has **no `activity_id`** and therefore sits entirely outside the `tbl_activities` spine (§B.12) — it does not appear in the activity feed, comments, or notifications. If a KPI mentions "collaboration" or "communication volume", this is where that data is, and it cannot be joined to projects at all: there is no `project_id` anywhere in the chat tables.

---

## C. Core Mapping / Junction Tables

These are the tables that make the whole model work. Nine of them carry no surrogate key at all.

**Rev 2 notes on this table:** `tbl_project_users` is the **only** junction here with a UNIQUE constraint (`project_id, user_id`) — every other one permits duplicate rows and can therefore fan out a join. Empty (ignore): `tbl_project_sponsors`, `tbl_project_task_milestone_mapping`, `tbl_project_risk_status`, `tbl_bulletin_tags_mapping`, `tbl_work_edu_mapping`, `tbl_project_estimation_lineitem_map`, `tbl_project_rca_users`. Does not exist: **`tbl_pms_issue_comment_users`** — the PMS-issue register has no comment-mention junction, so "my mentions" cannot include PMS issues.

| Junction | Connects | Columns | Membership gate |
|---|---|---|---|
| **`tbl_group_projects`** | `tbl_groups` ↔ `tbl_projects` | `group_id`, `project_id` | *none* — no status column, **and no unique key** (duplicates possible → double-count risk) |
| **`tbl_project_users`** | `tbl_projects` ↔ `tbl_users` | `project_id`, `user_id`, `access_type`, `role_id`, `allocation_from`, `allocation_to`, `allocation_hrs`, `resource_type`, `request_status`, `status` | **`request_status='A'` AND `status=1`** — **UNIQUE(project_id, user_id)**, so current state only, no history |
| **`tbl_group_users`** | `tbl_groups` ↔ `tbl_users` | `group_id`, `user_id`, `role_id`, `access_type`, `request_status` | `request_status = 'A'` — nullable column, so NULLs are silently excluded; here `'R'` = **Requested**, not Rejected |
| **`tbl_project_task_users`** | `tbl_project_tasks` ↔ `tbl_users` | `task_id`, `user_id`, `allot_percentage`, `status` | `status = 1` |
| **`tbl_project_issue_users`** | `tbl_project_issues` ↔ `tbl_users` | `issue_id`, `user_id`, `status` | `status = 1` |
| **`tbl_pms_issue_users`** | `tbl_pms_issues` ↔ `tbl_users` | `issue_id`, `user_id`, `status` | `status = 1` |
| **`tbl_project_risk_users`**, **`tbl_project_rca_users`**, **`tbl_project_rca_owners`**, **`tbl_project_rca_internal_users`** | risk/RCA ↔ users | `<entity>_id`, `user_id`, … | `status = 1` |
| **`tbl_rt_support_owner`** | `tbl_rt_support` ↔ `tbl_users` | `ticket_id`, `owner_id`, `status` | `status = 1` |
| **`tbl_task_release`** | `tbl_project_tasks` ↔ `tbl_project_release`/`tbl_group_release` | `release_id`, `task_id` | *none* |
| **`tbl_document_folder`** | `tbl_activities` ↔ `tbl_folder` | `activity_id`, `folder_id` | *none* |
| **`tbl_project_task_comment_users`** / **`tbl_project_issue_comment_users`** / **`tbl_pms_issue_comment_users`** | comments ↔ mentioned users | `id`, `<entity>_id`, `comment_id`, `user_id`, `status` | `status = 1` |
| **`tbl_project_sponsors`** | `tbl_projects` ↔ `tbl_users` | `project_id`, `sponsor_id` | *none* |
| **`tbl_user_company`** | `tbl_users` ↔ `tbl_companies` | `id`, `user_id`, `company_id`, `status` | `status = 1` |
| **`tbl_group_role`** | `tbl_groups` ↔ `tbl_roles` | `group_id`, `role_id`, `access_permission` | *none* |
| **`tbl_project_task_milestone_mapping`** | milestones ↔ tasks/projects | `milestone_id`, `project_id`, `task_id`, dates | *none* |
| **`tbl_estimation_assumption_map`**, **`tbl_project_estimation_lineitem_map`**, **`tbl_folder_mapping`**, **`tbl_bulletin_tags_mapping`**, **`tbl_work_edu_mapping`** | domain-specific maps | — | varies |

### The two canonical access chains

Everything about "what can this user see" reduces to one of these:

```sql
-- 1. Portfolio chain (group membership grants visibility of the group's projects)
tbl_users u
  INNER JOIN tbl_group_users   gu ON u.user_id  = gu.user_id AND gu.request_status = 'A'
  INNER JOIN tbl_groups         g ON gu.group_id = g.group_id AND g.status = 1
  INNER JOIN tbl_group_projects gp ON g.group_id = gp.group_id
  INNER JOIN tbl_projects       p ON gp.project_id = p.project_id AND p.status = 1

-- 2. Direct allocation chain (explicitly allocated to the project)
tbl_users u
  INNER JOIN tbl_project_users pu ON u.user_id = pu.user_id
       AND pu.request_status = 'A' AND pu.status = 1     -- BOTH gates
  INNER JOIN tbl_projects       p ON pu.project_id = p.project_id AND p.status = 1
```

The application generally requires **both** to be satisfied and additionally applies the company-privacy filter of §D.4. A report that uses only chain 1 will over-report; one that uses only chain 2 will miss group-level observers.

---

## D. Querying Gotchas & Heuristics

### D.1 There is **no automatic soft-delete filter anywhere** — this is the single biggest trap

`class.mysqli.php` builds every query as:

```php
$this->sql_query .= ' FROM ' . $this->getTableName() . ' ';
$this->sql_query .= ' WHERE 1 ';        // <- literally "WHERE 1"
```

There are **no global scopes, no default conditions, and no ORM-level soft-delete support**. Every `status = 1` you see is hand-written at the call site, which is exactly why it is inconsistently applied (see §B.3, the 30-vs-8 `project_users` count). When writing SQL you must add every flag yourself.

**The flag vocabulary:**

| Flag | Meaning | Convention |
|---|---|---|
| `status` | soft delete / active | `1` = live, `0` = deleted. Present on most tables — **but not always as a tinyint**: on `tbl_rt_support` it is `enum('0','1')`, which inverts numeric comparison (§D.10). |
| `archive` | archived but not deleted | `1` = archived. On `tbl_projects`, `tbl_project_tasks`, `tbl_groups`, `tbl_project_rca`. Active listings use `archive = 0`. **`tbl_users.hide_archive` is `enum('TRUE','FALSE')`**, a per-user display preference — compare against strings. Archived projects stay in `tbl_projects`; `tbl_projects_archive` is an unrelated stale backup (§B.16.4). |
| `search_status` | indexed for site search | Not a deletion flag — do not filter on it for business queries. **Rewritten by triggers** on `tbl_projects`, `tbl_project_issues`, `tbl_project_topics`, `tbl_group_topics`, `tbl_comments` (§D.9). |
| `request_status` | membership approval | ENUM, and **the letters mean different things in different tables**: `tbl_project_users` = A/I/R with R = *Rejected*; `tbl_group_users` = A/R/I with R = *Requested* and the column NULLable. |
| `deleted` | second delete flag on `tbl_attachment` only | `tinyint(1) DEFAULT 0` — check **in addition to** `status` |
| `enabled` / `verified` / `is_block` | `tbl_users` only (it has **no** `status` column) | plain ints/tinyints |
| `is_completed` (`tbl_todo_list`) | completion, independent of `status` | `done` on `tbl_sub_todo_list` is moot — that table is empty |
| `latest` (`tbl_client_summary_report`) | current row per group | table is **empty** — irrelevant in practice |
| `isvalid` (`tbl_risk`, `tbl_pms_issues`, `tbl_ehs`) | rejected/invalid entries | **`enum('0','1') DEFAULT '0'`** — quote the literal (§D.10) |
| `chat_status` (`tbl_chat_group_users`) | chat-room membership state | `1` LEFT, `2` REMOVED, `3` … — not a soft delete |

**A safe default project filter is therefore:**
```sql
WHERE p.status = 1 AND p.archive = 0
```
…plus the company-privacy filter of §D.4.

### D.2 Two more query-builder quirks worth knowing

- **`dbSelect`/`dbSelectSingle`/`dbCheck`/`dbCount` use only the FIRST key of the `$ID` array.** The implementation is `list($field_name, $value) = each($ID);` — a single `each()` call, no loop. So `dbSelectSingle($f, array('project_id'=>1, 'user_id'=>2))` silently filters on **`project_id` only**. Any additional criteria in existing code had to be passed through the `$cond` string instead. Do not assume a multi-key `$ID` array in the source means a multi-column WHERE.
- **`dbSelectSingle` always appends `LIMIT 0, 1`** with no ORDER BY, so "the" row it returns is whatever MySQL yields first. Several lookups in the codebase (e.g. `getProjectTaskStatusIdByType`) depend on there being exactly one match. If a deployment has duplicate config rows, these silently pick an arbitrary one.
- `name('field')` validates the field against the Table Object's declared properties and **errors out on unknown columns** — which is why the Table Object column lists in this report can be trusted to match the live schema for any column the app actually reads or writes. Columns added to the DB but never added to the Table Object would be invisible to this analysis.

### D.3 Status codes — resolve them, never hardcode them

**Task and issue status: use `status_type`, not `task_status_id`/`issue_status_id`.**

**Rev 2 correction — `status_type` is four different vocabularies, not one.** Rev 1 published a single 1/2/3 table for all four status masters. The column comments in `engagedb.sql` say otherwise, and two of the four have no `3` at all:

| Status master | `status_type` vocabulary (from the column comment) | "Closed" is |
|---|---|---|
| `tbl_project_task_status` | `1` New · `2` In Progress · `3` Closed · **`4` UAT** · **`5` Abandoned** · **`6` Reopened** | `= 3` |
| `tbl_project_issue_status` | `1` New · `2` In Progress · `3` Closed | `= 3` |
| `tbl_pms_issue_status` | `1` Open · `2` Closed | **`= 2`** |
| `tbl_risk_status` | `1` Open · `2` Closed | **`= 2`** |

Consequences you must design around:

- **`status_type = 3` returns zero rows on `tbl_risk_status` and `tbl_pms_issue_status`.** A "closed risks" query written to the rev 1 table yields an empty result that reads as a real answer. Closed risk = `status_type = 2`.
- **"Open" is not simply `!= 3` for tasks.** `!= 3` includes `5` (Abandoned), which is not open work, and it also includes `0` — all four columns are `DEFAULT 0`, so an unmapped status row falls into every `!= 3` bucket. For tasks use an allow-list: `status_type IN (1, 2, 4, 6)`, and decide explicitly whether **UAT (4)** counts as open and whether **Reopened (6)** should be counted separately (it is the natural source for a reopen-rate KPI, and `tbl_task_insights.reopened` is empty, so this is the only way to get it).
- For **issues**, `status_type != 3` is safe — the developer's C-03 answer holds, because 1/2/3 is the entire vocabulary there.
- The `status_name` strings and surrogate ids remain deployment-configurable; `status_type` remains the only stable axis. Used in ~41 places in `Project_model.php`.

```sql
-- Completed tasks, done correctly
SELECT t.*
FROM tbl_project_tasks t
JOIN tbl_project_task_status s
  ON t.task_status_id = s.task_status_id
WHERE s.status_type = 3        -- Closed (tasks/issues only; risks & PMS issues use 2)
  AND s.project_id  = 0        -- global status set; see below
  AND t.status = 1 AND t.archive = 0;
```

**`GLOBAL_PROJECT_STATUS` changes which status rows are live.** It is defined `true` in **all** site configs. When true, the resolvers force `project_id = 0` on `tbl_project_task_status` and `tbl_project_issue_status` — meaning the live status set is the **global** one, and any rows with `project_id > 0` are legacy leftovers that the app no longer reads. Include `project_id = 0` in status joins.

**Project status/stage are keyed by `project_type_id`, not globally** — see §B.3. Resolve `(project_type_id, status_name)`.

**Priority has three mutually incompatible vocabularies — and one of them is not even numeric.** *(Code-confirmed 2026-08-12; storage types corrected against the schema 2026-08-26.)*

| Entity | Column type | Mapping | Source |
|---|---|---|---|
| **Project** `priority` | `int NOT NULL` | `0`=High, `1`=Low, `2`=Urgent, `3`=Strategic | `Project/index.php:132` |
| **Task** `priority` | **`enum('High','Medium','Low','Default','In Staging') DEFAULT NULL`** | compare against the **strings** | DB schema; the PHP array at `Task/index.php:2541` is display-only |
| **Issue** `priority` **and** `severity` | `int NOT NULL` (both) | `1`=Low, `2`=Medium, `3`=High | `Project/index.php:3197` |

**Rev 2 correction: task priority is stored as a string, not an integer.** Rev 1's `0=High, 1=Low, 2=Medium` row described the PHP display array, whose order does not match the ENUM's (`High, Medium, Low, …`). So:

- `WHERE pt.priority = 'High'` — correct. `WHERE pt.priority = 0` — matches nothing usable (§D.10). `WHERE pt.priority = 1` would match `'High'` by ordinal, which is right by luck and wrong the moment someone reorders the ENUM.
- **Five task levels exist, two of which the UI cannot render:** `'Default'` and `'In Staging'` are in the schema but absent from the PHP array. Get the distribution before defining any priority KPI.
- Task priority is **NULLable and defaults to NULL**, so `priority <> 'High'` silently drops unset rows. Project and issue priority are `NOT NULL`, so their "unset" value is `0`.

Cross-entity consequences: `0` is High for a project, unset for an issue, and meaningless for a task; `3` is High for an issue but Strategic for a project and out of range for a task. **Any cross-entity priority KPI must resolve the label per entity type, and cannot be done with a single CASE expression.** There is **no "Critical" level** anywhere. Issue `priority` and `severity` share one label map, which is what makes "critical issue" ambiguous (C-11).

Note also `tbl_project_priority` (**empty**) and `tbl_rt_priority` (non-empty) are *lookup tables* used by different modules — the `priority` columns above are **not** FKs into them. For projects this is now settled by the census: the lookup has no rows, so the PHP map is the only source of labels (O-05).

**Risk rating** is computed, not stored as a band: `rating = probability_value × impact_value`, banded **≥20 red / 12–19 amber / <12 green**, hardcoded in three places in `Risk/index.php`.

**RAG:** `tbl_projects.rag`, `tbl_project_tasks.rag`, `tbl_project_release.rag`, `tbl_group_release.rag` carry a red/amber/green indicator; the colour vocabulary is driven by the `rating_color_code` Registry value (`core.php:82`).

### D.4 Registry values and constants that silently change results

`Registry` is a global key-value store populated in `source/core/core.php` from config files under `PROJECT_ROOT/config/system/` (`modules.php`, `role_settings.php`, `mail_recipients_config.php`). **These config files are gitignored and absent from this checkout** (`config/system/` is empty locally), so their contents cannot be read here — check them on the server.

| Registry key / constant | Effect on queries |
|---|---|
| `GLOBAL_PROJECT_STATUS` (constant, `true` everywhere) | forces `project_id = 0` on task/issue status lookups — §D.3 |
| `default_task_status_config`, `default_issue_status_config` | seed values for the status tables |
| `default_project_status_config`, `default_project_stage_config`, `default_project_types_config` | seed values for project status/stage/type |
| `rating_color_code` | RAG / risk band colour thresholds |
| `role_setting`, `default_group_role_settings` | permission resolution over `tbl_roles.access_permission` |
| `default_folder_settings` | the 12 folders auto-created per project on sync |
| `MONTHLY_BILLING_HOURS` | nominally `160`, but **commented out in `default-config` and `markit-config`** — so it is undefined there and any utilisation KPI referencing it will fatal *(confirmed 2026-08-12)* |

**The company-privacy filter — `chkPrivateProject()` (`Project_model.php:84`).**
Almost every project-listing query passes its SQL through this method, which appends either:
```sql
AND p.company_id = <session company_id>            -- when is_private_company = 1
-- or
AND p.company_id NOT IN (<private_company_ids>)    -- otherwise
```
Both branches read from the **PHP session** (`private_company_ids`, `is_private_company`, `ses_user_info.company_id`), **not** from `tbl_user_company` or `tbl_companies.is_private` directly. Two consequences:

1. You cannot reproduce application-visible row counts in raw SQL without knowing the calling user's company context. Derive it from `tbl_companies.is_private` and `tbl_user_company` and state the assumption.
2. **In cron jobs and any context with no session, the method appends nothing and silently returns cross-company data.** This is a real data-leak path in scheduled reports, not a hypothetical — worth flagging to whoever owns `cron-job/`.

### D.5 Denormalised values that drift

| Column | Authoritative alternative |
|---|---|
| `tbl_projects.total_hours_booked`, `.total_chargable_hours`, `.combined_hours` | `SUM()` over `tbl_timesheets` |
| `tbl_project_tasks.actual_hours` | `SUM()` over `tbl_timesheets` for that `task_id` — **mandatory, not a preference: the column is `tinyint` and caps at 127** |
| `tbl_project_tasks.release_id`, `.released`, `.release_reference_no` | the `tbl_task_release` junction |
| `tbl_task_insights.*` | **table is empty** — recompute from tasks/issues/history, there is no cache to fall back on |
| `tbl_weekly_*` snapshots | **all three are empty** — the cron has never populated them; use the `*_history` tables |
| `tbl_site_search` / `tbl_search` counters (`info1`) | trigger-maintained (§D.9); recount from the source table |

Use the cached columns for dashboards; use the aggregate for anything auditable, and say which you used. **Rev 2: for `actual_hours`, `tbl_task_insights` and `tbl_weekly_*`, there is no longer a choice — the cache is either type-limited or empty.**

### D.6 Date/time conventions

- Standard pair is `post_date` (created) / `update_date` (modified). `tbl_activities` breaks this with `activity_time` / `update_time` / `delete_time`; `tbl_user_skills` and `tbl_master_skills` use `created_at` / `updated_at`; `tbl_clients` uses `created_date`; `tbl_project_users_log` uses `created_at`.
- **Zero dates are used as nulls.** Code explicitly tests `!= '0000-00-00 00:00:00'` (e.g. `Task_model::updateTaskInBulk`). Assume `MODE_NO_ZERO_DATE` is **off** and guard every date comparison — `WHERE due_date < NOW()` will match zero-dates.
- Entity-specific date columns differ: issues use `date_raised`/`date_closed`/`planned_closure_date`; risks use `date_raised`/`date_closed`/`target_closure_date`/`review_date`; tasks use `start_date`/`due_date`; timesheets use `timesheet_date` (the day worked) vs `post_date` (when entered) — **period reporting must use `timesheet_date`**.

### D.7 Known performance traps

`.claude/memory/perf_n1_fixes.md` records batch pre-fetch fixes for the issue/task listing pages and a `getTotalTasks` COUNT optimisation, and noted **two `ALTER TABLE` index statements not yet applied on the server.**

**Rev 2: the dump suggests that note is at least partly stale.** `engagedb.sql` already contains the composite indexes that work called for — `idx_project_request_status(project_id, request_status, status, user_id)` on `tbl_project_users`, `idx_task_users_user_status(user_id, status, task_id)` on `tbl_project_task_users`, and a family of `idx_task_project_status` / `idx_project_status_task_parent` / `idx_tasks_status_parent_post` indexes on `tbl_project_tasks`. Since the dump is a snapshot of the same server, take it as evidence they were applied and **re-verify with `SHOW INDEX` rather than trusting either the memory note or this paragraph** (this is O-26).

What the dump does show as genuinely thin:

- **`tbl_timesheets` has no project-facing index** — only `PRIMARY`, `task_id`, `todo_id`, and `(user_id, timesheet_date, todo_id)`. Every project- or group-level effort aggregate has to hop through `tbl_project_tasks`, and a date-ranged *project* effort query cannot use the date index at all (it is prefixed by `user_id`). This is the single most likely slow path in an executive dashboard.
- **`tbl_group_projects` has four overlapping non-unique indexes and no unique key** — redundant on write, and no protection against the duplicate-row fan-out of §B.2.
- **Type-mismatched join keys** (§0.2) can defeat index use on `tbl_projects` ↔ `tbl_group_projects` ↔ `tbl_groups`.
- `tbl_comments` indexes `status` and `search_status` as single low-cardinality columns — near-useless, and no `(activity_id, status)` composite for the canonical comment lookup.

### D.8 Quick reference — safe filter template

```sql
SELECT ...
FROM tbl_projects p
  INNER JOIN tbl_group_projects gp ON p.project_id = gp.project_id
  INNER JOIN tbl_groups g          ON gp.group_id  = g.group_id  AND g.status = 1
  LEFT  JOIN tbl_project_users pu  ON p.project_id = pu.project_id
        AND pu.request_status = 'A' AND pu.status = 1      -- both gates
  LEFT  JOIN tbl_project_status ps ON p.project_status_id = ps.status_id
        AND ps.project_type_id = p.project_type_id          -- status is type-scoped
WHERE p.status = 1
  AND p.archive = 0
  -- AND p.company_id NOT IN (<private_company_ids>)        -- §D.4, session-derived
;
```

If the query counts projects, either `GROUP BY p.project_id` or use `COUNT(DISTINCT p.project_id)` — `tbl_group_projects` has no unique key and a project may legitimately sit in several groups (§B.2).

### D.9 Triggers — 19 of them, and rev 1 missed all of them

The dump contains **19 triggers and no stored procedures or functions.** They matter because they mutate columns you might otherwise read as application state, and because they fire on `UPDATE`/`DELETE` from *any* client — including a manual fix-up.

| Trigger | On | What it does |
|---|---|---|
| `project_search_update` | **BEFORE UPDATE** `tbl_projects` | **rewrites `NEW.search_status`**: `2` if the row is live and was already indexed, `0` if `status = 0` **or `archive = 1`** — and then `DELETE`s the matching `tbl_search` rows (`stype IN (4,9)`) |
| `project_search_delete` | AFTER DELETE `tbl_projects` | removes the search rows |
| `project_issue_search_update` / `_delete` | `tbl_project_issues` | same pattern for issues |
| `project_topic_search_update` / `_delete` | `tbl_project_topics` | same pattern |
| `group_topic_search_update` / `_delete` | `tbl_group_topics` | same pattern |
| `comment_search_update` / `_delete` | `tbl_comments` | same pattern |
| `user_master_insert` / `_update` / `_delete` | `tbl_users` | maintains a `tbl_site_search` row (`stype = '1'`), **inserted only when `enabled = 1 AND verified = 1`** |
| `group_user_insert` / `_update` / `_delete` | `tbl_group_users` | increments/decrements `tbl_site_search.info1` (member count, `stype = '3'`) **only for `request_status = 'A'`** |
| `idea_master_delete` | AFTER DELETE `tbl_qa_questions` | search cleanup |
| `event_dates_delete` | AFTER DELETE `tbl_event_dates` | cascade cleanup |
| `resetOnlineStatus` | **BEFORE DELETE** `tbl_sessions` | sets `tbl_users.online_status = 0` and blanks `session_id` for that session |

Practical consequences:

1. **`search_status` is trigger-derived, not application state.** Archiving a project silently zeroes it. Never use it as a business filter (§D.1 already said so; now there is a mechanism behind the rule).
2. **`tbl_users.online_status` is session-lifecycle data**, reset by a trigger on session deletion. It is not a presence metric — `tbl_chat_status.status`/`last_activity` and `tbl_users.lastactivity` are closer.
3. **`tbl_site_search.info1` group-member counts are trigger-incremented**, so they drift from `COUNT(*)` on `tbl_group_users` whenever a row was inserted with a NULL `request_status` and approved through a path the trigger's `IF` misses. Recount, do not read.
4. **`tbl_project_tasks` has no search trigger** while projects, issues, topics and comments do — task `search_status` is maintained only by PHP, so the two are not comparable.

### D.10 The ENUM-vs-integer comparison trap — read this before writing any `status =` filter

MySQL compares an `ENUM` column against a **bare number by ordinal position**, not by value. Several flags in this schema are `enum('0','1')`, where ordinal 1 is the string `'0'`. So:

```sql
-- WRONG: returns the DELETED tickets (ordinal 1 = the value '0')
SELECT * FROM tbl_rt_support WHERE status = 1;

-- RIGHT
SELECT * FROM tbl_rt_support WHERE status = '1';
```

Columns where this bites:

| Column | Type | Correct predicate |
|---|---|---|
| `tbl_rt_support.status` | `enum('0','1') DEFAULT '1'` | `status = '1'` |
| `tbl_risk.isvalid`, `tbl_pms_issues.isvalid`, `tbl_ehs.isvalid` | `enum('0','1') DEFAULT '0'` | `isvalid = '1'` |
| `tbl_users.hide_archive` | `enum('TRUE','FALSE')` | `hide_archive = 'FALSE'` |
| `tbl_project_tasks.priority` | `enum('High','Medium','Low','Default','In Staging')` | `priority = 'High'` |
| `tbl_project_tasks.chargeable`, `.invoice`, `.released`, `.requirement_complete`, `.ignore_report`, `.ignore_release_note`, `.bespoke_item` | `enum('Y','N')` | `= 'Y'` |
| `tbl_project_users.request_status`, `.access_type`, `.resource_type`; `tbl_group_users.request_status`, `.access_type` | ENUMs | quote the letter |
| `tbl_projects.source`, `tbl_users.source` | `enum('I','T','P','V')` | quote |
| `tbl_projects.project_type`, `.category_type`, `.audit_status` | ENUMs | quote |

**Rule: quote every ENUM literal, always.** Where the value happens to be numeric-looking (`'0'`/`'1'`), an unquoted comparison is not just sloppy — it inverts the result and returns a confidently wrong answer.

---

## E. Developer decisions from *PMS — Pending Items for POC Review* (2026-08-26), reconciled against the schema

The developer's answers arrived as `PMS — Pending Items for POC Review - Sheet1.csv` (IDs from `PMS_Contradictions_Requiring_Decision.md` and `PMS_Open_Items_Pending.md`). Reconciling them against `engagedb.sql` + the census: **most are confirmed, three need an amendment, and two are settled outright by the data.**

### E.1 Confirmed, no change needed

| ID | Decision | Schema evidence |
|---|---|---|
| **C-02** | resolve task/issue status via `status_type`, not hardcoded ids | confirmed — but see C-03 below for the vocabulary correction |
| **C-04** | `tbl_risk` is the real risk table | **doubly confirmed**: `tbl_project_risk` is *empty* (§B.8) |
| **C-06** | "My Projects" = accepted membership on `tbl_project_users` | confirmed, and the two-gate rule applies: `request_status = 'A' AND status = 1`. Note the UNIQUE key means this is *current* membership only — no as-of-date variant is possible |
| **C-07** | `archive = 0`; the "on" toggle shows `archive = 1` **only**, never both | confirmed as a schema-supported filter. Watch the `project_search_update` trigger: archiving also zeroes `search_status` |
| **C-12** | risk bands from `tbl_risk.rating` / `rating_color_code` | both columns exist and are populated-capable (`rating int NOT NULL`, `rating_color_code varchar(15)`) |
| **O-01 / O-04** | `GLOBAL_PROJECT_STATUS` true; `MONTHLY_BILLING_HOURS` undefined | unchanged — both live in the gitignored PHP config, not the DB |
| **O-05** | project `0` = High, not "unset"; `1` = Low | confirmed. `tbl_project_priority` is **empty**, so there is no lookup table to contradict the PHP map |
| **O-07** | project titles not unique | **confirmed from the index list**: no unique key on `title` — and none on `project_unique_id` either, so the MIS business key can duplicate too |
| **O-08** | all four columns exist; estimate-weighted completion if coverage ≥ 80 % | columns confirmed (`estimate float`, `estimate_complete float`, `percent_complete float DEFAULT 0`) — **except `actual_hours`, which is `tinyint` and caps at 127**; use timesheets for actuals |
| **O-09 – O-12** | no capacity, working-days, calendar or FTE data anywhere | **confirmed by exhaustive schema search.** The nearest thing is `tbl_project_users.resource_type enum('D','P','S')` (Dedicated / Part-Time / Support) — a category, not a fraction |
| **O-15** | drop any indicator relying on `tbl_projects.attention_required` | **confirmed: the column does not exist on `tbl_projects`** (it is on tasks, issues, PMS issues, tickets) |
| **O-19** | `COALESCE(after_mitigation_risk_score, rating)` | both columns exist on `tbl_risk`; see the `NULLIF` amendment in E.2 |
| **O-21** | sample user = `3066` | matches the confirmed test identity in `CLAUDE.md` |

### E.2 Confirmed but needs an amendment

| ID | Developer's answer | Amendment |
|---|---|---|
| **C-05** | department = `tbl_groups`, joined `g.group_id = p.department_id` | **Entity identification confirmed** — `tbl_groups`/`department` are the right tables (`tbl_project_department`/`tbl_project_team` are empty). **Membership join superseded 2026-08-27**: project-department membership resolves via `tbl_group_projects` (the portfolio junction), not the direct `department_id` FK this answer used — confirmed live that the two paths disagree (553 vs. 635 projects on a test department) and the junction is authoritative. See §B.1 rev 2.3 |
| **C-03 / C-02** | "Open issues are `status_type != 3`; in-progress is definitively not closed" | **Correct for issues, unsafe for tasks.** `tbl_project_issue_status` really is 1/2/3, so `!= 3` is right there. But `tbl_project_task_status` has **six** values — `!= 3` sweeps in `5 = Abandoned` (not open) and `0` (unmapped). Use `status_type IN (1,2,4,6)` for open tasks and decide whether UAT counts. And **for risks and PMS issues, closed is `status_type = 2`; `= 3` matches nothing** (§D.3) |
| **C-01 / C-11** | issue severity is `1=Low, 2=Medium, 3=High`, "not used in the form so insufficient data" | Types confirmed (`severity int`, `priority int`, both `NOT NULL` → unset reads as `0`, which is outside the 1–3 range). The mapping is fine to adopt, but a "high severity" KPI needs the **distribution** first, because a form that never sets the field means most rows are `0`: `SELECT severity, COUNT(*) FROM tbl_project_issues WHERE status = 1 GROUP BY severity;`. If `0` dominates, C-11's "critical issue" indicator should be dropped rather than reported as zero |
| **O-19** | `COALESCE(after_mitigation_risk_score, rating)` | `revised_probability`/`revised_impact` **default to `0`, not NULL**, so a residual score can be stored as a real `0`. Use `COALESCE(NULLIF(after_mitigation_risk_score, 0), rating)` if "0" should mean "not assessed" |
| **O-14** | count leaf tasks only, reusing the existing rollup | The rollup is `view_project_tasks_combined`, and its `IF(t2.parent_id > 0, …)` pattern is exactly as described — **but it applies no `status`/`archive` filter, joins releases only via `tbl_group_release`, goes through the non-unique `tbl_group_projects`, and breaks leaf identity at three levels of nesting** (§B.14). Reuse the *pattern*, filter outside it |
| **O-26** | DBA index review | Partly answerable now: the composite indexes from the N+1 work are already in the dump. The real gaps are `tbl_timesheets` (no project-facing index), the four redundant indexes on `tbl_group_projects`, and the type-mismatched join keys (§D.7) |

### E.3 Settled by the data, no decision needed

| ID | Status |
|---|---|
| **O-02** (task status master rows) | The `status_type` **vocabulary** is now known from the column comment (six values). The *row inventory* — how many rows per `status_type`, and whether `project_id = 0` really is the live set — still needs the developer's query run |
| **O-03** (issue status master rows) | Same: vocabulary confirmed as 1/2/3; row inventory still to be run |
| **O-06** (department UAT sample) | Unblocked, as the developer said — and now with the `department` table available for type/unit/HRBP attributes |
| **O-10 / O-11 / O-13** | "None" / "no such constant" / "unconstrained" all confirmed. `allocation_hrs decimal(9,2) DEFAULT 0.00` has no CHECK constraint and no cap, so an over-allocation threshold is a reporting convention, not a violated rule |
| **C-08** (company-privacy filter) | Still open, and rev 2 adds nothing new: `tbl_companies.is_private` exists, but `chkPrivateProject()` reads the PHP **session**, so raw SQL cannot reproduce app-visible counts (§D.4) |
| **C-09, C-10, O-16 – O-18, O-20, O-22 – O-25** | Product/process decisions the schema cannot settle. C-10 ("pending approval" bucket) is now *further* constrained: there is no `status_type` for it in any of the four masters, so it would have to be a `status_name` convention |

### E.4 What the developer's sheet did not cover, and probably should

1. **The chat module** (§B.17) — five populated tables, outside the activity spine, no `project_id`. If any KPI mentions collaboration volume, it needs a decision.
2. **No historical snapshots exist.** All three `tbl_weekly_*` tables and `tbl_task_insights` are empty, and `tbl_project_status_history` is empty. **Any KPI phrased as a trend, a week-on-week delta, or a project-status history is unanswerable from this database** except by deriving from `tbl_project_tasks_history` / `tbl_project_issue_history` / `tbl_risk_history` / `tbl_rt_status_history`. This should be raised before KPI sign-off (O-20), not after.
3. **`tbl_project_documents` is empty**, so any document-count KPI must come from `tbl_attachment` with an explicit `type` filter.
4. **The `tbl_projects.client_id` → `tbl_clients` join target is unverified** (`int` vs `varchar`) — client-level reporting is blocked until that is checked (§B.1).
5. **Nine of the views the code references do not exist**, so any mapped query in the workbook that names one will fail outright. Worth grepping the workbook's column L for `view_` before the next verifier run.
6. **The ENUM comparison trap** (§D.10) — if any already-mapped query filters `status = 1` on `tbl_rt_support` or `isvalid = 1` on `tbl_risk`, it is silently returning the wrong rows and should be re-checked.

---

## F. Recommended Follow-Ups (rev 2)

Verification queries, in priority order. All are read-only and should be run through the `mysql` MCP server against `engagedb`.

1. **Confirm the client join** (blocks all client reporting):
   ```sql
   SELECT (SELECT COUNT(*) FROM tbl_projects WHERE status = 1)                       AS projects,
          (SELECT COUNT(*) FROM tbl_projects p JOIN tbl_clients c ON c.id        = p.client_id) AS via_id,
          (SELECT COUNT(*) FROM tbl_projects p JOIN tbl_clients c ON c.client_id = p.client_id) AS via_client_id;
   ```
2. **Confirm the view inventory** (blocks any mapped query naming a view):
   `SHOW FULL TABLES IN engagedb WHERE Table_type = 'VIEW';`
3. **Run the developer's own O-02 / O-03 queries** to get the status-master row inventory, and extend them to the two masters rev 1 mis-documented:
   ```sql
   SELECT task_status_id, status_name, status_type, project_id FROM tbl_project_task_status ORDER BY project_id, status_type;
   SELECT issue_status_id, status_name, status_type, project_id FROM tbl_project_issue_status ORDER BY project_id, status_type;
   SELECT status_id, status_name, status_type FROM tbl_risk_status      ORDER BY status_type;
   SELECT status_id, status_name, status_type FROM tbl_pms_issue_status ORDER BY status_type;
   ```
4. **Distributions that decide whether a KPI is reportable at all:** task `priority` (five ENUM values, two unrenderable), issue `severity`/`priority` (how much is `0`?), `tbl_project_users.allocation_hrs` (how much is `0.00`?), and O-08's estimate/percent-complete coverage.
5. **Duplicate checks** the schema does not prevent: `tbl_group_projects (group_id, project_id)`, `tbl_projects.project_unique_id`, `tbl_projects.title`.
6. **`SHOW INDEX`** on `tbl_projects`, `tbl_project_tasks`, `tbl_project_users`, `tbl_project_task_users`, `tbl_timesheets` — to close O-26 and settle whether the N+1 indexes are live (§D.7).
7. **Still needed from the server, not the DB:** contents of `config/system/*.php` (gitignored) for `GLOBAL_PROJECT_STATUS`, `MONTHLY_BILLING_HOURS`, `default_*_config` and `rating_color_code`.
8. **Worth raising with the team** (unchanged from rev 1, both still true): the `tbl_project_users.status` filter is missing from ~22 of 30 call sites in `Project_model.php`, so de-allocated resources remain visible on those paths; and `chkPrivateProject()` is a no-op without a session, so cron-generated reports are not company-filtered.
9. **New for the team:** `api/src/models/Ticket.php` filters `WHERE status = 1` on an `enum('0','1')` column and therefore selects deleted tickets (§D.10). No route is bound to it today, so it is latent rather than live.
