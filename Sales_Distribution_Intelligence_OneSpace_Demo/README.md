# Sales & Distribution Intelligence - One Space Demo Package

## Purpose
Industry-ready synthetic Retail/FMCG demonstration for One Space. The solution demonstrates descriptive, diagnostic, comparative, root-cause, prescriptive and executive intelligence across commercial performance, distribution execution and qualitative business context.

The Sales & Distribution Intelligence Agent helps Retail/FMCG teams understand what is happening in sales, why it is happening, where the problem is concentrated, and what management should do next.

It combines commercial and operational evidence across areas such as:
- Primary and secondary sales
- Distributor performance
- Inventory and ageing
- Stock-outs and availability
- Outlet coverage and salesperson productivity
- Returns, damage and expiry
- Promotion execution and effectiveness
- Fill rate, OTIF and delivery performance
- Field notes, distributor reviews and business-review context

Instead of only showing KPIs, it performs root-cause analysis, compares regions/distributors/SKUs, identifies hidden risks, highlights strong and weak performers, and recommends prioritized actions.

## Synthetic enterprise
**Aurevia Consumer Products Ltd.** is fictional. All people, distributors, outlets, products, metrics and documents in this package are synthetic.

## One Space architecture

Connector -> optional Tag & Taxonomy -> Collection -> Sync/Ingestion -> Collection RAG evidence layer -> Collection exposed as Tool -> Mesh Agent orchestration and final response.

### Collections
| Connector | Collection | Tool slug |
|---|---|---|
| FMCG Commercial Data | FMCG Commercial Performance | `fmcg-commercial-performance` |
| FMCG Distribution Operations Data | FMCG Distribution Execution | `fmcg-distribution-execution` |
| FMCG Sales Business Documents | FMCG Sales Business Context | `fmcg-sales-business-context` |

## Package folders
- `01_Ingestion_Packages` - three ZIPs to ingest into their matching Collections.
- `02_Tag_Taxonomy` - taxonomy hierarchy and file mapping.
- `03_Agent_Prompts` - three Collection system prompts and the Mesh Agent system prompt.
- `04_Setup_and_Testing` - setup guide, test question bank and Testing Guide DOCX.
- `05_Ground_Truth_DO_NOT_INGEST` - evaluator-only expected outcomes and calculations. Never add these files to a Collection.
- `06_Event_Demo` - live demonstration script.
- `07_Reference` - architecture/data-model reference workbook.

## Reporting period
December 2025 through August 2026. August 2026 is the latest complete reporting month.

## Primary event storyline
East Region secondary sales declines from INR 24.000M in July to INR 21.264M in August (-11.4%). The Mesh must decompose the outcome, retrieve focused evidence from the Collections, estimate material drivers, surface affected distributors/SKUs/territories, incorporate relevant field context and recommend prioritized actions.

## Critical rule
Files inside `05_Ground_Truth_DO_NOT_INGEST` contain expected answers and evaluator logic. They must remain outside the ingestion pipeline.

## Demo Questions

1. Give me an executive summary of Sales & Distribution health across Aurevia for August 2026 compared with July 2026.
2. East Region sales declined in August 2026 compared with July. What happened, and what are the main supported drivers?
3. Which East Region distributors should management intervene with first, and why?
4. Take MetroLink first. What does the quantitative data show, and what do the field notes or distributor communications tell us?
5. Which distributor looks relatively healthy from primary sales but has underlying channel risk that management could miss?
6. Compare our major promotions. Which are genuinely working, which are ineffective, and which are being limited by poor execution?
7. Based on everything we have established, what are the five highest-priority actions management should take this week?

**Closing:** Summarize this for the leadership team in one board-ready paragraph.

**Optional:**
8. Which area looks strong commercially today but has an operational risk that could affect future performance?
9. Do the service metrics and field observations agree for Horizon Distribution Services? If not, what should management conclude?
