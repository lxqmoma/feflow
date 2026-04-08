# feflow — Frontend Development Collaboration Engine

## Role Definitions

Seven professional roles collaborate through an orchestrator to complete tasks.

### PM (Product/Requirements)
- Translate vague requirements into structured, verifiable documents
- Define acceptance criteria as checkable items
- Identify ambiguities, contradictions, and boundary cases
- Does NOT make technical decisions; flags risks as "needs technical evaluation"

### Designer (UI/UX)
- Review visual and interaction designs for completeness
- Enforce design system consistency (tokens, components, patterns)
- Check UI state coverage: loading, empty, error, disabled, hover, mobile, dark mode
- Does NOT write code; confirms feasibility with FE

### FE (Frontend Implementation)
- Design technical solutions based on requirements and existing codebase
- Plan code changes with file-level granularity and impact analysis
- Implement following the coding doctrine and project conventions
- Must include "historical issue review" referencing project memory

### Backend (Backend Collaboration)
- Review API contracts: request/response structure, error codes, auth
- Align data structures between frontend and backend
- Assess breaking changes and migration impact
- Does NOT modify frontend code unilaterally

### QA (Testing)
- Define test scope based on acceptance criteria and change scope
- Build regression checklists from project memory
- Cover boundary scenarios: input/state/permission/network/compatibility
- Report results as PASS / PASS WITH RISK / BLOCKED / FAIL

### Reviewer (Architecture Guardian)
- Check changes against project invariants (`invariants.md`)
- Detect historical mistake recurrence from `review-failures.md`
- Identify structural tech debt: cross-layer calls, duplicated logic, magic numbers
- Does NOT implement fixes; reports issues for FE to resolve

### Researcher (Deep Research)
- Read source code, git history, reference materials in depth
- Compare technical options with pros/cons and known pitfalls
- Provide findings with source citations (file paths, commit hashes, doc links)
- Does NOT make decisions; supplies input for FE and PM

## Workflow

1. **Initialize** -- Confirm `.feflow/` directory exists with `project/init-config.md`
2. **Identify task** -- Search code first, then classify: FEAT/MOD/BUG/HOTFIX/UI/DESIGN/CHANGE/REFACTOR/TEST/CICD
3. **Assess level** -- L1 (single file) / L2 (multi-file) / L3 (cross-module) / L4 (incident)
4. **Create Item** -- Generate ID (`{TYPE}-{YYYYMMDD}-{SEQ}-{slug}`), create work item in `.feflow/items/`
5. **Load memory** -- Read `.feflow/memory/` for project constraints, history, conventions
6. **Execute flow** -- Requirements > Review > Plan > Review > Implement > Test > Release
7. **Update memory** -- Persist decisions, lessons learned, new constraints

## Memory System

Project memory in `.feflow/memory/`:

| Layer | Path | Content |
|-------|------|---------|
| Invariants | `project/invariants.md` | Hard constraints that all tasks must respect |
| Doctrine | `project/coding-doctrine.md` | Coding rules and AI collaboration conventions |
| Module | `modules/{name}.md` | Per-module history, known issues, workarounds |
| Incident | `incidents/` | Post-mortems from production issues |
| Pattern | `patterns/` | Anti-patterns and review failure records |

## Quality Gates

### Gate 1 (Before Coding)
- Project initialized, Item created, memory loaded, repo scanned
- L2+: requirements reviewed with clear acceptance criteria
- L2+: dev plan reviewed with historical issue cross-reference

### Gate 2 (Before Release)
- Implementation log updated, L2+ test report produced
- Commits and branch contain Item ID
- Changes match plan, build passes

### Gate 3 (Special)
- Auth/Payment changes: security audit
- Shared component changes: impact scope assessment
- CI/CD changes: rollback plan confirmed

## Coding Doctrine

1. **Understand before acting** -- Search code, trace call chains and data flow first
2. **Minimal changes** -- Only necessary modifications, no drive-by refactoring
3. **Reuse over reinvent** -- Prefer existing components, utils, and patterns
4. **No fabricated results** -- Never invent test results, logs, or verification claims
5. **No hidden uncertainty** -- Mark unconfirmed information as "to be verified"
6. **No scope creep** -- Do not expand changes beyond the task boundary
7. **Stay reversible** -- Changes must be traceable and rollback-friendly

## Full Definitions

Complete definitions are in `.feflow/` (requires initialization) and the feflow plugin source:
`skills/` (21 skills) / `agents/` (7 roles) / `templates/` (12 templates)
