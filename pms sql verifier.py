#!/usr/bin/env python3
"""
PMS SQL Query Verification Script
===================================
Tests the mapped SQL queries from the updated questionnaire workbook against the live database.

HOW TO USE:
-----------
1. Install dependency:   pip install pymysql
2. Set DB credentials in .env (or via shell environment variables).
3. Fill in test parameter values in the TEST_PARAMS section below.
4. Run:                  python "pms sql verifier.py"
5. Output:               pms_verification_results.json (upload this back to Claude)

The script does NOT modify any data. Every query is wrapped in a read-only connection
and each query is executed with LIMIT 5 appended (unless it already has a LIMIT).

If a query succeeds:  status = "PASS", columns and sample row count are captured.
If a query fails:     status = "FAIL", the MySQL error message is captured.
If a query is skipped: status = "SKIPPED" (missing test param values).
"""

import json
import os
import re
import sys
import zipfile
import traceback
import xml.etree.ElementTree as ET
from datetime import datetime, date
from pathlib import Path


def load_dotenv(dotenv_path=".env"):
    """Load simple KEY=VALUE pairs from .env into process env (if not already set)."""
    if not os.path.exists(dotenv_path):
        return

    with open(dotenv_path, "r", encoding="utf-8") as f:
        for raw_line in f:
            line = raw_line.strip()
            if not line or line.startswith("#"):
                continue
            if line.startswith("export "):
                line = line[7:].strip()
            if "=" not in line:
                continue

            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key:
                os.environ.setdefault(key, value)


load_dotenv()


def load_queries_from_workbook(workbook_path):
    """Load mapped query definitions from the workbook generated after filtering empty tables."""
    if not workbook_path.exists():
        return []

    ns = {
        "a": "http://schemas.openxmlformats.org/spreadsheetml/2006/main",
        "r": "http://schemas.openxmlformats.org/officeDocument/2006/relationships",
    }

    def cell_value(cell, shared_strings):
        value_node = cell.find("a:v", ns)
        if value_node is None:
            return None
        value = value_node.text
        if cell.attrib.get("t") == "s":
            return shared_strings[int(value)]
        return value

    queries = []
    with zipfile.ZipFile(workbook_path) as workbook_zip:
        workbook_xml = ET.fromstring(workbook_zip.read("xl/workbook.xml"))
        workbook_rels = ET.fromstring(workbook_zip.read("xl/_rels/workbook.xml.rels"))
        rel_map = {rel.attrib["Id"]: rel.attrib["Target"] for rel in workbook_rels}

        shared_strings = []
        if "xl/sharedStrings.xml" in workbook_zip.namelist():
            shared_root = ET.fromstring(workbook_zip.read("xl/sharedStrings.xml"))
            for shared_item in shared_root.findall("a:si", ns):
                shared_strings.append("".join(text.text or "" for text in shared_item.iterfind(".//a:t", ns)))

        first_sheet = workbook_xml.find("a:sheets", ns)[0]
        sheet_target = "xl/" + rel_map[first_sheet.attrib["{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"]]
        sheet_root = ET.fromstring(workbook_zip.read(sheet_target))

        for row in sheet_root.findall(".//a:sheetData/a:row", ns)[1:]:
            values = [cell_value(cell, shared_strings) for cell in row.findall("a:c", ns)]
            if len(values) < 12:
                continue

            sql = values[11]
            if not sql:
                continue

            canonical = values[2]
            question = values[3]
            row_number = int(float(values[0])) if values[0] is not None else None
            bind_params = sorted(set(re.findall(r":([A-Za-z_][A-Za-z0-9_]*)\b", sql)), key=sql.find)

            queries.append(
                {
                    "row": row_number,
                    "canonical": canonical,
                    "question": question,
                    "bind_params": bind_params,
                    "sql": sql,
                }
            )

    return queries


if "__file__" in globals():
    WORKBOOK_PATH = Path(__file__).with_name("PMS Questions and Query After Removing Empty Table.xlsx")
else:
    WORKBOOK_PATH = Path("PMS Questions and Query After Removing Empty Table.xlsx").resolve()

# ============================================================
# CONFIG — FILL IN YOUR DATABASE CREDENTIALS
# ============================================================
DB_CONFIG = {
    "host":     os.getenv("MYSQL_HOST", "43.204.209.116"),      # e.g. "localhost" or "192.168.1.100"
    "port":     int(os.getenv("MYSQL_PORT", "3306")),            # default MySQL port
    "user":     os.getenv("MYSQL_USER", "engagedb_ro_usr"),      # e.g. "pms_readonly"
    "password": os.getenv("MYSQL_PASSWORD", ""),                 # e.g. "s3cret"
    "database": os.getenv("MYSQL_DATABASE", "engagedb"),         # e.g. "engagedb"
    "charset":  "utf8mb4",
    "connect_timeout": 10,
    "read_timeout": 30,
}

# ============================================================
# TEST PARAMETERS — FILL IN REAL VALUES FROM YOUR PMS DATA
# ============================================================
# These are substituted into the :param placeholders in each query.
# Use REAL values that exist in your database so the queries return data.
# If you leave a value as None, queries needing that param will be SKIPPED.

TEST_PARAMS = {
    # Pick any active user_id from tbl_users (e.g. your own)
    "current_user_id":  3066,       # e.g. 42

    # Pick any real project title from tbl_projects
    "project_name":     None,       # e.g. "Project Alpha"

    # Pick any real project_unique_id OR project title (Row 4 supports both)
    "project_identifier": None,     # e.g. "PF-001" or "Project Alpha"

    # Pick any real task reference_no from tbl_project_tasks
    "task_reference":   None,       # e.g. "TASK-001"

    # Pick any real risk reference_no from tbl_risk
    "risk_reference":   None,       # e.g. "RISK-001"

    # Pick any real issue reference_no from tbl_project_issues
    "issue_reference":  None,       # e.g. "ISS-001"

    # Pick any real milestone name from tbl_project_task_milestone
    "milestone_name":   None,       # e.g. "Phase 1 Complete"

    # Pick any real employee full name (first_name + ' ' + last_name) from tbl_users
    "employee_name":    None,       # e.g. "Rahul Sharma"

    # Pick any real department name from tbl_project_department
    "department_name":  None,       # e.g. "Engineering"

    # Pick any real team name from tbl_project_team
    "team_name":        None,       # e.g. "Backend Team"

    # Pick any real project type from tbl_project_types
    "project_type":     None,       # e.g. "Fixed Price"

    # Date range for period-based queries (use recent dates with data)
    "start_date":       None,       # e.g. "2025-01-01"
    "end_date":         None,       # e.g. "2025-06-30"

    # Lookback window for "last N days" queries
    "days":             30,         # default 30 days — safe to leave as-is

    # Week range for weekly summary queries
    "week_range":       None,       # e.g. "2025-06-01 - 2025-06-07" (check actual format in DB)
}

# ============================================================
# QUERY DEFINITIONS — extracted from PMS_Questionaire.xlsx
# ============================================================
QUERIES = [
    {
        "row": 1,
        "canonical": "my_active_projects",
        "question": "What are my active projects?",
        "bind_params": ["current_user_id"],
        "sql": """SELECT DISTINCT
    p.project_id,
    p.project_unique_id,
    p.project_key,
    p.title,
    p.start_date,
    p.end_date,
    ps.status_name,
    st.stage_name,
    p.priority,
    p.rag
FROM tbl_projects p
JOIN tbl_project_users pu
    ON p.project_id = pu.project_id
LEFT JOIN tbl_project_status ps
    ON ps.status_id = p.project_status_id
LEFT JOIN tbl_project_stages st
    ON st.stage_id = p.project_stage_id
WHERE pu.user_id = :current_user_id
  AND pu.request_status = 'A'
  AND pu.status = 1
  AND p.status = 1
  AND p.archive = 0
ORDER BY p.title ASC"""
    },
    {
        "row": 4,
        "canonical": "project_details",
        "question": "Show details of project :project_identifier.",
        "bind_params": ["project_identifier"],
        "sql": """SELECT
    p.project_id,
    p.project_unique_id,
    p.project_key,
    p.title,
    p.description,
    p.start_date,
    p.end_date,
    ps.status_name,
    st.stage_name,
    pp.priority_name,
    p.rag,
    p.estimate,
    p.total_hours_booked,
    p.total_chargable_hours,
    d.department_name,
    t.team_name,
    pm.first_name AS pm_first_name,
    pm.last_name AS pm_last_name,
    ow.first_name AS owner_first_name,
    ow.last_name AS owner_last_name,
    p.post_date AS created_date,
    p.update_date
FROM tbl_projects p
LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id
LEFT JOIN tbl_project_stages st ON st.stage_id = p.project_stage_id
LEFT JOIN tbl_project_priority pp ON pp.priority_id = p.priority
LEFT JOIN tbl_project_department d ON d.department_id = p.department_id
LEFT JOIN tbl_project_team t ON t.team_id = p.team_id
LEFT JOIN tbl_users pm ON pm.user_id = p.pm_user_id
LEFT JOIN tbl_users ow ON ow.user_id = p.project_owner_id
WHERE (p.project_unique_id = :project_identifier OR p.title = :project_identifier)
  AND p.status = 1
  AND p.archive = 0
ORDER BY p.project_id"""
    },
    {
        "row": 16,
        "canonical": "project_team_size",
        "question": "How many active users are allocated to :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT
    p.project_id,
    p.project_key,
    p.title,
    COUNT(DISTINCT pu.user_id) AS active_member_count
FROM tbl_projects p
JOIN tbl_project_users pu
    ON pu.project_id = p.project_id
WHERE p.title = :project_name
  AND pu.status = 1
  AND pu.request_status = 'A'
  AND p.status = 1
  AND p.archive = 0
GROUP BY p.project_id, p.project_key, p.title"""
    },
    {
        "row": 31,
        "canonical": "my_open_tasks",
        "question": "What are my open tasks?",
        "bind_params": ["current_user_id"],
        "sql": """SELECT
    t.task_id,
    t.reference_no,
    t.title,
    p.title AS project_title,
    t.due_date,
    t.priority,
    t.rag,
    t.percent_complete,
    ts.status_name,
    ts.status_type
FROM tbl_project_tasks t
JOIN tbl_project_task_users tu
    ON t.task_id = tu.task_id
JOIN tbl_projects p
    ON p.project_id = t.project_id
LEFT JOIN tbl_project_task_status ts
    ON ts.task_status_id = t.task_status_id
WHERE tu.user_id = :current_user_id
  AND tu.status = 1
  AND t.status = 1
  AND t.archive = 0
  AND ts.status_type NOT IN (3, 5)
ORDER BY t.due_date ASC, t.reference_no"""
    },
    {
        "row": 2,
        "canonical": "projects_managed_by_me",
        "question": "Which projects am I managing?",
        "bind_params": ["current_user_id"],
        "sql": """SELECT p.project_id, p.project_unique_id, p.project_key, p.title, p.start_date, p.end_date, ps.status_name, st.stage_name, p.priority, p.rag FROM tbl_projects p LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id LEFT JOIN tbl_project_stages st ON st.stage_id = p.project_stage_id WHERE p.pm_user_id = :current_user_id AND p.status = 1 AND p.archive = 0 ORDER BY p.end_date, p.title"""
    },
    {
        "row": 3,
        "canonical": "projects_owned_by_me",
        "question": "Which projects do I own?",
        "bind_params": ["current_user_id"],
        "sql": """SELECT p.project_id, p.project_unique_id, p.project_key, p.title, p.start_date, p.end_date, ps.status_name, st.stage_name, p.priority, p.rag FROM tbl_projects p LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id LEFT JOIN tbl_project_stages st ON st.stage_id = p.project_stage_id WHERE p.project_owner_id = :current_user_id AND p.status = 1 AND p.archive = 0 ORDER BY p.end_date, p.title"""
    },
    {
        "row": 5,
        "canonical": "project_status",
        "question": "What is the status of project :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.project_status_id, ps.status_name, ps.color_code FROM tbl_projects p LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id WHERE p.title = :project_name AND p.status = 1 AND p.archive = 0 ORDER BY p.project_id"""
    },
    {
        "row": 6,
        "canonical": "project_stage",
        "question": "What stage is :project_name in?",
        "bind_params": ["project_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.project_stage_id, st.stage_name, st.color_code FROM tbl_projects p LEFT JOIN tbl_project_stages st ON st.stage_id = p.project_stage_id WHERE p.title = :project_name AND p.status = 1 AND p.archive = 0 ORDER BY p.project_id"""
    },
    {
        "row": 7,
        "canonical": "project_rag",
        "question": "What is the RAG status of :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.rag FROM tbl_projects p WHERE p.title = :project_name AND p.status = 1 AND p.archive = 0 ORDER BY p.project_id"""
    },
    {
        "row": 8,
        "canonical": "project_priority",
        "question": "What is the priority of :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.priority AS priority_id, pp.priority_name, pp.priority_order FROM tbl_projects p LEFT JOIN tbl_project_priority pp ON pp.priority_id = p.priority WHERE p.title = :project_name AND p.status = 1 AND p.archive = 0 ORDER BY p.project_id"""
    },
    {
        "row": 9,
        "canonical": "projects_starting_period",
        "question": "Which projects start between :start_date and :end_date?",
        "bind_params": ["start_date", "end_date"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.start_date, p.end_date, ps.status_name, p.rag FROM tbl_projects p LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id WHERE p.start_date >= :start_date AND p.start_date < DATE_ADD(:end_date, INTERVAL 1 DAY) AND p.status = 1 AND p.archive = 0 ORDER BY p.start_date, p.title"""
    },
    {
        "row": 10,
        "canonical": "projects_ending_period",
        "question": "Which projects end between :start_date and :end_date?",
        "bind_params": ["start_date", "end_date"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.start_date, p.end_date, ps.status_name, p.rag FROM tbl_projects p LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id WHERE p.end_date >= :start_date AND p.end_date < DATE_ADD(:end_date, INTERVAL 1 DAY) AND p.status = 1 AND p.archive = 0 ORDER BY p.end_date, p.title"""
    },
    {
        "row": 12,
        "canonical": "projects_by_department",
        "question": "Show projects for department :department_name.",
        "bind_params": ["department_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, d.department_name, ps.status_name, p.start_date, p.end_date FROM tbl_projects p JOIN tbl_project_department d ON d.department_id = p.department_id LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id WHERE d.department_name = :department_name AND p.status = 1 AND p.archive = 0 ORDER BY p.title"""
    },
    {
        "row": 13,
        "canonical": "projects_by_team",
        "question": "Show projects for team :team_name.",
        "bind_params": ["team_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, t.team_name, ps.status_name, p.start_date, p.end_date FROM tbl_projects p JOIN tbl_project_team t ON t.team_id = p.team_id LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id WHERE t.team_name = :team_name AND p.status = 1 AND p.archive = 0 ORDER BY p.title"""
    },
    {
        "row": 14,
        "canonical": "projects_by_type",
        "question": "Show projects of type :project_type.",
        "bind_params": ["project_type"],
        "sql": """SELECT p.project_id, p.project_key, p.title, pt.project_type, ps.status_name, p.start_date, p.end_date FROM tbl_projects p JOIN tbl_project_types pt ON pt.project_type_id = p.project_type_id LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id WHERE pt.project_type = :project_type AND p.status = 1 AND p.archive = 0 ORDER BY p.title"""
    },
    {
        "row": 17,
        "canonical": "projects_without_pm",
        "question": "Which projects do not have a project manager?",
        "bind_params": [],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.start_date, p.end_date, ps.status_name FROM tbl_projects p LEFT JOIN tbl_project_status ps ON ps.status_id = p.project_status_id WHERE p.pm_user_id IS NULL AND p.status = 1 AND p.archive = 0 ORDER BY p.title"""
    },
    {
        "row": 21,
        "canonical": "project_milestones",
        "question": "Show milestones for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT DISTINCT m.milestone_id, m.milestone, m.start_date, m.end_date FROM tbl_project_task_milestone m JOIN tbl_project_task_milestone_mapping mm ON mm.milestone_id = m.milestone_id JOIN tbl_projects p ON p.project_id = mm.project_id WHERE p.title = :project_name ORDER BY m.end_date, m.milestone"""
    },
    {
        "row": 22,
        "canonical": "upcoming_milestones",
        "question": "Which milestones are due in the next :days days?",
        "bind_params": ["days"],
        "sql": """SELECT DISTINCT p.project_id, p.project_key, p.title AS project_title, m.milestone_id, m.milestone, m.start_date, m.end_date FROM tbl_project_task_milestone m JOIN tbl_project_task_milestone_mapping mm ON mm.milestone_id = m.milestone_id JOIN tbl_projects p ON p.project_id = mm.project_id WHERE m.end_date >= CURRENT_DATE AND m.end_date < DATE_ADD(CURRENT_DATE, INTERVAL :days + 1 DAY) AND p.status = 1 AND p.archive = 0 ORDER BY m.end_date, p.title"""
    },
    {
        "row": 24,
        "canonical": "next_project_milestone",
        "question": "What is the next milestone for :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT DISTINCT m.milestone_id, m.milestone, m.start_date, m.end_date FROM tbl_project_task_milestone m JOIN tbl_project_task_milestone_mapping mm ON mm.milestone_id = m.milestone_id JOIN tbl_projects p ON p.project_id = mm.project_id WHERE p.title = :project_name AND m.end_date >= CURRENT_DATE ORDER BY m.end_date LIMIT 1"""
    },
    {
        "row": 25,
        "canonical": "milestone_tasks",
        "question": "Which tasks belong to milestone :milestone_name?",
        "bind_params": ["milestone_name"],
        "sql": """SELECT p.project_id, p.title AS project_title, m.milestone_id, m.milestone, t.task_id, t.reference_no, t.title AS task_title, t.start_date, t.due_date, ts.status_name, t.percent_complete FROM tbl_project_task_milestone m JOIN tbl_project_task_milestone_mapping mm ON mm.milestone_id = m.milestone_id JOIN tbl_project_tasks t ON t.task_id = mm.task_id JOIN tbl_projects p ON p.project_id = mm.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE m.milestone = :milestone_name AND t.status = 1 AND t.archive = 0 ORDER BY p.title, t.due_date, t.reference_no"""
    },
    {
        "row": 27,
        "canonical": "milestones_without_tasks",
        "question": "Which milestones have no mapped tasks?",
        "bind_params": [],
        "sql": """SELECT m.milestone_id, m.milestone, m.start_date, m.end_date FROM tbl_project_task_milestone m LEFT JOIN tbl_project_task_milestone_mapping mm ON mm.milestone_id = m.milestone_id WHERE mm.task_id IS NULL ORDER BY m.end_date, m.milestone"""
    },
    {
        "row": 29,
        "canonical": "milestones_due_month",
        "question": "Which milestones are due this month?",
        "bind_params": [],
        "sql": """SELECT DISTINCT p.project_id, p.project_key, p.title AS project_title, m.milestone_id, m.milestone, m.end_date FROM tbl_project_task_milestone m JOIN tbl_project_task_milestone_mapping mm ON mm.milestone_id = m.milestone_id JOIN tbl_projects p ON p.project_id = mm.project_id WHERE m.end_date >= DATE_FORMAT(CURRENT_DATE, '%Y-%m-01') AND m.end_date < DATE_ADD(LAST_DAY(CURRENT_DATE), INTERVAL 1 DAY) ORDER BY m.end_date, p.title"""
    },
    {
        "row": 32,
        "canonical": "my_tasks_due_today",
        "question": "Which of my tasks are due today?",
        "bind_params": ["current_user_id"],
        "sql": """SELECT t.task_id, t.reference_no, t.title, p.title AS project_title, t.due_date, ts.status_name, t.priority, t.rag, t.percent_complete FROM tbl_project_task_users tu JOIN tbl_project_tasks t ON t.task_id = tu.task_id JOIN tbl_projects p ON p.project_id = t.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE tu.user_id = :current_user_id AND tu.status = 1 AND t.status = 1 AND t.archive = 0 AND DATE(t.due_date) = CURRENT_DATE ORDER BY t.due_date, t.reference_no"""
    },
    {
        "row": 34,
        "canonical": "tasks_assigned_to_user",
        "question": "Show tasks assigned to :employee_name.",
        "bind_params": ["employee_name"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, p.title AS project_title, t.task_id, t.reference_no, t.title AS task_title, t.due_date, ts.status_name, tu.allot_percentage FROM tbl_users u JOIN tbl_project_task_users tu ON tu.user_id = u.user_id JOIN tbl_project_tasks t ON t.task_id = tu.task_id JOIN tbl_projects p ON p.project_id = t.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE CONCAT_WS(' ', u.first_name, u.last_name) = :employee_name AND tu.status = 1 AND t.status = 1 AND t.archive = 0 ORDER BY p.title, t.due_date, t.reference_no"""
    },
    {
        "row": 39,
        "canonical": "red_rag_tasks",
        "question": "Which tasks have a red RAG status?",
        "bind_params": [],
        "sql": """SELECT t.task_id, t.reference_no, t.title, p.title AS project_title, t.rag, t.due_date, ts.status_name FROM tbl_project_tasks t JOIN tbl_projects p ON p.project_id = t.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE LOWER(t.rag) = 'red' AND t.status = 1 AND t.archive = 0 ORDER BY t.due_date, p.title"""
    },
    {
        "row": 40,
        "canonical": "tasks_due_period",
        "question": "Which tasks are due between :start_date and :end_date?",
        "bind_params": ["start_date", "end_date"],
        "sql": """SELECT t.task_id, t.reference_no, t.title, p.title AS project_title, t.due_date, ts.status_name, t.priority, t.rag FROM tbl_project_tasks t JOIN tbl_projects p ON p.project_id = t.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE t.due_date >= :start_date AND t.due_date < DATE_ADD(:end_date, INTERVAL 1 DAY) AND t.status = 1 AND t.archive = 0 ORDER BY t.due_date, p.title, t.reference_no"""
    },
    {
        "row": 41,
        "canonical": "task_details",
        "question": "Show details of task :task_reference.",
        "bind_params": ["task_reference"],
        "sql": """SELECT t.task_id, t.reference_no, t.title, t.description, p.project_id, p.title AS project_title, t.task_owner, t.start_date, t.due_date, t.task_status_id, ts.status_name, t.priority, t.rag, t.estimate, t.actual_hours, t.percent_complete, t.update_date FROM tbl_project_tasks t JOIN tbl_projects p ON p.project_id = t.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE t.reference_no = :task_reference AND t.status = 1 AND t.archive = 0"""
    },
    {
        "row": 42,
        "canonical": "subtasks_of_task",
        "question": "Show subtasks of :task_reference.",
        "bind_params": ["task_reference"],
        "sql": """SELECT c.task_id, c.reference_no, c.title, c.start_date, c.due_date, ts.status_name, c.priority, c.rag, c.percent_complete FROM tbl_project_tasks parent JOIN tbl_project_tasks c ON c.parent_id = parent.task_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = c.task_status_id WHERE parent.reference_no = :task_reference AND c.status = 1 AND c.archive = 0 ORDER BY c.due_date, c.reference_no"""
    },
    {
        "row": 43,
        "canonical": "task_assignees",
        "question": "Who is assigned to task :task_reference?",
        "bind_params": ["task_reference"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, u.email, tu.allot_percentage, tu.post_date AS assigned_on FROM tbl_project_tasks t JOIN tbl_project_task_users tu ON tu.task_id = t.task_id JOIN tbl_users u ON u.user_id = tu.user_id WHERE t.reference_no = :task_reference AND tu.status = 1 ORDER BY employee_name"""
    },
    {
        "row": 44,
        "canonical": "task_allocation_percentages",
        "question": "Show allocation percentages for task :task_reference.",
        "bind_params": ["task_reference"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, tu.allot_percentage FROM tbl_project_tasks t JOIN tbl_project_task_users tu ON tu.task_id = t.task_id JOIN tbl_users u ON u.user_id = tu.user_id WHERE t.reference_no = :task_reference AND tu.status = 1 ORDER BY tu.allot_percentage DESC, employee_name"""
    },
    {
        "row": 46,
        "canonical": "task_progress",
        "question": "What is the completion percentage of task :task_reference?",
        "bind_params": ["task_reference"],
        "sql": """SELECT t.task_id, t.reference_no, t.title, t.percent_complete, ts.status_name, t.update_date FROM tbl_project_tasks t LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE t.reference_no = :task_reference AND t.status = 1 AND t.archive = 0"""
    },
    {
        "row": 47,
        "canonical": "task_estimate_vs_actual",
        "question": "Compare estimate and actual hours for task :task_reference.",
        "bind_params": ["task_reference"],
        "sql": """SELECT t.task_id, t.reference_no, t.title, t.estimate AS estimated_hours, t.actual_hours, (t.actual_hours - t.estimate) AS variance_hours, t.estimate_complete AS remaining_estimate_hours FROM tbl_project_tasks t WHERE t.reference_no = :task_reference AND t.status = 1 AND t.archive = 0"""
    },
    {
        "row": 49,
        "canonical": "recently_updated_tasks",
        "question": "Which tasks were updated in the last :days days?",
        "bind_params": ["days"],
        "sql": """SELECT t.task_id, t.reference_no, t.title, p.title AS project_title, t.update_date, ts.status_name, t.percent_complete FROM tbl_project_tasks t JOIN tbl_projects p ON p.project_id = t.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE t.update_date >= DATE_SUB(NOW(), INTERVAL :days DAY) AND t.status = 1 AND t.archive = 0 ORDER BY t.update_date DESC"""
    },
    {
        "row": 51,
        "canonical": "task_status_counts",
        "question": "Show task counts by status for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT ts.task_status_id, ts.status_name, ts.status_type, COUNT(*) AS task_count FROM tbl_project_tasks t JOIN tbl_projects p ON p.project_id = t.project_id LEFT JOIN tbl_project_task_status ts ON ts.task_status_id = t.task_status_id WHERE p.title = :project_name AND t.status = 1 AND t.archive = 0 GROUP BY ts.task_status_id, ts.status_name, ts.status_type ORDER BY ts.status_order, ts.status_name"""
    },
    {
        "row": 53,
        "canonical": "my_logged_hours_today",
        "question": "How many hours did I log today?",
        "bind_params": ["current_user_id"],
        "sql": """SELECT ts.user_id, ts.timesheet_date, SUM(ts.hours * 60 + ts.minutes) / 60.0 AS total_hours FROM tbl_timesheets ts WHERE ts.user_id = :current_user_id AND ts.timesheet_date = CURRENT_DATE GROUP BY ts.user_id, ts.timesheet_date"""
    },
    {
        "row": 54,
        "canonical": "my_logged_hours_period",
        "question": "How many hours did I log between :start_date and :end_date?",
        "bind_params": ["current_user_id", "start_date", "end_date"],
        "sql": """SELECT ts.user_id, SUM(ts.hours * 60 + ts.minutes) / 60.0 AS total_hours FROM tbl_timesheets ts WHERE ts.user_id = :current_user_id AND ts.timesheet_date BETWEEN :start_date AND :end_date GROUP BY ts.user_id"""
    },
    {
        "row": 55,
        "canonical": "employee_logged_hours",
        "question": "Show hours logged by :employee_name between :start_date and :end_date.",
        "bind_params": ["employee_name", "start_date", "end_date"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, SUM(ts.hours * 60 + ts.minutes) / 60.0 AS total_hours FROM tbl_users u JOIN tbl_timesheets ts ON ts.user_id = u.user_id WHERE CONCAT_WS(' ', u.first_name, u.last_name) = :employee_name AND ts.timesheet_date BETWEEN :start_date AND :end_date GROUP BY u.user_id, u.first_name, u.last_name"""
    },
    {
        "row": 56,
        "canonical": "project_logged_hours",
        "question": "How many hours were logged on :project_name between :start_date and :end_date?",
        "bind_params": ["project_name", "start_date", "end_date"],
        "sql": """SELECT p.project_id, p.title AS project_title, SUM(ts.hours * 60 + ts.minutes) / 60.0 AS total_hours FROM tbl_timesheets ts JOIN tbl_project_tasks t ON t.task_id = ts.task_id JOIN tbl_projects p ON p.project_id = t.project_id WHERE p.title = :project_name AND ts.timesheet_date BETWEEN :start_date AND :end_date GROUP BY p.project_id, p.title"""
    },
    {
        "row": 57,
        "canonical": "project_hours_by_user",
        "question": "Show hours by user for :project_name.",
        "bind_params": ["project_name", "start_date", "end_date"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, SUM(ts.hours * 60 + ts.minutes) / 60.0 AS total_hours FROM tbl_timesheets ts JOIN tbl_project_tasks t ON t.task_id = ts.task_id JOIN tbl_projects p ON p.project_id = t.project_id JOIN tbl_users u ON u.user_id = ts.user_id WHERE p.title = :project_name AND ts.timesheet_date BETWEEN :start_date AND :end_date GROUP BY u.user_id, u.first_name, u.last_name ORDER BY total_hours DESC"""
    },
    {
        "row": 58,
        "canonical": "hours_by_task",
        "question": "How many hours were logged against task :task_reference?",
        "bind_params": ["task_reference"],
        "sql": """SELECT t.task_id, t.reference_no, t.title, SUM(ts.hours * 60 + ts.minutes) / 60.0 AS total_hours FROM tbl_project_tasks t LEFT JOIN tbl_timesheets ts ON ts.task_id = t.task_id WHERE t.reference_no = :task_reference GROUP BY t.task_id, t.reference_no, t.title"""
    },
    {
        "row": 65,
        "canonical": "my_project_allocations",
        "question": "What projects am I allocated to?",
        "bind_params": ["current_user_id"],
        "sql": """SELECT p.project_id, p.project_key, p.title, pu.access_type, pu.role_id, pu.allocation_from, pu.allocation_to, pu.allocation_hrs, pu.resource_type, pu.request_status FROM tbl_project_users pu JOIN tbl_projects p ON p.project_id = pu.project_id WHERE pu.user_id = :current_user_id AND pu.status = 1 AND pu.request_status = 'A' ORDER BY pu.allocation_from DESC, p.title"""
    },
    {
        "row": 66,
        "canonical": "employee_allocations",
        "question": "Show allocations for :employee_name.",
        "bind_params": ["employee_name"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, p.project_id, p.title AS project_title, pu.allocation_from, pu.allocation_to, pu.allocation_hrs, pu.resource_type, pu.access_type, pu.request_status FROM tbl_users u JOIN tbl_project_users pu ON pu.user_id = u.user_id JOIN tbl_projects p ON p.project_id = pu.project_id WHERE CONCAT_WS(' ', u.first_name, u.last_name) = :employee_name AND pu.status = 1 ORDER BY pu.allocation_from DESC, p.title"""
    },
    {
        "row": 67,
        "canonical": "project_team",
        "question": "Who is allocated to :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, u.email, pu.access_type, pu.role_id, pu.allocation_from, pu.allocation_to, pu.allocation_hrs, pu.resource_type, pu.request_status FROM tbl_projects p JOIN tbl_project_users pu ON pu.project_id = p.project_id JOIN tbl_users u ON u.user_id = pu.user_id WHERE p.title = :project_name AND pu.status = 1 ORDER BY employee_name"""
    },
    {
        "row": 68,
        "canonical": "project_allocated_hours",
        "question": "Show allocated hours by user for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, pu.allocation_hrs, pu.allocation_from, pu.allocation_to, pu.resource_type FROM tbl_projects p JOIN tbl_project_users pu ON pu.project_id = p.project_id JOIN tbl_users u ON u.user_id = pu.user_id WHERE p.title = :project_name AND pu.status = 1 AND pu.request_status = 'A' ORDER BY pu.allocation_hrs DESC, employee_name"""
    },
    {
        "row": 69,
        "canonical": "allocations_ending_soon",
        "question": "Whose project allocation ends in the next :days days?",
        "bind_params": ["days"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, p.project_id, p.title AS project_title, pu.allocation_to, pu.allocation_hrs, pu.resource_type FROM tbl_project_users pu JOIN tbl_projects p ON p.project_id = pu.project_id JOIN tbl_users u ON u.user_id = pu.user_id WHERE pu.status = 1 AND pu.request_status = 'A' AND pu.allocation_to >= CURRENT_DATE AND pu.allocation_to < DATE_ADD(CURRENT_DATE, INTERVAL :days + 1 DAY) ORDER BY pu.allocation_to, employee_name"""
    },
    {
        "row": 70,
        "canonical": "allocations_starting_soon",
        "question": "Whose project allocation starts in the next :days days?",
        "bind_params": ["days"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, p.project_id, p.title AS project_title, pu.allocation_from, pu.allocation_to, pu.allocation_hrs, pu.resource_type FROM tbl_project_users pu JOIN tbl_projects p ON p.project_id = pu.project_id JOIN tbl_users u ON u.user_id = pu.user_id WHERE pu.status = 1 AND pu.request_status IN ('A','I') AND pu.allocation_from >= CURRENT_DATE AND pu.allocation_from < DATE_ADD(CURRENT_DATE, INTERVAL :days + 1 DAY) ORDER BY pu.allocation_from, employee_name"""
    },
    {
        "row": 73,
        "canonical": "resource_skills",
        "question": "What skills does :employee_name have?",
        "bind_params": ["employee_name"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, s.id AS skill_id, s.name AS skill_name FROM tbl_users u JOIN tbl_user_skills us ON us.user_id = u.user_id JOIN tbl_master_skills s ON s.id = us.skill_id WHERE CONCAT_WS(' ', u.first_name, u.last_name) = :employee_name AND us.status = '1' AND s.status = '1' ORDER BY s.name"""
    },
    {
        "row": 76,
        "canonical": "project_roles",
        "question": "Show project roles for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT u.user_id, CONCAT_WS(' ', u.first_name, u.last_name) AS employee_name, pu.role_id, r.role_name, r.role_slug FROM tbl_projects p JOIN tbl_project_users pu ON pu.project_id = p.project_id JOIN tbl_users u ON u.user_id = pu.user_id LEFT JOIN tbl_roles r ON r.role_id = pu.role_id WHERE p.title = :project_name AND pu.status = 1 ORDER BY r.role_name, employee_name"""
    },
    {
        "row": 77,
        "canonical": "project_access_types",
        "question": "Show access types for users on :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT pu.access_type, COUNT(*) AS user_count FROM tbl_projects p JOIN tbl_project_users pu ON pu.project_id = p.project_id WHERE p.title = :project_name AND pu.status = 1 GROUP BY pu.access_type ORDER BY pu.access_type"""
    },
    {
        "row": 89,
        "canonical": "project_estimate",
        "question": "What is the estimate for :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.estimate AS estimated_hours, p.is_approved FROM tbl_projects p WHERE p.title = :project_name AND p.status = 1 AND p.archive = 0 ORDER BY p.project_id"""
    },
    {
        "row": 90,
        "canonical": "project_hours_summary",
        "question": "Show total booked and chargeable hours for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT p.project_id, p.project_key, p.title, p.estimate AS estimated_hours, p.total_hours_booked, p.total_chargable_hours, p.grant_hours, p.combined_hours FROM tbl_projects p WHERE p.title = :project_name AND p.status = 1 AND p.archive = 0 ORDER BY p.project_id"""
    },
    {
        "row": 93,
        "canonical": "project_estimation_versions",
        "question": "Show estimation versions for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT e.estimation_id, e.project_id, e.version, e.estimation_status_id, es.status_name, e.review, e.user_id, e.reviewer_id, e.posted_on, e.updated_on FROM tbl_projects p JOIN tbl_project_estimation e ON e.project_id = p.project_id LEFT JOIN tbl_project_estimation_status es ON es.rca_status_id = e.estimation_status_id WHERE p.title = :project_name AND e.status = 1 ORDER BY e.updated_on DESC, e.estimation_id DESC"""
    },
    {
        "row": 94,
        "canonical": "project_estimation_status",
        "question": "What is the estimation status for :project_name?",
        "bind_params": ["project_name"],
        "sql": """SELECT e.estimation_id, e.version, e.estimation_status_id, es.status_name, es.status_type, e.review, e.updated_on FROM tbl_projects p JOIN tbl_project_estimation e ON e.project_id = p.project_id LEFT JOIN tbl_project_estimation_status es ON es.rca_status_id = e.estimation_status_id WHERE p.title = :project_name AND e.status = 1 ORDER BY e.updated_on DESC, e.estimation_id DESC"""
    },
    {
        "row": 95,
        "canonical": "estimation_summary",
        "question": "Show the detailed estimation summary for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT e.estimation_id, e.version, s.dev_design, s.qa, s.effort, s.contingency, s.uat, s.total, s.support, s.grand_total, s.update_date FROM tbl_projects p JOIN tbl_project_estimation e ON e.project_id = p.project_id JOIN tbl_estimation_summary s ON s.estimation_id = e.estimation_id WHERE p.title = :project_name AND e.status = 1 ORDER BY e.updated_on DESC, s.update_date DESC"""
    },
    {
        "row": 96,
        "canonical": "estimation_assumptions",
        "question": "Show estimation assumptions for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT e.estimation_id, e.version, a.id, a.assumption, a.updated_date FROM tbl_projects p JOIN tbl_project_estimation e ON e.project_id = p.project_id JOIN tbl_estimation_asumption a ON a.estimation_id = e.estimation_id WHERE p.title = :project_name AND e.status = 1 ORDER BY e.updated_on DESC, a.id"""
    },
    {
        "row": 97,
        "canonical": "estimation_risks",
        "question": "Show estimation risks for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT e.estimation_id, e.version, r.id, r.risks, r.updated_date FROM tbl_projects p JOIN tbl_project_estimation e ON e.project_id = p.project_id JOIN tbl_estimation_risks r ON r.estimation_id = e.estimation_id WHERE p.title = :project_name AND e.status = 1 ORDER BY e.updated_on DESC, r.id"""
    },
    {
        "row": 98,
        "canonical": "infrastructure_cost_summary",
        "question": "Show infrastructure cost estimates for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT ir.requirements_id, ir.project_id, ir.tag, ir.provided_by, li.service_category, li.tennancy, li.instance_type, li.region, li.operating_system, li.vcpu, li.memory, li.storage, li.cost, li.monthly_cost, li.version FROM tbl_projects p JOIN project_infrastructure_requirements ir ON ir.project_id = p.project_id JOIN project_requirements_lineitem li ON li.requirements_id = ir.requirements_id WHERE p.title = :project_name ORDER BY ir.requirements_id, li.sl_no"""
    },
    {
        "row": 102,
        "canonical": "high_priority_risks",
        "question": "Which risks are high priority?",
        "bind_params": [],
        "sql": """SELECT r.risk_id, r.reference_no, r.title, p.title AS project_title, rp.priority_name, r.rating, r.rating_color_code, r.target_closure_date, rs.status_name FROM tbl_risk r JOIN tbl_projects p ON p.project_id = r.project_id LEFT JOIN tbl_risk_priority rp ON rp.risk_priority_id = r.risk_priority_id LEFT JOIN tbl_risk_status rs ON rs.status_id = r.status_id WHERE LOWER(rp.priority_name) = 'high' AND r.status = 1 ORDER BY r.rating DESC, r.target_closure_date"""
    },
    {
        "row": 103,
        "canonical": "risk_details",
        "question": "Show details of risk :risk_reference.",
        "bind_params": ["risk_reference"],
        "sql": """SELECT r.risk_id, r.reference_no, r.title, r.description, r.cause, r.consequence, r.controls, r.action, p.title AS project_title, pr.probability_name, ri.impact_name, rp.priority_name, r.rating, r.rating_color_code, rs.status_name, r.owner_id, r.target_closure_date, r.revised_target_closure_date, r.date_raised, r.update_date FROM tbl_risk r JOIN tbl_projects p ON p.project_id = r.project_id LEFT JOIN tbl_risk_probability pr ON pr.probability_id = r.probability_id LEFT JOIN tbl_risk_impact ri ON ri.impact_id = r.impact_id LEFT JOIN tbl_risk_priority rp ON rp.risk_priority_id = r.risk_priority_id LEFT JOIN tbl_risk_status rs ON rs.status_id = r.status_id WHERE r.reference_no = :risk_reference AND r.status = 1"""
    },
    {
        "row": 104,
        "canonical": "risks_by_probability",
        "question": "Show risks by probability.",
        "bind_params": [],
        "sql": """SELECT pr.probability_id, pr.probability_name, pr.probability_value, COUNT(*) AS risk_count FROM tbl_risk r LEFT JOIN tbl_risk_probability pr ON pr.probability_id = r.probability_id WHERE r.status = 1 GROUP BY pr.probability_id, pr.probability_name, pr.probability_value ORDER BY pr.probability_value DESC"""
    },
    {
        "row": 105,
        "canonical": "risks_by_impact",
        "question": "Show risks by impact.",
        "bind_params": [],
        "sql": """SELECT ri.impact_id, ri.impact_name, ri.impact_value, COUNT(*) AS risk_count FROM tbl_risk r LEFT JOIN tbl_risk_impact ri ON ri.impact_id = r.impact_id WHERE r.status = 1 GROUP BY ri.impact_id, ri.impact_name, ri.impact_value ORDER BY ri.impact_value DESC"""
    },
    {
        "row": 106,
        "canonical": "risks_without_owner",
        "question": "Which risks have no owner?",
        "bind_params": [],
        "sql": """SELECT r.risk_id, r.reference_no, r.title, p.title AS project_title, r.owner_id, r.responsibility, r.target_closure_date FROM tbl_risk r JOIN tbl_projects p ON p.project_id = r.project_id WHERE (r.owner_id = 0 OR r.owner_id IS NULL) AND r.status = 1 ORDER BY r.target_closure_date, r.reference_no"""
    },
    {
        "row": 109,
        "canonical": "risk_history",
        "question": "Show the status history of risk :risk_reference.",
        "bind_params": ["risk_reference"],
        "sql": """SELECT 'STATUS_HISTORY' AS record_type, h.post_date AS event_date, h.user_id, h.status_id, rs.status_name, h.probability_id, rp.probability_name, h.impact_id, ri.impact_name, NULL AS update_text FROM tbl_risk r JOIN tbl_risk_history h ON h.risk_id = r.risk_id LEFT JOIN tbl_risk_status rs ON rs.status_id = h.status_id LEFT JOIN tbl_risk_probability rp ON rp.probability_id = h.probability_id LEFT JOIN tbl_risk_impact ri ON ri.impact_id = h.impact_id WHERE r.reference_no = :risk_reference UNION ALL SELECT 'TEXT_UPDATE' AS record_type, u.post_date AS event_date, NULL AS user_id, NULL AS status_id, NULL AS status_name, NULL AS probability_id, NULL AS probability_name, NULL AS impact_id, NULL AS impact_name, u.updated_text AS update_text FROM tbl_risk r JOIN tbl_risk_update u ON u.risk_id = r.risk_id WHERE r.reference_no = :risk_reference AND u.status = 1 ORDER BY event_date DESC"""
    },
    {
        "row": 112,
        "canonical": "issue_details",
        "question": "Show details of issue :issue_reference.",
        "bind_params": ["issue_reference"],
        "sql": """SELECT i.issue_id, i.reference_no, i.title, i.description, p.title AS project_title, i.user_id AS raised_by_user_id, i.date_raised, i.date_closed, i.issue_status_id, s.status_name, i.severity, i.priority, i.impact, i.planned_closure_date, i.overdue_status, i.update_date FROM tbl_project_issues i JOIN tbl_projects p ON p.project_id = i.project_id LEFT JOIN tbl_project_issue_status s ON s.issue_status_id = i.issue_status_id WHERE i.reference_no = :issue_reference AND i.status = 1"""
    },
    {
        "row": 115,
        "canonical": "issues_by_status",
        "question": "Show issue counts by status for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT s.issue_status_id, s.status_name, s.status_type, COUNT(*) AS issue_count FROM tbl_project_issues i JOIN tbl_projects p ON p.project_id = i.project_id LEFT JOIN tbl_project_issue_status s ON s.issue_status_id = i.issue_status_id WHERE p.title = :project_name AND i.status = 1 GROUP BY s.issue_status_id, s.status_name, s.status_type ORDER BY s.status_order, s.status_name"""
    },
    {
        "row": 117,
        "canonical": "project_weekly_task_summary",
        "question": "Show the weekly task summary for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT w.id, w.project_id, p.title AS project_title, w.week_range, w.total_till_date, w.open_till_date, w.closed_till_date, w.carried_forward, w.scheduled_this_week, w.due_this_week, w.uat_this_week, w.closed_this_week, w.mail_sent FROM tbl_weekly_task_status w JOIN tbl_projects p ON p.project_id = w.project_id WHERE p.title = :project_name ORDER BY w.id DESC"""
    },
    {
        "row": 118,
        "canonical": "project_weekly_issue_summary",
        "question": "Show the weekly issue summary for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT w.id, w.project_id, p.title AS project_title, w.week_range, w.total_till_date, w.closed_till_date, w.carried_forward, w.raised_this_week, w.closed_this_week, w.mail_sent FROM tbl_weekly_issue_status w JOIN tbl_projects p ON p.project_id = w.project_id WHERE p.title = :project_name ORDER BY w.id DESC"""
    },
    {
        "row": 119,
        "canonical": "project_executive_summary",
        "question": "Show the latest executive summary for :project_name.",
        "bind_params": ["project_name"],
        "sql": """SELECT es.executive_id, es.project_id, p.title AS project_title, es.summary, es.stage, es.client_mood, es.live_issues, es.dev_issues, es.resource, es.dev, es.test, es.issues, es.risks, es.pm, es.remaining_tail, es.post_date, es.save_date FROM tbl_project_executive_summary es JOIN tbl_projects p ON p.project_id = es.project_id WHERE p.title = :project_name ORDER BY es.save_date DESC, es.post_date DESC LIMIT 1"""
    },
]

workbook_queries = load_queries_from_workbook(WORKBOOK_PATH)
if workbook_queries:
    QUERIES = workbook_queries


def replace_bind_params(sql, params):
    """Replace :param_name with %(param_name)s for pymysql parameterized execution."""
    result = sql
    for param in sorted(params.keys(), key=len, reverse=True):
        # Handle :param + N patterns (like :days + 1)
        result = re.sub(rf':({param})\b', rf'%({param})s', result)
    return result


def verify_query(cursor, query_def, test_params):
    """Execute a single query and return the verification result."""
    result = {
        "row": query_def["row"],
        "canonical": query_def["canonical"],
        "question": query_def["question"],
        "status": None,
        "columns": [],
        "row_count": 0,
        "sample_data": [],
        "error": None,
        "sql_executed": None,
    }

    # Check if all required params are available
    missing = [p for p in query_def["bind_params"] if test_params.get(p) is None]
    if missing:
        result["status"] = "SKIPPED"
        result["error"] = f"Missing test parameters: {', '.join(missing)}"
        return result

    # Build param dict for this query
    param_values = {p: test_params[p] for p in query_def["bind_params"]}

    # Convert bind-param syntax
    sql = replace_bind_params(query_def["sql"], param_values)

    # Add LIMIT if not present (safety measure)
    if "LIMIT" not in sql.upper():
        sql = sql.rstrip(";") + " LIMIT 5"

    result["sql_executed"] = sql

    try:
        cursor.execute(sql, param_values)
        rows = cursor.fetchall()
        columns = [desc[0] for desc in cursor.description] if cursor.description else []

        result["status"] = "PASS"
        result["columns"] = columns
        result["row_count"] = len(rows)

        # Capture up to 2 sample rows (convert non-serializable types)
        for row in rows[:2]:
            sample = {}
            for col, val in zip(columns, row):
                if isinstance(val, (datetime, date)):
                    sample[col] = val.isoformat()
                elif isinstance(val, bytes):
                    sample[col] = val.decode("utf-8", errors="replace")
                elif val is None:
                    sample[col] = None
                else:
                    sample[col] = str(val) if not isinstance(val, (int, float)) else val
            result["sample_data"].append(sample)

    except Exception as e:
        result["status"] = "FAIL"
        result["error"] = f"{type(e).__name__}: {str(e)}"

    return result


def main():
    try:
        import pymysql
    except ImportError:
        print("ERROR: pymysql not installed. Run: pip install pymysql")
        sys.exit(1)

    # Validate required DB credentials
    required = ["host", "user", "password", "database"]
    missing = [k for k in required if not DB_CONFIG.get(k)]
    if missing:
        print(f"ERROR: Missing DB config values: {', '.join(missing)}")
        print("Set them in .env (MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, MYSQL_DATABASE).")
        sys.exit(1)

    # Check for at least some test params
    filled = {k: v for k, v in TEST_PARAMS.items() if v is not None}
    print(f"Test parameters provided: {len(filled)} / {len(TEST_PARAMS)}")
    if not filled:
        print("WARNING: No test parameters filled in. Only parameterless queries will run.")

    # Connect
    print(f"\nConnecting to {DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}...")
    try:
        conn = pymysql.connect(**DB_CONFIG)
        cursor = conn.cursor()
        print("Connected successfully.\n")
    except Exception as e:
        print(f"CONNECTION FAILED: {e}")
        sys.exit(1)

    # Run verification
    results = []
    pass_count = 0
    fail_count = 0
    skip_count = 0

    print(f"Verifying {len(QUERIES)} queries...\n")
    print(f"{'Row':<6} {'Status':<10} {'Canonical Intent':<35} {'Rows':<6} {'Error'}")
    print("-" * 100)

    for qdef in QUERIES:
        r = verify_query(cursor, qdef, TEST_PARAMS)
        results.append(r)

        if r["status"] == "PASS":
            pass_count += 1
            print(f"{r['row']:<6} {'PASS':<10} {r['canonical']:<35} {r['row_count']:<6}")
        elif r["status"] == "FAIL":
            fail_count += 1
            err_short = (r["error"] or "")[:50]
            print(f"{r['row']:<6} {'FAIL':<10} {r['canonical']:<35} {'—':<6} {err_short}")
        else:
            skip_count += 1
            err_short = (r["error"] or "")[:50]
            print(f"{r['row']:<6} {'SKIP':<10} {r['canonical']:<35} {'—':<6} {err_short}")

    # Summary
    print(f"\n{'=' * 60}")
    print(f"PASS: {pass_count}  |  FAIL: {fail_count}  |  SKIPPED: {skip_count}  |  TOTAL: {len(QUERIES)}")
    print(f"{'=' * 60}")

    # Also pull lookup data that's needed for Derived queries
    print("\n\nBONUS: Extracting lookup master data for future use...\n")
    lookup_queries = {
        "project_statuses":     "SELECT * FROM tbl_project_status WHERE status = 1 ORDER BY status_order",
        "project_stages":       "SELECT * FROM tbl_project_stages ORDER BY stage_id",
        "task_statuses":        "SELECT * FROM tbl_project_task_status WHERE status = 1 ORDER BY status_order",
        "risk_statuses":        "SELECT * FROM tbl_risk_status ORDER BY status_id",
        "risk_priorities":      "SELECT * FROM tbl_risk_priority ORDER BY risk_priority_id",
        "risk_probabilities":   "SELECT * FROM tbl_risk_probability ORDER BY probability_id",
        "risk_impacts":         "SELECT * FROM tbl_risk_impact ORDER BY impact_id",
        "issue_statuses":       "SELECT * FROM tbl_project_issue_status WHERE status = 1 ORDER BY status_order",
        "issue_types":          "SELECT * FROM tbl_project_issue_types ORDER BY issue_type_id",
        "project_priorities":   "SELECT * FROM tbl_project_priority ORDER BY priority_order",
        "project_types":        "SELECT * FROM tbl_project_types WHERE status = 1 ORDER BY project_type_id",
        "roles":                "SELECT * FROM tbl_roles WHERE status = 1 ORDER BY role_id",
    }

    lookup_results = {}
    for name, sql in lookup_queries.items():
        try:
            cursor.execute(sql)
            rows = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]
            data = []
            for row in rows:
                record = {}
                for col, val in zip(columns, row):
                    if isinstance(val, (datetime, date)):
                        record[col] = val.isoformat()
                    elif isinstance(val, bytes):
                        record[col] = val.decode("utf-8", errors="replace")
                    elif val is None:
                        record[col] = None
                    else:
                        record[col] = str(val) if not isinstance(val, (int, float)) else val
                data.append(record)
            lookup_results[name] = {"status": "OK", "count": len(data), "data": data}
            print(f"  {name}: {len(data)} rows")
        except Exception as e:
            lookup_results[name] = {"status": "ERROR", "error": str(e), "data": []}
            print(f"  {name}: ERROR - {e}")

    # Write output
    output = {
        "generated_at": datetime.now().isoformat(),
        "database": DB_CONFIG["database"],
        "summary": {
            "total": len(QUERIES),
            "pass": pass_count,
            "fail": fail_count,
            "skipped": skip_count,
        },
        "test_params_used": {k: ("(set)" if v is not None else "(not set)") for k, v in TEST_PARAMS.items()},
        "query_results": results,
        "lookup_master_data": lookup_results,
    }

    output_file = "pms_verification_results.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"\nResults written to: {output_file}")
    print("Upload this file back to Claude to update the spreadsheet.")

    cursor.close()
    conn.close()


if __name__ == "__main__":
    main()