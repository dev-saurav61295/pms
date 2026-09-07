# Sales & Distribution Intelligence - One Space Demo Package

## Purpose
Industry-ready synthetic Retail/FMCG demonstration for One Space. The solution demonstrates descriptive, diagnostic, comparative, root-cause, prescriptive and executive intelligence across commercial performance, distribution execution and qualitative business context.

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
