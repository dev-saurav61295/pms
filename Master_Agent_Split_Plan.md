Architecture summary
Master — Project Management System Agent 2
* Type: Master Agent · Pattern: Composite Supervisor (delegates only, no direct tool calls)
* Tools bound: none
* Linked sub-agents: retrieval-sub-agent (order 1), verifier-sub-agent (order 2)
* Prompt: the full governed prompt — project-context resolution (asks which project when unscoped), version/count/authority disclosures, delegation flow
* Strategic Context Inheritance: turned OFF (was the source of the identity-leak bug — see below)
* Status: deployed, active, tested
Sub-agent 1 — Retrieval Sub-Agent (developed)
* Type: Sub Agent · Pattern: ReAct (reason⇄act loop — enables retry-on-miss)
* Tools bound: project-management-system-data (only agent in the chain that touches the tool)
* Prompt: query-construction discipline (preserve exact entity names, no identity terms in queries, retry once with name variants on miss), outputs draft answer + chunks inlined for the verifier
* Inheritance: OFF
* Status: deployed, active, tested — confirmed fixing the "no evidence for Jio Brahmos" regression via the retry loop
Sub-agent 2 — Verifier Sub-Agent (developed)
* Type: Sub Agent · Pattern: ReAct
* Tools bound: none (works only on chunks passed to it — this was the field that got mis-set twice during build and is now correctly empty)
* Prompt: groundedness check — verifies every claim in the draft traces to a retrieved chunk, strips/corrects overreach, enforces the no-exact-count / no-version-authority disclosures
* Inheritance: OFF
* Status: deployed, active, tested — confirmed receiving chunks from the retrieval sub (the biggest open architectural risk going in) and correctly hedging at least one count answer