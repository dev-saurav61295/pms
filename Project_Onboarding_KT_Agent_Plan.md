# Project Onboarding / KT Agent Plan

## 1. Objective

Build a **Project Onboarding / KT Agent** for the Project Management System (PMS) that helps new project members, managers, and stakeholders quickly understand a project without depending heavily on manual Knowledge Transfer (KT) sessions.

The agent should combine:

- **RAG-based access to unstructured project knowledge**
- **MCP-based access to structured PMS data**

### Core Value Proposition

> Enable any authorized user to understand both **what the project is about** and **what is happening in the project right now** through a conversational interface.

A simple positioning statement:

> **Instead of asking five people to understand a project, ask the Project Onboarding Agent.**

---

## 2. Why This Agent Is Needed

Today, when a new team member joins a project, they often depend on:

- Project Managers
- Business Analysts
- Architects
- Developers
- QA Leads
- Existing team members

for project context and KT.

This creates several challenges:

- Manual KT consumes senior team members' time
- Information is scattered across documents and PMS screens
- New team members take time to locate the right information
- Knowledge may be lost when key employees leave
- Project understanding may vary from person to person
- Current project status may not be available in project documents
- Important historical decisions may be difficult to trace

The Project Onboarding / KT Agent solves these problems by creating a **self-service project knowledge and operational intelligence layer**.

---

## 3. Data Sources Required

The agent should use **both File Data and Database Data**.

### File / Unstructured Data

Typical sources include:

- BRD
- FRD
- SOW
- Project Charter
- Architecture Documents
- API Documentation
- Technical Design Documents
- User Stories
- Meeting Minutes / MOMs
- Decision Logs
- Project Plans
- Policies
- Security Documents
- Deployment Documents
- SOPs
- Release Notes
- Test Strategy
- Customer Requirements
- Compliance Documents

This information will primarily be accessed through the **RAG layer**.

### Structured PMS / Database Data

Typical sources include:

- Project Master
- Project Status
- Project Team
- Employees
- Roles
- Resource Allocations
- Tasks
- Milestones
- Sprints
- Risks
- Issues
- Dependencies
- Timesheets
- Effort
- Budget
- Progress
- Releases
- Open Actions

This information will primarily be accessed through the **MCP Bridge**.

---

## 4. Key Capabilities

### 4.1 Project Overview

The agent should provide a concise project overview including:

- Project name
- Customer
- Project objective
- Scope
- Current phase
- Project status
- Completion percentage
- Start and end dates
- Technology stack
- Project Manager
- Key stakeholders
- Current milestone
- Major risks
- Current blockers

Example question:

> Give me an overview of Project ABC.

---

### 4.2 Role-Based Project Onboarding

The onboarding experience should be tailored based on the user's role.

| Role | Information to Emphasize |
|---|---|
| Developer | Architecture, modules, APIs, coding standards, repositories, technical dependencies, current tasks |
| QA Engineer | Requirements, acceptance criteria, environments, test strategy, defects, release plan |
| Business Analyst | Business objectives, scope, requirements, stakeholders, open questions, decisions |
| Project Manager | Status, milestones, risks, issues, resources, dependencies, budget, delivery plan |
| Architect | Architecture, integrations, NFRs, technology choices, security decisions |
| DevOps Engineer | Infrastructure, environments, CI/CD, cloud setup, deployment process |
| Senior Management | Project health, milestones, risks, customer status, commercials, major dependencies |
| Customer Stakeholder | Objectives, roadmap, status, deliverables, major milestones |

Example:

> I am joining Project ABC as a backend developer. Onboard me.

---

## 5. Project KT Pack

The agent should be able to generate a structured **Project KT Pack**.

Recommended sections:

1. Project Snapshot
2. Business Context
3. Project Objectives
4. In-Scope Items
5. Out-of-Scope Items
6. Solution Overview
7. Functional Overview
8. Architecture
9. Technology Stack
10. Integrations
11. Project Team
12. Stakeholders
13. Current Project Status
14. Current Phase
15. Completed Milestones
16. Upcoming Milestones
17. Current Sprint / Tasks
18. Risks
19. Issues
20. Dependencies
21. Important Historical Decisions
22. Open Actions
23. Security / Compliance Considerations
24. Environments
25. Deployment Process
26. Release Process
27. Ways of Working
28. Important Project Documents
29. Project Terminology
30. First-Week Guidance for New Joiners

---

## 6. Conversational KT Experience

The agent should allow the user to continue asking project-specific questions after the initial onboarding.

Example questions:

- What exactly does this project do?
- Who is the customer?
- What problem are we solving?
- What is in scope?
- What is out of scope?
- Who is the Project Manager?
- Who is the technical architect?
- Who should I contact for API integration?
- What architecture are we using?
- What is the technology stack?
- Explain the authentication flow.
- What external APIs are integrated?
- What are the major modules?
- What is currently under development?
- What is the current project status?
- What milestone is coming next?
- Which milestones are delayed?
- What are the biggest project risks?
- What are the current blockers?
- Why is the current milestone delayed?
- What decisions were made around authentication?
- What are the major dependencies?
- What tasks are currently assigned to the backend team?
- Which documents should I read first?
- Summarize the latest project decisions.
- What should I understand before my first customer meeting?
- What changed in the project recently?

---

## 7. Recommended Architecture

```text
                    User
                      |
                      v
              Onboarding / KT Agent
                      |
              Intent Detection
                      |
              User / Role Context
                      |
          +-----------+------------+
          |                        |
          v                        v
     RAG Service                MCP Bridge
          |                        |
          v                        v
 Project Documents             PMS Database
          |                        |
 BRD / SOW / MOM               Projects
 Architecture                  Tasks
 Requirements                  Milestones
 Policies                      Resources
 Decision Logs                 Risks
 Technical Docs                Issues
 API Docs                      Timesheets
 Test Docs                     Allocations
                               Sprints
                               Releases
          |                        |
          +-----------+------------+
                      |
                      v
              Agent Reasoning
                      |
                      v
             Contextual KT Answer
```

---

## 8. Routing Logic

The agent should dynamically decide which source to use.

### RAG-Only Queries

Use RAG when the answer is mainly available in documents.

Examples:

- What was agreed for authentication?
- What is the solution architecture?
- What are the non-functional requirements?
- What is in scope according to the SOW?
- What security requirements were documented?

### MCP-Only Queries

Use MCP when the answer depends on current structured PMS data.

Examples:

- Who is currently assigned to the project?
- What is the current project status?
- Which tasks are overdue?
- What is the next milestone?
- What risks are currently open?

### RAG + MCP Queries

Use both when the user needs current facts plus project context.

Examples:

- Why is the current milestone delayed?
- Are the current risks already mentioned in the project plan?
- Has the project deviated from the original delivery plan?
- Which documented dependencies are affecting current tasks?
- What changed between the original plan and the current project status?

---

## 9. Handling Historical vs Current Information

The agent must distinguish between:

- **Original / documented information**
- **Current / operational information**

Example:

If the SOW says:

> Planned delivery date: 1 October

and the PMS says:

> Current forecast delivery date: 20 October

the agent should answer clearly:

> The original SOW planned delivery for 1 October. According to the current PMS status, the forecast delivery date is now 20 October.

The agent should never silently mix historical and current information.

---

## 10. RBAC and Security

The Project Onboarding / KT Agent must respect the same access permissions as the PMS.

### Principle

> The AI Agent must not provide access to information that the user is not authorized to access through the PMS.

Examples:

### Developer

May access:

- Requirements
- Architecture
- Technical documentation
- Assigned tasks
- Project status
- Technical dependencies

May not access:

- Employee salary
- Commercial rates
- Customer contract values
- Sensitive financial information

### Project Manager

May have broader access to:

- Project status
- Resources
- Risks
- Milestones
- Effort
- Project financial data, where authorized

### Leadership

May access:

- Portfolio status
- Project health
- Strategic risks
- Customer status
- Commercial information, where authorized

The agent should enforce:

- User authentication
- Project-level access
- Role-level access
- Document-level access
- Database field-level restrictions where required
- Audit logging
- Source traceability
- Tool-level permission controls

---

## 11. Source Citations and Traceability

Every important answer should identify its source whenever practical.

Examples:

- Source: Project SOW
- Source: Architecture Document v2.1
- Source: Latest Project Status in PMS
- Source: Risk Register
- Source: MOM dated 12 August 2026

This increases trust and allows users to verify the answer.

---

## 12. Recommended MVP

Avoid implementing every capability in Phase 1.

### MVP Scope

Build these six capabilities first:

1. **Project Overview**
2. **Role-Based Project Onboarding**
3. **Ask Questions About Project Documents**
4. **Current Project Status**
5. **Team, Milestones, Risks, Issues and Tasks**
6. **Generate Project KT Summary**

### MVP User Journey

1. User logs into PMS
2. User opens the Project Onboarding Agent
3. Project is automatically detected or selected
4. User role is detected from PMS
5. Agent generates a role-specific introduction
6. Agent recommends important documents
7. User asks follow-up questions
8. Agent retrieves information using RAG, MCP, or both
9. Answers contain relevant source references
10. User can generate a KT summary

---

## 13. Example User Experience

### Scenario

A developer joins Project Liskart.

The agent could respond:

> Welcome to the Liskart project.
>
> You are joining during the Development phase.
>
> The project is currently 58% complete.
>
> As a backend developer, you should first understand:
>
> - Backend architecture
> - Authentication
> - Product catalogue
> - API integrations
> - Database design
> - Development standards
>
> There are currently 23 active development tasks and 3 critical dependencies.
>
> Recommended documents:
>
> - Architecture Overview
> - API Specification
> - Development Guidelines
> - Latest Sprint Plan
>
> You can ask me anything about the project.

The user can then ask:

> Explain the authentication architecture.

or:

> Which backend tasks are currently blocked and why?

The first may use RAG.

The second may use both RAG and MCP.

---

## 14. Suggested Agent Flow

```text
User Question
      |
      v
Identify User
      |
      v
Identify Project
      |
      v
Check Authorization
      |
      v
Detect User Role
      |
      v
Understand Intent
      |
      +----------------------------+
      |             |              |
      v             v              v
     RAG           MCP         RAG + MCP
      |             |              |
      +-------------+--------------+
                    |
                    v
              Consolidate Answer
                    |
                    v
        Apply Security / Guardrails
                    |
                    v
             Add Source References
                    |
                    v
               Final Response
```

---

## 15. Suggested Functional Modules

The solution can be divided into the following modules:

### A. User Context Module

Responsible for:

- User identity
- Role
- Project access
- Team membership
- Permissions

### B. Project Context Module

Responsible for:

- Current project
- Project metadata
- Current project phase
- User's relationship with the project

### C. Intent Classification Module

Classifies questions into:

- Knowledge query
- Operational query
- Combined query
- Onboarding request
- KT summary request
- Role-specific briefing request

### D. RAG Retrieval Module

Responsible for:

- Document search
- Semantic retrieval
- Chunk ranking
- Source references

### E. MCP Tool Module

Responsible for controlled queries to:

- Projects
- Tasks
- Milestones
- Resources
- Risks
- Issues
- Allocations
- Sprints
- Timesheets
- Releases

### F. Response Synthesis Module

Responsible for:

- Combining structured and unstructured information
- Avoiding contradictions
- Differentiating current and historical information
- Role-specific presentation

### G. Guardrail Module

Responsible for:

- RBAC
- Query restrictions
- Sensitive data protection
- Prompt injection protection
- Tool invocation policies
- Source authorization

---

## 16. Phase-Wise Implementation Plan

### Phase 1 — Foundation / MVP

Focus:

- Project overview
- Basic role-based onboarding
- RAG access to project documents
- MCP access to basic project information
- Current status
- Team
- Tasks
- Milestones
- Risks
- Issues
- Source references
- RBAC

### Phase 2 — Advanced KT

Add:

- Project KT Pack generation
- First-week onboarding guidance
- Suggested reading
- Project glossary
- Decision history
- Dependency understanding
- Architecture explanations
- Integration summaries
- Meeting/MOM intelligence

### Phase 3 — Intelligent Project Copilot

Add:

- Project health intelligence
- Risk detection
- Resource intelligence
- Scope change impact
- Project governance
- Executive summaries
- Historical-vs-current comparison
- Recommendations and next-best actions

---

## 17. Success Metrics

The following KPIs can be used to measure the agent's value:

- Reduction in manual KT hours
- Reduction in PM/BA/Architect time spent answering repetitive questions
- Time taken for a new joiner to become productive
- Number of onboarding queries handled by the agent
- Percentage of questions answered without human intervention
- User satisfaction
- Answer accuracy
- Source citation accuracy
- Adoption rate
- Number of project documents accessed through the agent
- Reduction in project information search time
- Reduction in onboarding dependency on key individuals

---

## 18. Business Value

### Faster Onboarding

New employees can understand a project significantly faster.

### Reduced KT Effort

Senior employees spend less time repeating the same project explanations.

### Self-Service Knowledge

Employees can find answers without searching multiple documents or PMS screens.

### Knowledge Retention

Project knowledge remains available even if key employees leave.

### Current + Historical Context

The agent combines project documentation with live PMS information.

### Better Consistency

Everyone receives answers based on the same approved project knowledge and system data.

### Increased Productivity

New project members can become productive earlier.

### Better Decision Support

Managers can understand both project context and the current operational situation.

---

## 19. Positioning for Management

The Project Onboarding / KT Agent can be explained as:

> Today, whenever someone joins a project, significant time is spent by the PM, BA, architect, and existing team members conducting KT sessions and helping the new employee locate information.
>
> The Project Onboarding Agent brings together project documents and current PMS information to provide role-specific, self-service KT.
>
> This helps reduce onboarding time, reduce dependency on key individuals, preserve project knowledge, and make new team members productive faster.

### One-Line Pitch

> **Instead of asking five people to understand a project, ask the Project Onboarding Agent.**

---

## 20. Long-Term Vision

The Project Onboarding Agent can eventually evolve into a broader **Project Copilot**.

```text
                Project Copilot
                       |
      +----------------+----------------+
      |                |                |
      v                v                v
 Knowledge         Operational      Predictive
 Intelligence      Intelligence     Intelligence
      |                |                |
      v                v                v
    RAG            MCP Bridge      Health / Risk
                                      Agents
```

Future capabilities can include:

- Project Health Agent
- Risk & Dependency Intelligence
- Resource Planning
- PMO Governance
- Executive Reporting
- Scope Change Impact Analysis
- Project Estimation
- Timesheet & Effort Intelligence

The goal is to evolve the PMS from:

> **A system where users search for project information**

to:

> **An intelligent project platform that understands project knowledge, current status, risks, and recommended actions.**
