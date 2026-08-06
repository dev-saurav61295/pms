# PMS Very-Complex Questions: Data, KPI, Caching, and LLM Approach

## 1. Core Explanation

For very-complex PMS questions, the answer should **not be produced directly by the LLM from raw database tables**.

The recommended approach is:

```text
Raw PMS data
→ deterministic SQL / KPI calculation
→ structured derived result
→ LLM explanation and summarisation
```

The database provides the facts. SQL, views, KPI tools, or rule engines calculate the derived indicators. The LLM then explains the result in natural language.

A practical statement for stakeholders is:

> The required operational data is retrieved from the PMS database, and the derived KPIs are calculated through predefined SQL and approved business rules. The LLM uses those structured results to explain the answer, highlight the main drivers, and provide an executive summary.

This is more accurate than saying that the LLM itself derives all the figures.

---

## 2. Can This Be Based 100% on NL2SQL Caching?

No. Very-complex questions should **not depend 100% on NL2SQL caching**.

NL2SQL caching is useful for reusing a previously generated SQL structure. It can avoid asking the LLM to generate the same SQL repeatedly, while still executing the query against current data.

However, very-complex questions usually require:

- Multiple data sources or tables
- Approved KPI formulas
- Status mappings
- Thresholds
- Weighted scoring
- Comparison across periods
- Ranking
- Exception logic
- Business interpretation
- Explainable evidence

These should be implemented as predefined, deterministic tools rather than relying on the LLM to regenerate the complete SQL logic every time.

### Recommended responsibility split

| Component | Responsibility |
|---|---|
| FAQ or semantic mapping | Map user wording to a canonical question or tool |
| NL2SQL cache | Reuse approved SQL structure for suitable queries |
| Bridge query tool | Execute deterministic SQL against current PMS data |
| KPI or rule engine | Calculate approved derived indicators and scores |
| Orbit tool | Package the process with structured inputs and outputs |
| Mesh / LLM | Explain findings, summarise drivers, and answer follow-ups |
| Response cache | Reuse final responses only where data freshness permits |

---

## 3. Direct, Derived, and Very-Complex Questions

### Direct question

Example:

> What is the current status of Project Alpha?

Process:

```text
Question
→ project-status query
→ current DB value
→ response
```

This can use:

- A predefined Bridge query
- FAQ-to-tool mapping
- NL2SQL cache, where appropriate

### Derived question

Example:

> What percentage of the project's tasks are overdue?

Process:

```text
Task data
→ approved open-task rule
→ overdue-task count
→ eligible-task count
→ overdue percentage
→ LLM explanation
```

The percentage should be calculated through SQL or a KPI service, not freely calculated by the LLM.

### Very-complex question

Example:

> Which projects require immediate executive attention and why?

Process:

```text
Project dates
+ task exposure
+ effort variance
+ risk exposure
+ issue exposure
+ resource exposure
→ deterministic KPI calculations
→ approved executive-attention score
→ ranked project list
→ LLM explanation
```

This cannot be handled reliably through a single simple lookup or uncontrolled NL2SQL generation.

---

# 4. Forecasting

## Example question

> Which projects are likely to miss their committed end dates?

The database does not contain a direct `will_miss_deadline` field. The system must derive an early-warning result from indicators such as:

- Days remaining until the project end date
- Open and overdue tasks
- Task completion percentage
- Estimated versus actual effort
- Recent progress velocity
- Open risk exposure
- Unresolved and overdue issues
- Resource-allocation gaps
- Timesheet burn rate

## Rule-based forecasting

An initial implementation can use a deterministic early-warning score.

Example:

```text
Deadline Risk Score =
25% overdue-task ratio
+ 20% incomplete-work ratio
+ 15% effort overrun
+ 15% open-risk exposure
+ 10% overdue-issue exposure
+ 10% recent-progress slowdown
+ 5% resource gap
```

Example classification:

| Score | Classification |
|---:|---|
| 0–29 | Low |
| 30–59 | Medium |
| 60–79 | High |
| 80–100 | Critical |

The exact weights and thresholds must be approved by the business.

## What can be claimed

With current operational data, the system can provide:

> High schedule-slippage risk based on current delivery indicators.

It should not claim:

> There is a 78.4% probability of delay.

A precise probability requires historical snapshots, completed-project outcomes, model training, validation, and ongoing monitoring.

---

# 5. Executive Prioritisation

## Example question

> Which projects require immediate executive attention?

The database does not directly store an executive-attention flag. It must be derived by combining several indicators.

## Possible executive-attention dimensions

| Dimension | Example weight |
|---|---:|
| Schedule exposure | 25% |
| Task-delivery exposure | 20% |
| Risk exposure | 20% |
| Issue exposure | 15% |
| Effort or cost exposure | 10% |
| Resource exposure | 5% |
| Data or reporting inactivity | 5% |

Example:

```text
Executive Attention Score =
Schedule Score × 25%
+ Task Score × 20%
+ Risk Score × 20%
+ Issue Score × 15%
+ Effort Score × 10%
+ Resource Score × 5%
+ Inactivity Score × 5%
```

The output should be a structured ranked list.

| Rank | Project | Score | Attention Level | Main Drivers |
|---:|---|---:|---|---|
| 1 | Project A | 87 | Critical | Overdue tasks, high risks, effort overrun |
| 2 | Project B | 73 | High | Near end date, unresolved issues |
| 3 | Project C | 61 | High | Resource gap, declining progress |

The LLM explains why each project was ranked, but the rank and score must come from approved deterministic logic.

---

# 6. Root-Cause Analysis

## Example question

> Why is Project Alpha delayed?

The database can identify evidence and likely contributing factors. It cannot always prove true causality from current records alone.

## Possible contributing factors

| Category | Database evidence |
|---|---|
| Task-execution delay | High overdue-task ratio |
| Effort underestimation | Actual or logged hours above estimate |
| Resource shortage | Low allocation or allocation ended |
| Key-person dependency | One contributor supplies most project hours |
| Quality problems | Reopened, retest, QA, or UAT task concentration |
| Issue blockage | Old unresolved or overdue issues |
| Risk exposure | High open risks or overdue mitigation |
| Scope growth | Tasks added after the baseline |
| Slow progress | Low recent completion velocity |
| Governance inactivity | No recent status or executive updates |

## Example deterministic rules

```text
IF actual_hours > estimate × 1.20
THEN contributing_factor = "Effort underestimation"

IF overdue_open_tasks / open_tasks > 0.30
THEN contributing_factor = "Task execution delay"

IF top_contributor_hours / total_project_hours > 0.60
THEN contributing_factor = "Key-person dependency"

IF open_high_risks > 0
AND target_closure_date < current_date
THEN contributing_factor = "Unresolved risk exposure"

IF reopened_or_retest_tasks / active_tasks > 0.20
THEN contributing_factor = "Quality or rework pressure"
```

The result should be presented as evidence-based contributing-factor analysis.

| Suspected contributor | Evidence | Confidence |
|---|---|---|
| Effort underestimation | Actual hours are 28% above estimate | High |
| Task slippage | 34 of 72 open tasks are overdue | High |
| Key-person dependency | One person logged 66% of project hours | Medium |
| Quality rework | 18% of tasks are ReOpen or ReTest | Medium |

The term **root cause** should be used carefully. A stronger root-cause conclusion may require project notes, RCA documents, meeting records, client communication, and status-history data.

Prism can provide supporting document evidence, while Bridge provides live structured data. Mesh can combine and explain both.

---

# 7. Recommended OneSpace Architecture

## Layer 1: Base Bridge queries

Retrieve current factual data:

- Projects
- Tasks
- Timesheets
- Allocations
- Risks
- Issues
- Users
- Project status and stage values

## Layer 2: Derived KPI queries or views

Calculate:

- Task-completion rate
- Overdue-task ratio
- Effort-burn percentage
- Risk-exposure score
- Issue-aging score
- Contributor concentration
- Resource-allocation gap
- Recent-progress velocity

## Layer 3: Decision tools

Package the derived logic as:

- Deadline Risk Tool
- Executive Attention Tool
- Project Health Tool
- Contributing-Factor Diagnostic Tool
- 30/60/90-Day Watchlist

## Layer 4: LLM explanation

The LLM receives the structured result and explains:

- What happened
- Why the item was ranked or flagged
- Which indicators contributed most
- What supporting evidence exists
- What approved action may be considered

---

# 8. Caching Strategy

## FAQ or semantic intent mapping

Use this to map multiple user phrasings to the same canonical tool.

Example:

```text
"Which projects need leadership attention?"
"What should the CEO focus on?"
"Show critical projects."
→ executive_attention_watchlist
```

## NL2SQL cache

Use this where an approved SQL structure can be reused and executed against live data.

Suitable examples:

- Project status
- Tasks due in a period
- Project hours
- Risk details
- Issue details
- Allocation summaries
- Some derived KPI queries after their formulas are approved

NL2SQL cache does not replace the need for business rules.

## Predefined KPI tools

Use predefined KPI tools for:

- Composite scores
- Weighted prioritisation
- Forecast watchlists
- Trend comparisons
- Root-cause or contributing-factor logic
- Cross-domain executive summaries

These should be version-controlled, tested, explainable, and auditable.

## Response cache

Use response caching only when the output can safely be reused for a defined period.

Avoid long-lived response caching for live operational data such as:

- Current project status
- Current task progress
- Timesheets
- Active risks
- Open issues
- Resource allocations

---

# 9. Recommended Stakeholder Explanation

A clear explanation is:

> For direct questions, we use predefined or cached SQL to retrieve live data from the PMS database. For complex questions, the system retrieves the required operational data and calculates approved derived KPIs through deterministic SQL and business rules. The LLM does not invent the figures or formulas. It uses the structured KPI result to explain the answer, identify the main drivers, and provide an executive-friendly summary.

A shorter version is:

> The database provides the facts, the KPI layer performs the calculations, and the LLM explains the result.

---

# 10. What Is and Is Not 100% NL2SQL

| Capability | Can rely mainly on NL2SQL or cached SQL? |
|---|---|
| Direct record lookup | Yes |
| Simple filtering | Yes |
| Basic aggregation | Usually |
| Approved derived KPI | Partially; preferably predefined SQL or a KPI tool |
| Composite executive scoring | No |
| Forecast watchlist | No |
| Statistical prediction | No |
| Evidence-based diagnosis | No |
| Natural-language explanation | LLM responsibility |

---

# 11. Final Position

Very-complex PMS questions are supported through a combination of:

```text
Live database data
+ deterministic derived calculations
+ approved business rules
+ reusable Bridge / Orbit tools
+ LLM explanation
```

They should not be based solely on:

- Raw NL2SQL generation
- NL2SQL caching alone
- LLM-generated KPI formulas
- LLM-calculated totals
- Cached final responses for fast-changing operational data

The objective is to make the answer:

- Accurate
- Repeatable
- Explainable
- Auditable
- Current
- Safe from LLM calculation errors
