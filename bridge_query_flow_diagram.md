# Query Flow Diagram

This flow diagram illustrates the step-by-step process of how a query (question) from an AI Agent is handled by the backend pipeline (`query_pipeline`).

```mermaid
flowchart TD
    %% Entry Point
    Start([Query Request from Agent])
    
    %% Server Precheck
    PreCheck[1. Server Precheck <br/> Initialize Pipeline State]
    Start --> PreCheck
    
    %% Tool Selection
    ToolSelect[2. Tool Selection <br/> Fetches tools & Uses Intent Classification <br/> to match a tool]
    PreCheck --> ToolSelect
    
    %% FAQ Check
    subgraph FAQ [3. FAQ Engine Check]
        direction TB
        FAQ_Check{Is there an <br/> FAQ Match?}
        FAQ_Exact[Exact Match]
        FAQ_Semantic[Semantic Match <br/> Vector Search]
        
        FAQ_Resolve{Resolution Type}
        FAQ_Direct[Static Response / Direct]
        FAQ_Tool[Tool Call Binding]
        FAQ_Redirect[Redirect Message]
        
        FAQ_Check -->|Yes| FAQ_Exact
        FAQ_Check -->|No Exact, Check Embs| FAQ_Semantic
        FAQ_Exact --> FAQ_Resolve
        FAQ_Semantic -->|Above Threshold| FAQ_Resolve
    end
    
    ToolSelect --> FAQ_Check
    
    %% FAQ Short Circuit
    FAQ_Resolve -->|Static| FAQ_Direct
    FAQ_Resolve -->|Tool| FAQ_Tool
    FAQ_Resolve -->|Redirect| FAQ_Redirect
    
    FAQ_Direct --> End_ShortCircuit([Return Early Response])
    FAQ_Tool --> End_ShortCircuit
    FAQ_Redirect --> End_ShortCircuit
    
    %% Response Cache
    RespCacheCheck{4. Response <br/> Cache Hit?}
    FAQ_Check -->|No Match| RespCacheCheck
    FAQ_Semantic -->|Below Threshold| RespCacheCheck
    
    RespCacheCheck -->|Yes| End_ShortCircuit
    
    %% RBAC & Security
    RBAC[5. Policy Compile <br/> Compile User RBAC Constraints]
    RespCacheCheck -->|No| RBAC
    
    %% NL2SQL Cache
    NL2SQL_Check{6. NL2SQL Cache Hit?}
    RBAC --> NL2SQL_Check
    
    %% Build SQL
    subgraph BuildSQL [7. Build SQL Phase]
        direction TB
        CheckToolSQL{Does Tool have <br/> Base SQL / Semantic View?}
        ApplyRBAC_View[Apply RBAC to View SQL]
        
        GraphRetriever[Retrieve Schema Context <br/> Check Relationships in Neo4j Graph]
        LLM_SQL[LLM Generates SQL]
        StoreNL2SQL[Store in NL2SQL Cache]
        
        CheckToolSQL -->|Yes| ApplyRBAC_View
        CheckToolSQL -->|No| GraphRetriever
        GraphRetriever --> LLM_SQL
        LLM_SQL --> StoreNL2SQL
    end
    
    NL2SQL_Check -->|Yes| CheckToolSQL
    NL2SQL_Check -->|No| CheckToolSQL
    
    %% If NL2SQL Cache hit, it skips LLM Generation and uses cached SQL directly (merged logic in BuildSQL)
    %% To make diagram clear:
    
    %% Execute & Summarize
    ExecuteSummarize[8. Execute Query & <br/> Summarize Results via LLM]
    ApplyRBAC_View --> ExecuteSummarize
    StoreNL2SQL --> ExecuteSummarize
    
    %% Store Cache
    StoreRespCache[9. Store Response Cache]
    ExecuteSummarize --> StoreRespCache
    
    %% Final
    FinalResponse([Return Final Summarized Response])
    StoreRespCache --> FinalResponse
    
    %% Styles
    classDef step fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    classDef decision fill:#fff3e0,stroke:#f57c00,stroke-width:2px;
    classDef endNode fill:#e8f5e9,stroke:#388e3c,stroke-width:2px;
    classDef subg fill:#f3e5f5,stroke:#7b1fa2,stroke-width:2px;

    class PreCheck,ToolSelect,RBAC,ExecuteSummarize,StoreRespCache step;
    class FAQ_Check,FAQ_Resolve,RespCacheCheck,NL2SQL_Check,CheckToolSQL decision;
    class End_ShortCircuit,FinalResponse endNode;
```

## Detailed Flow Correction

Based on the actual pipeline execution (`src/retrieval/pipeline/pipeline_orchestrator.py`), here is the verified order of execution:

1. **Server Precheck**: Initializes the pipeline state.
2. **Tool Selection / Intent Classification**: Fetches available tools and selects the best one using intent classification.
3. **FAQ Engine**:
   - Tries for an **Exact Match** or a **Semantic Match** via embeddings.
   - If a match is found, it evaluates the resolution type:
     - **a. Direct (Static Response)**
     - **b. Tool Call Binding** (Executes a specific tool)
     - **c. Redirect**
   - *Short circuits (returns response)* if an FAQ resolves the question.
4. **Response Cache Check**: Looks to see if this exact query already has a stored and fully summarized response. *Short circuits* if found.
5. **RBAC Policy Compile**: Compiles data-access constraints specific to the user.
6. **NL2SQL Cache Check**: Looks for a cached SQL template to skip LLM generation later.
7. **Build SQL**: 
   - Checks if the selected tool already has predefined SQL (like a Semantic View). If so, it applies the RBAC policies to that SQL.
   - If no predefined SQL or NL2SQL cache exists, it **checks for Relationships in the Graph** (Retrieves schema context) and asks the LLM to generate the SQL.
   - It caches the generated SQL back into the NL2SQL cache.
8. **Execute & Summarize**: Runs the finalized SQL query securely and uses the LLM to generate a natural language summary from the raw data rows.
9. **Store Response Cache**: Caches the final generated response for future matching.
