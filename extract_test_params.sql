-- Run this through your MySQL MCP server to fetch seed values for TEST_PARAMS.
-- It returns one row with columns mapped to the script's TEST_PARAMS keys.

SELECT
  (SELECT u.user_id
   FROM tbl_users u
   WHERE u.status = 1
   ORDER BY u.user_id
   LIMIT 1) AS current_user_id,

  (SELECT p.title
   FROM tbl_projects p
   WHERE p.status = 1 AND p.archive = 0
   ORDER BY p.project_id
   LIMIT 1) AS project_name,

  (SELECT COALESCE(p.project_unique_id, p.title)
   FROM tbl_projects p
   WHERE p.status = 1 AND p.archive = 0
   ORDER BY p.project_id
   LIMIT 1) AS project_identifier,

  (SELECT t.reference_no
   FROM tbl_project_tasks t
   WHERE t.status = 1 AND t.archive = 0
   ORDER BY t.task_id
   LIMIT 1) AS task_reference,

  (SELECT r.reference_no
   FROM tbl_risk r
   WHERE r.status = 1
   ORDER BY r.risk_id
   LIMIT 1) AS risk_reference,

  (SELECT i.reference_no
   FROM tbl_project_issues i
   WHERE i.status = 1
   ORDER BY i.issue_id
   LIMIT 1) AS issue_reference,

  (SELECT m.milestone
   FROM tbl_project_task_milestone m
   ORDER BY m.milestone_id
   LIMIT 1) AS milestone_name,

  (SELECT CONCAT_WS(' ', u.first_name, u.last_name)
   FROM tbl_users u
   WHERE u.status = 1
   ORDER BY u.user_id
   LIMIT 1) AS employee_name,

  (SELECT d.department_name
   FROM tbl_project_department d
   ORDER BY d.department_id
   LIMIT 1) AS department_name,

  (SELECT t.team_name
   FROM tbl_project_team t
   ORDER BY t.team_id
   LIMIT 1) AS team_name,

  (SELECT pt.project_type
   FROM tbl_project_types pt
   WHERE pt.status = 1
   ORDER BY pt.project_type_id
   LIMIT 1) AS project_type,

  (SELECT DATE_FORMAT(COALESCE(MIN(p.start_date), CURRENT_DATE - INTERVAL 30 DAY), '%Y-%m-%d')
   FROM tbl_projects p
   WHERE p.status = 1 AND p.archive = 0) AS start_date,

  (SELECT DATE_FORMAT(COALESCE(MAX(p.end_date), CURRENT_DATE), '%Y-%m-%d')
   FROM tbl_projects p
   WHERE p.status = 1 AND p.archive = 0) AS end_date,

  30 AS days,

  (SELECT w.week_range
   FROM tbl_weekly_task_status w
   ORDER BY w.id DESC
   LIMIT 1) AS week_range;
