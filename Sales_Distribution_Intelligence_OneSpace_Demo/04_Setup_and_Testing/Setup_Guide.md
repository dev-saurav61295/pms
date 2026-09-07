# Setup Guide - Sales & Distribution Intelligence

## 1. Create Tag & Taxonomy
Create/import the hierarchy in `02_Tag_Taxonomy/Tag_Taxonomy_Definition.md` or the XLSX version. Use stable business concepts only. Do not create tags from distributor IDs, outlet IDs, salesperson IDs, SKU IDs or month values.

## 2. Create connectors
Create three connectors:
1. `FMCG Commercial Data`
2. `FMCG Distribution Operations Data`
3. `FMCG Sales Business Documents`

## 3. Create Collections
### Collection A
- Name: `FMCG Commercial Performance`
- Slug/tool: `fmcg-commercial-performance`
- Connector: FMCG Commercial Data
- Ingestion ZIP: `01_FMCG_Commercial_Performance_Ingestion.zip`
- Prompt: `01_Commercial_Performance_Collection_System_Prompt.md`

### Collection B
- Name: `FMCG Distribution Execution`
- Slug/tool: `fmcg-distribution-execution`
- Connector: FMCG Distribution Operations Data
- Ingestion ZIP: `02_FMCG_Distribution_Execution_Ingestion.zip`
- Prompt: `02_Distribution_Execution_Collection_System_Prompt.md`

### Collection C
- Name: `FMCG Sales Business Context`
- Slug/tool: `fmcg-sales-business-context`
- Connector: FMCG Sales Business Documents
- Ingestion ZIP: `03_FMCG_Sales_Business_Context_Ingestion.zip`
- Prompt: `03_Sales_Business_Context_Collection_System_Prompt.md`

Assign the relevant taxonomy branches before sync/ingestion.

## 4. Sync / ingest
Ingest only the corresponding ZIP into each Collection. Confirm the dataset/document names are searchable after sync.

**Do not ingest `05_Ground_Truth_DO_NOT_INGEST`.**

## 5. Configure Collection prompts
Apply the matching Collection-level system prompt. Collection agents should act as evidence specialists, not as user-facing cross-source reasoners.

## 6. Create Mesh Agent
- Name: `Sales & Distribution Intelligence`
- Bind the three Collections as tools using their slugs.
- Apply `04_Sales_Distribution_Intelligence_Mesh_System_Prompt.md`.

## 7. Smoke tests before event testing
Ask direct evidence questions against each Collection first:
- Commercial: August secondary sales for East versus July.
- Execution: August stock availability for MetroLink Consumer Trade.
- Context: retrieve the MetroLink section from Distributor Review Notes.

Then test the Mesh with: `Sales in the East Region declined significantly this month. Why?`

## 8. Expected orchestration behavior
The Mesh should:
1. resolve August 2026 versus July 2026;
2. retrieve commercial movement and contributors;
3. narrow to material entities;
4. retrieve grouped operational drivers for those entities;
5. perform targeted follow-up if a material evidence family was omitted;
6. retrieve qualitative context only when useful;
7. synthesize estimated drivers with traceability;
8. preserve context for follow-up questions.

## 9. Event readiness
Use `Testing Guide.docx`, `Test_Question_Bank.xlsx` and the evaluator-only ground-truth folder to validate before the event. Run the scripted flow in `06_Event_Demo/Event_Demo_Script.md` only after the critical tests pass.
