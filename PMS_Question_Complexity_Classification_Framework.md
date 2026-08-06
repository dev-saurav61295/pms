# PMS Question Complexity Classification Framework

## Purpose

This framework explains how PMS questions are categorized as **Simple**, **Moderate**, **Complex**, or **Very Complex**.

The classification is based on how difficult a question is to answer reliably from the database and approved business logic. It is not based only on how complex the wording sounds.

The key factors considered are:

- Number of tables involved
- Type and number of joins required
- Whether the answer is directly stored or must be calculated
- Need for aggregation, comparison, ranking, or trend analysis
- Dependency on business rules
- Need to combine several KPIs
- Risk of incorrect SQL or formula generation by an LLM
- Need for historical, predictive, or executive-prioritization logic

---

## Summary Classification

| Category | Core Meaning | Typical Operation |
|---|---|---|
| Simple | Retrieve | Direct lookup or straightforward join |
| Moderate | Aggregate | Count, sum, group, filter, or simple variance |
| Complex | Derive and compare | Ratios, KPIs, trends, exceptions, and multi-table analysis |
| Very Complex | Combine, rank, forecast, or recommend | Composite scoring, forecasting, executive prioritization, and root-cause analysis |

## The complexity category and caching mechanism are related, but they are not the same classification.

| Complexity | Can use NL2SQL cache? | Recommended approach |
|---|---|---|
| Simple | Yes | Cached or predefined SQL |
| Moderate | Yes | Cached approved aggregation SQL |
| Complex | Conditionally | Predefined KPI SQL/tool, with NL2SQL cache as reuse/fallback |
| Very Complex | Not as the only mechanism | Multiple KPI tools, rule engine/workflow, then LLM explanation |

---

## 1. Simple Questions

### Definition

A Simple question retrieves a value that already exists in the database or requires only a straightforward lookup.

### Typical Characteristics

- One primary table
- Sometimes one lookup-table join
- No major calculation
- No significant business-rule ambiguity
- Usually one input parameter
- Result already exists as a stored database value

### Typical Query Pattern

- Direct column selection
- Simple filter
- Simple lookup join

### Examples

| Question | Why It Is Simple |
|---|---|
| What is the status of Project Alpha? | Direct project field plus status lookup |
| What stage is Project Alpha in? | Direct project field plus stage lookup |
| What is the RAG status of the project? | Direct field from the project table |
| Show task details | Direct task-record retrieval |
| Who is assigned to this task? | Straightforward task-user join |
| What is the task completion percentage? | Direct stored value |

### Example SQL Pattern

```sql
SELECT
    p.title,
    ps.status_name
FROM tbl_projects p
LEFT JOIN tbl_project_status ps
    ON ps.status_id = p.project_status_id
WHERE p.project_id = :project_id;
```

### Recommended OneSpace Implementation

Use a **Bridge Query Tool** for these questions.

---

## 2. Moderate Questions

### Definition

A Moderate question requires aggregation, date filtering, grouping, or a small number of related joins.

### Typical Characteristics

- Two or three related tables
- Counts, sums, averages, or grouped results
- Date-range filtering
- Simple variance or exception logic
- Low-to-medium business-rule dependency

### Typical Query Pattern

- `COUNT`
- `SUM`
- `AVG`
- `GROUP BY`
- Date filtering
- Two-to-three-table joins
- Simple conditional filtering

### Examples

| Question | Why It Is Moderate |
|---|---|
| How many hours were logged by each employee? | Timesheet aggregation and user join |
| Show task counts by status | Grouping by task status |
| Which allocations end in the next 30 days? | Date filtering across users and projects |
| Which projects have Red tasks? | Project-task grouping and RAG filter |
| Show issue counts by status | Issue aggregation |
| Compare estimated and actual task hours | Simple variance calculation |

### Example SQL Pattern

```sql
SELECT
    p.project_id,
    p.title,
    COUNT(*) AS red_task_count
FROM tbl_projects p
JOIN tbl_project_tasks t
    ON t.project_id = p.project_id
WHERE t.rag = 'Red'
  AND t.status = 1
  AND t.archive = 0
GROUP BY p.project_id, p.title;
```

### Recommended OneSpace Implementation

Use a deterministic **Bridge Query Tool** or a simple **Orbit KPI Tool**.

---

## 3. Complex Questions

### Definition

A Complex question requires multiple datasets, derived KPIs, comparisons, trend analysis, exception logic, or confirmed business rules.

### Typical Characteristics

- Several related tables or aggregated subqueries
- Derived percentages or ratios
- Comparison between different measures
- Ranking or exception identification
- Multiple time periods
- Data-quality handling
- Medium-to-high dependency on approved business rules

### Typical Query Pattern

- CTEs
- Multiple joins
- Conditional aggregation
- Ratios and percentages
- Trend comparison
- Ranking
- Multiple subqueries

### Examples

| Question | Required Derivation |
|---|---|
| Which projects are consuming effort faster than work is completed? | Effort-consumption percentage versus task-completion percentage |
| Which projects have the greatest overdue-task exposure? | Open-status rule, overdue rule, task weighting, and project aggregation |
| Which project managers have the most unhealthy projects? | Project-health calculation followed by PM-level grouping |
| Which resources are overallocated? | Overlapping allocation periods and capacity definition |
| Which projects depend heavily on one contributor? | User-wise timesheet concentration per project |
| Which projects have both high risks and unresolved issues? | Risk aggregation combined with issue aggregation |
| Which projects show declining task performance? | Time-period comparison and task-status trends |

### Example KPI Logic

```text
Effort Burn Percentage =
Actual or Logged Hours
÷ Estimated Hours
× 100
```

```text
Task Completion Percentage =
Completed Eligible Tasks
÷ Total Eligible Tasks
× 100
```

```text
Delivery Imbalance =
Effort Burn Percentage - Task Completion Percentage
```

This is categorized as Complex because the formula, eligible statuses, thresholds, and exception rules must be approved before the SQL is finalized.

### Recommended OneSpace Implementation

Use a deterministic **Orbit KPI Tool** or **Watchlist Tool**. The LLM may explain the result but should not invent the KPI formula.

---

## 4. Very Complex Questions

### Definition

A Very Complex question combines several KPIs or business domains and normally requires executive prioritization, forecasting, composite scoring, or root-cause analysis.

### Typical Characteristics

- Multiple KPI calculations
- Cross-domain data
- Weighted composite scoring
- Forecasting or forward-looking indicators
- Executive ranking
- 30/60/90-day outlook
- Root-cause analysis
- Recommended actions
- High dependency on approved business rules

### Typical Query Pattern

- Multiple CTEs or precomputed KPI datasets
- Weighted formulas
- Cross-functional joins
- Historical trend logic
- Ranking and prioritization
- Rule-based forecasting or a trained predictive model

### Examples

| Question | Why It Is Very Complex |
|---|---|
| Which projects require immediate executive attention? | Combines schedule, tasks, risks, issues, effort, allocations, and inactivity |
| Which projects are most likely to miss their committed end dates? | Requires forward-looking indicators and historical patterns |
| How much business value is currently exposed? | Health score combined with commercial or deal value |
| Which PM portfolios carry the greatest delivery risk? | Project-level health aggregated at PM level |
| What should leadership focus on over the next 30, 60, and 90 days? | Combines upcoming dates, risks, issues, releases, and allocations |
| Why is this project unhealthy? | Requires evidence aggregation and root-cause explanation |

### Example Composite Score

```text
Executive Attention Score =
30% Schedule Exposure
+ 20% Overdue Task Exposure
+ 20% Open Risk Exposure
+ 15% Issue Exposure
+ 10% Effort Variance
+ 5% Resource Exposure
```

The weights above are illustrative. Final weights must be approved by the business.

### Recommended OneSpace Implementation

Use:

- Deterministic KPI calculations
- An Orbit executive watchlist or dashboard tool
- Mesh only for explanation, summarization, and follow-up reasoning

The LLM should not independently invent the score, threshold, or ranking formula.

---

## Additional Classification Criteria

### Number of Tables

| Tables Involved | Usual Classification |
|---:|---|
| 1 | Simple |
| 2–3 | Simple or Moderate |
| 4–6 | Moderate or Complex |
| Multiple aggregated datasets | Complex or Very Complex |

The number of tables is only one factor. A six-table lookup may still be easier than a two-table utilization question that depends on an undefined business formula.

---

### Type of Calculation

| Calculation | Classification Tendency |
|---|---|
| Direct field | Simple |
| Count or sum | Moderate |
| Ratio or percentage | Moderate or Complex |
| Trend or variance | Complex |
| Weighted composite score | Very Complex |
| Forecast or probability | Very Complex |

---

### Business-Rule Ambiguity

A question is categorized at a higher level when it includes terms that require interpretation, such as:

- Active
- Open
- Completed
- Healthy
- At risk
- Overallocated
- High severity
- Stale
- Delayed
- Likely to miss
- Requires executive attention

Example:

- **What is the task status?** — Simple
- **How many open tasks are there?** — Moderate or Complex, because the statuses considered open must be defined

---

### LLM Error Risk

| LLM Risk | Typical Classification |
|---|---|
| Selecting a direct field | Simple |
| Choosing an aggregation | Moderate |
| Building several joins and KPI ratios | Complex |
| Inventing weights, thresholds, or predictions | Very Complex |

Questions with a higher risk of incorrect LLM interpretation should be implemented through predefined SQL, approved formulas, and structured tools.

---

## Important Clarification

The complexity category describes **implementation complexity**, not business importance.

Examples:

- **What is the project RAG?** is technically Simple but may be important to leadership.
- **Which projects are silently deteriorating despite Green RAG?** is Complex or Very Complex because it compares stored RAG with objective operational indicators.

---

## Decision Guide

Use the following quick test:

| Question Test | Classification |
|---|---|
| Is the answer stored directly in one record? | Simple |
| Does it require grouping, counting, summing, or date filtering? | Moderate |
| Does it require formulas, ratios, trends, or several business rules? | Complex |
| Does it combine multiple KPIs to rank, forecast, prioritize, or recommend? | Very Complex |

---

## Final Summary

```text
Simple
= Retrieve

Moderate
= Aggregate

Complex
= Derive and Compare

Very Complex
= Combine, Rank, Forecast, or Recommend
```
