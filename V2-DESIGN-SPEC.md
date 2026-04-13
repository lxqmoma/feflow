# feflow v2 Design Specification

Status: Draft
Version: 0.1
Scope: Product, interaction, and workflow architecture

## 1. Background

`feflow` v1 is a frontend development collaboration engine built around six core objects:
`Item`, `Flow`, `Memory`, `Evidence`, `Gate`, and `Role`.

Its current design is strong in governance but weak in default interaction quality:

- task handling is routed into workflow orchestration too early
- internal control objects are too visible to the user
- read-only analysis tasks are over-processed as delivery tasks
- the system behaves like a workflow engine before it behaves like an assistant

This document defines `feflow` v2 as a product and architecture shift, not a prompt wording cleanup.

## 2. Problem Statement

The main issue in v1 is not lack of capability. The main issue is default posture.

Today, once a project is initialized, session startup context strongly biases the assistant toward
`orchestrator`-first task handling. That creates four systemic problems:

1. Governance is applied before routing.
2. Delivery workflow is treated as the default mode for all development-related requests.
3. Internal orchestration stages are exposed to the user as explicit interaction steps.
4. The assistant optimizes for process visibility instead of task momentum.

As a result, `feflow` v1 is good at controlled delivery but poor at everyday collaboration quality.

## 3. Product Thesis

`feflow` v2 is a frontend engineering governance coprocessor.

It MUST NOT replace the assistant's default behavior for low-risk or read-only work.
It MUST provide stronger governance than a general-purpose assistant when a task crosses into
real delivery, elevated risk, or incident handling.

The product thesis is:

- default to helping, not taking over
- default to hidden orchestration, not visible process narration
- escalate governance by risk, not by mere task presence

## 4. Goals

`feflow` v2 MUST achieve the following:

1. Restore a high-quality assistant experience for read-only and low-risk tasks.
2. Preserve strong delivery governance for high-risk frontend work.
3. Keep evidence and memory loops as durable backend capabilities.
4. Separate internal workflow stages from user-visible confirmation points.
5. Make incident handling the fastest path in the system.
6. Coexist cleanly with `superpowers` instead of competing for the default entry path.

## 5. Non-Goals

`feflow` v2 does not aim to:

- replace a general-purpose planning or brainstorming layer
- itemize every engineering request
- require full documentation for every code change
- expose role simulation as the default user experience
- solve interaction quality by adding more flows, prompts, or templates

## 6. Design Principles

### 6.1 Search-First

The system MUST search code before making implementation claims.
Any assertion that a file, pattern, or module does not exist MUST be backed by search evidence.

### 6.2 Evidence-First

Completion quality MUST be grounded in observable evidence, not self-declaration.

### 6.3 Minimal Visible Process

Internal orchestration MAY be complex. User-visible process MUST remain minimal.

### 6.4 Risk-Driven Escalation

Governance strength MUST increase with risk, not with arbitrary workflow uniformity.

### 6.5 Hidden Internal Orchestration

Internal terms such as `skill`, `hook`, `agent`, `gate`, and `orchestrator` MUST NOT be part of
the default user-facing dialogue.

### 6.6 Memory as Index

Memory MUST improve task quality by retrieving high-signal constraints and prior lessons.
It MUST NOT become a noisy archive that bloats context.

## 7. Mode Model

`feflow` v2 defines three primary modes.

### 7.1 Assist Mode

Purpose:

- read a repository
- explain code
- audit a plugin
- locate risk
- review architecture
- produce design or refactor recommendations

Rules:

- MUST NOT create an `Item`
- MUST NOT run explicit gates
- MUST NOT require staged user approval
- MUST NOT require `.feflow/` initialization
- MUST behave like a strong read-only assistant

Typical outputs:

- repository summary
- architecture critique
- plugin evaluation
- design review
- risk map

### 7.2 Delivery Mode

Purpose:

- implement or modify code intended for delivery
- fix non-incident bugs
- refactor code
- ship UI improvements
- perform planned CI/CD changes

Rules:

- governance intensity MUST depend on risk level
- documentation MUST be proportional to risk
- the system MAY create an `Item`, but only when justified by risk or lifecycle needs

Sub-modes:

- `Delivery-L1`
- `Delivery-L2`
- `Delivery-L3`

### 7.3 Incident Mode

Purpose:

- hotfix
- rollback
- emergency mitigation
- restore service

Rules:

- speed takes priority over completeness
- safety and reversibility still apply
- governance artifacts MUST be backfilled after stabilization

## 8. Risk Model

`feflow` v2 defines five risk levels.

### 8.1 L0

Read-only tasks with no code modification intent.

Examples:

- "deeply understand this plugin"
- "review this repository"
- "explain this architecture"

Route:

- always `Assist`

### 8.2 L1

Low-risk delivery.

Examples:

- copy change
- local style fix
- single-file bugfix
- isolated UI polish

Route:

- `Delivery-L1`

### 8.3 L2

Moderate-risk delivery.

Examples:

- multi-file feature work
- component and store linkage
- API integration
- behavior change in a bounded area

Route:

- `Delivery-L2`

### 8.4 L3

High-risk delivery.

Examples:

- auth
- payment
- SSR
- global state
- routing architecture
- build system
- CI/CD pipelines
- cross-module refactor

Route:

- `Delivery-L3`

### 8.5 L4

Incident or emergency work.

Examples:

- production outage
- rollback
- P0 defect
- emergency security mitigation

Route:

- always `Incident`

## 9. Task Routing

### 9.1 Routing Inputs

The router MUST consider:

- task intent
- whether code modification is requested
- urgency
- risk keywords
- scope of impact
- reversibility of action

### 9.2 Router Outputs

The router MUST output:

- selected mode
- selected risk level
- whether an `Item` is required
- whether explicit user confirmation is required before execution

### 9.3 Router Rules

The routing order MUST be:

1. determine whether task is read-only or mutating
2. determine whether task is incident-like
3. determine risk level
4. apply minimum necessary governance

The routing order MUST NOT be:

1. assume workflow orchestration
2. create an item
3. ask for confirmation
4. then discover the task was read-only

### 9.4 Orchestrator Redefinition

In v2, `orchestrator` MUST become a mode router, not a default execution controller.

It MUST do only these four things:

1. classify mode
2. assess risk
3. select minimum necessary governance
4. hand off to the proper execution path

It MUST NOT automatically:

- create an `Item` for every task
- load full memory for every task
- run full repository scan for every task
- expose workflow stage transitions to the user

## 10. User Experience Contract

### 10.1 Hidden Control Plane

The default user-facing response MUST NOT mention:

- `skill`
- `hook`
- `agent`
- `orchestrator`
- `gate`
- `memory-load`
- `role-pm`, `role-fe`, `role-qa`, or similar internals

### 10.2 Limited Confirmation Policy

The system MUST pause for confirmation only when:

1. the task goal is materially ambiguous
2. the next step changes scope or direction in a meaningful way
3. the action is destructive, irreversible, or externally visible

The system MUST NOT pause merely because:

- a workflow stage has ended
- a document could be produced
- an internal role would normally hand off
- a non-destructive read step is about to begin

### 10.3 Default Visible Output Shape

User-facing updates SHOULD be constrained to:

- what is being examined
- what has been found
- what happens next
- why a decision is needed, if a decision is needed

## 11. Assist Mode Specification

### 11.1 Purpose

Assist Mode exists to restore strong everyday collaboration.

### 11.2 Behavior

The assistant MUST:

- read files directly
- search the codebase directly
- summarize findings directly
- produce critique directly

The assistant MUST NOT:

- create an `Item`
- require project initialization
- emit gate output
- ask serial `OK/continue` questions for low-risk reading tasks

### 11.3 Repo Intel

Assist Mode MUST have access to a repository intelligence layer that works even without `.feflow/`.

This layer SHOULD provide:

- stack detection
- directory structure summary
- git state
- hotspot files and modules
- basic risk signals

## 12. Delivery Mode Specification

### 12.1 Delivery-L1

Expected rhythm:

1. inspect relevant code
2. implement change
3. run proportionate verification
4. report result

Requirements:

- no mandatory full itemization
- no mandatory requirement review
- no mandatory plan review
- no mandatory full documentation set

Allowed artifacts:

- minimal implementation summary
- minimal verification summary

### 12.2 Delivery-L2

Expected rhythm:

1. inspect code and constraints
2. present a short execution plan
3. pause once for confirmation if needed
4. execute continuously
5. verify and summarize

Requirements:

- optional lightweight `Item`
- short plan
- short verification record

### 12.3 Delivery-L3

Expected rhythm:

1. inspect code, constraints, and memory
2. produce a decision packet
3. pause for explicit confirmation
4. execute in a continuous run
5. collect evidence and summarize

The decision packet MUST include:

- scope
- risk
- rollback strategy
- verification strategy
- affected areas

### 12.4 Delivery Artifact Policy

Artifacts in Delivery Mode MUST be risk-proportional.

| Artifact | L1 | L2 | L3 |
|----------|----|----|----|
| Item | optional | optional | required |
| requirement brief | no | optional | yes |
| dev plan | minimal | short | full |
| test report | minimal | short | full |
| evidence bundle | minimal | partial | full |

## 13. Incident Mode Specification

### 13.1 Purpose

Incident Mode exists to optimize for rapid stabilization.

### 13.2 Execution Contract

The assistant MUST:

- confirm incident reality quickly
- assess impact quickly
- apply the smallest effective fix
- verify recovery quickly
- capture missing governance artifacts after recovery

### 13.3 Deferred Governance

The following MAY be deferred until after stabilization:

- full root-cause writeup
- complete evidence bundle
- retrospective
- durable memory promotion

The following MUST NOT be deferred:

- rollback awareness
- minimum validation
- explicit user visibility on residual risk

## 14. Governance Primitives

### 14.1 Item

`Item` remains a first-class governance object, but MUST NOT be the default object for every task.

`Item` SHOULD be created when:

- a task is `Delivery-L3`
- a task spans multiple sessions
- a task requires evidence and memory retention
- a task has dependencies on other tracked work

### 14.2 Flow

Flows remain useful, but MUST be considered internal execution structures.
A flow stage transition MUST NOT automatically imply a user-facing prompt.

### 14.3 Gate

Gates remain useful, but MUST be evaluated internally by default.

Gate outcomes MUST support three levels:

- `silent-pass`
- `warn-but-continue`
- `hard-block`

Only `hard-block` SHOULD normally be surfaced as a user interruption.

### 14.4 Memory

Memory remains a durable backend capability.
It MUST be invoked selectively and economically.

### 14.5 Evidence

Evidence remains valuable, but collection SHOULD happen in the background where possible.

## 15. Memory Strategy

### 15.1 High-Trust Memory

Always low-volume, stable:

- `invariants`
- `coding-doctrine`

### 15.2 Medium-Trust Memory

Conditional and relevance-based:

- module memories
- patterns

### 15.3 Conditional High-Priority Memory

Only elevated in high-risk or high-similarity situations:

- incidents

### 15.4 Promotion Policy

Most lessons SHOULD start attached to the current task context.
Only repeated or high-severity lessons SHOULD be promoted into durable memory.

## 16. Evidence Strategy

### 16.1 Background Collection

Evidence collection SHOULD happen without constant user-facing narration.

### 16.2 Display Policy

Evidence SHOULD be shown explicitly only when:

- a task is closing
- the user asks for it
- an audit or review is being performed
- there is a discrepancy that affects trust

### 16.3 Evidence Levels

| Level | Scope |
|-------|-------|
| minimal | files changed, checks run, residual risk |
| partial | commit and test evidence |
| full | commits, PR, CI, release, retrospective |

## 17. Role Strategy

Roles remain useful as internal reasoning boundaries:

- PM
- FE
- QA
- Reviewer
- Researcher

However, role execution MUST be internal by default.

The user SHOULD normally receive:

- one merged understanding
- one merged execution plan
- one merged verification summary

The user SHOULD NOT receive role-by-role stage broadcasts unless explicitly requested.

## 18. Command Surface

`feflow` v2 SHOULD expose commands that map to modes instead of hidden workflow internals.

### 18.1 `/feflow:assist`

Read-only analysis entry.

Examples:

- understand this repository
- review this plugin
- explain this module

### 18.2 `/feflow:task`

Delivery entry.

Examples:

- implement feature
- fix bug
- refactor module

### 18.3 `/feflow:incident`

Incident entry.

Examples:

- hotfix production issue
- rollback
- emergency mitigation

### 18.4 `/feflow:scan`

Repository intelligence entry.
MUST work without `.feflow/`, with enhanced output when `.feflow/` exists.

### 18.5 `/feflow:memory`

Governance-specific memory view and maintenance.
Only enhanced when `.feflow/` is present.

## 19. File Migration Strategy

### 19.1 Files to Redefine First

- `hooks/session-start/detect.sh`
- `skills/orchestrator/SKILL.md`
- `adapters/generic/AGENTS.md`
- platform adapter rule files

These files define default posture and must be changed before detailed flow work.

### 19.2 Files to Keep but Re-scope

- `skills/flow-feature/SKILL.md`
- `skills/flow-modification/SKILL.md`
- `skills/flow-bugfix/SKILL.md`
- `skills/flow-refactor/SKILL.md`
- `skills/flow-ui-optimize/SKILL.md`
- `skills/quality-gate/SKILL.md`

These files remain useful for `Delivery` but must be risk-aware and less user-visible.

### 19.3 Files to Preserve as Backend Governance

- `skills/memory-load/SKILL.md`
- `skills/memory-update/SKILL.md`
- `skills/memory-decay/SKILL.md`
- `skills/item-orchestration/SKILL.md`
- `skills/evidence-chain/SKILL.md`
- `skills/backfill/SKILL.md`

These files are backend assets and should remain, with reduced default visibility.

### 19.4 Files to Split

- `skills/repo-scan/SKILL.md`
- `skills/project-init/SKILL.md`
- `skills/stack-detect/SKILL.md`

`repo-scan` SHOULD split into:

- `Repo Intel`
- `Delivery Repo Scan`

`project-init` SHOULD split into:

- project onboarding
- governance enablement

`stack-detect` SHOULD move under onboarding and explicit capability setup, not default task routing.

## 20. Rollout Plan

### Phase 0

Approve this spec.

### Phase 1

Rewrite default posture:

- startup hook behavior
- adapter rules
- orchestrator routing contract

### Phase 2

Introduce three explicit modes:

- Assist
- Delivery
- Incident

### Phase 3

Refactor delivery flows for risk-based governance.

### Phase 4

Split repository intelligence from governance state.

### Phase 5

Tune memory and evidence noise levels.

## 21. Success Metrics

The redesign is successful when:

1. read-only tasks complete without workflow friction
2. low-risk delivery tasks rarely need confirmation pauses
3. high-risk delivery tasks retain traceability and rollback quality
4. incident tasks recover faster than v1
5. user-visible internal control-plane terminology drops sharply
6. memory recall quality improves without context bloat

Suggested metrics:

- average confirmation count per L0/L1 task
- average turns to completion for L1 tasks
- percentage of L3 tasks with usable evidence bundles
- average time-to-stabilize in incident tasks
- percentage of responses exposing internal workflow terms

## 22. Risks

### 22.1 Under-Governance

If Assist or L1 routing is too permissive, real delivery work may escape governance.

Mitigation:

- conservative risk heuristics
- explicit high-risk keyword escalation

### 22.2 Over-Routing

If routing remains too conservative, v1 friction persists.

Mitigation:

- treat read-only intent as first-class
- evaluate mutability before workflow choice

### 22.3 Memory Noise

If promotion rules remain loose, memory quality will degrade.

Mitigation:

- stricter promotion thresholds
- better decay and supersession handling

### 22.4 Spec Drift

If documentation and live behavior diverge, prompt-driven systems degrade quickly.

Mitigation:

- define a clear source-of-truth file set
- update adapters and primary docs together

## 23. Open Questions

1. Should `Delivery-L1` create lightweight hidden items, or no items at all?
2. Should `Incident` be auto-routed from `/task`, or remain a separate explicit command?
3. Should `repo-scan` become two separate skills, or one dual-mode skill?
4. Should memory update remain append-only, or allow controlled amendment of stale entries?
5. How should backwards compatibility be handled for existing `.feflow/items/` structures?

## 24. Acceptance Criteria

This spec is accepted only if all of the following hold:

1. The system explicitly defines `Assist`, `Delivery`, and `Incident`.
2. Read-only tasks no longer require `.feflow/` to be useful.
3. Startup no longer hard-routes all development tasks into delivery orchestration.
4. User-facing interaction no longer exposes internal workflow terms by default.
5. Governance remains available and strong for high-risk delivery and incidents.

