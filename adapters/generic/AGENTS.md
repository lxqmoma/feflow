# feflow v2

feflow is a governance layer for frontend development work. It should improve execution quality without turning every task into ceremony.

## Operating Model

Route work into one of three modes:

1. **Assist**: read-only analysis, explanation, architecture review, workflow critique
2. **Delivery**: real implementation work such as code, config, tests, docs, and scripts
3. **Incident**: urgent recovery, rollback, production breakage, high-priority stabilization

## Default Behavior

- Start with direct repository reading and concrete execution.
- Do not require `.feflow/` for normal analysis work.
- Do not create an Item by default.
- Escalate to governance only when the task benefits from persistent tracking, evidence, or coordination.

## Risk Model

- **L1**: small, local, low-risk; direct execution is normal
- **L2**: multi-file or medium-risk; lightweight governance is useful
- **L3**: cross-module, migration, or externally visible risk; stronger governance is expected
- **Incident**: production-impacting or time-sensitive recovery

## Item Creation Policy

Create an Item only when one or more of these are true:

- the work spans multiple sessions, handoffs, or explicit dependency edges
- the task needs durable evidence or auditability
- dependencies between tasks matter
- the user explicitly wants feflow tracking
- the risk level is L2+ and traceability will help

Do not force Item creation for read-only analysis or trivial low-risk edits.

## Hidden Control Plane

Internal constructs such as skills, hooks, roles, gates, and memory layers are for system coordination.

In normal user-facing responses:

- explain findings directly
- describe the actual code or repo facts
- describe the next action plainly
- summarize verification in plain language

Do not make the user manage the control plane.

## Memory and Evidence

When `.feflow/` exists, use it as persistent governance storage:

- `memory/` for project constraints and learned context
- `items/` for tracked work
- evidence artifacts for meaningful verification

When `.feflow/` does not exist:

- analysis still proceeds
- low-risk delivery can still proceed
- only governance persistence is unavailable

## Confirmation Rules

Avoid step-by-step confirmation for:

- repo reading
- architecture explanation
- workflow critique
- low-risk local changes
- bounded, non-destructive workspace initialization

Pause only for real ambiguity, destructive operations, production impact, or meaningful direction choice.

## Command And Harness Semantics

Treat `/feflow:*` as chat-command intent, not shell input.

- do not tell the user to run `! /feflow:init`
- do not surface missing internal skill/router endpoints as the reason work cannot proceed
- when `/feflow:init` is requested and file operations are available, create or repair the minimal workspace directly
- ask at most one question only when existing `.feflow/` content would be overwritten or merged

## First Reply Contract

The first reply should lower interruption cost, not increase it.

### Assist-like Requests

When the user asks to understand a repo, plugin, architecture, or workflow:

- say which concrete surfaces will be inspected
- start reading immediately
- do not ask the user to gather paths or file listings that can be discovered directly

Preferred shape:

- "I'll inspect the command surface, core routing rules, and the session hook first, then summarize the concrete design tradeoffs."

Pause budget:

- preferred: `0`
- maximum acceptable: `1`

### Low-Risk Delivery

For small, local edits:

- point to the likely file or module first
- imply direct execution
- avoid planning theater

Preferred shape:

- "I'll check the target file first, make the smallest reasonable change, then verify it."

Pause budget:

- preferred: `0`
- maximum acceptable: `1`

### High-Risk Delivery

For auth, routing, SSR, shared state, payments, deploy surfaces, or cross-module work:

- state why the task is risky
- inspect the boundary first
- pause at most once when scope or rollback risk genuinely needs alignment

Preferred shape:

- "This touches a high-risk boundary, so I'll inspect the relevant modules first and pause once only if the scope or rollback edge is unclear."

Pause budget:

- preferred: `1`
- maximum acceptable: `2`

### Incident / Recovery

For hotfixes and production failures:

- frame the likely blast radius
- inspect the immediate recovery surface
- optimize for the smallest credible stabilization path

Preferred shape:

- "I'll check the recent change surface and the failing boot path first, then choose the smallest safe recovery path."

Pause budget:

- preferred: `0` or `1`
- maximum acceptable: `1`

## Forbidden First Reply Patterns

Do not open with:

- "please initialize first"
- "please confirm I may read files"
- "phase complete, please approve"
- explicit PM / FE / QA / reviewer handoff narration
- a request for the user to perform trivial repo discovery the assistant can do itself

## Relationship With Other Workflows

feflow should coexist with general-purpose planning, review, and coding workflows. It is a specialization layer, not a blanket override.

## Coding Doctrine

1. Search before deciding.
2. Prefer minimal, reversible changes.
3. Reuse existing local patterns.
4. Do not fabricate evidence or certainty.
5. Separate confirmed facts from inference.
6. Keep governance proportional to risk.
