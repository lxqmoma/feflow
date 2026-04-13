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

Pause only for real ambiguity, destructive operations, production impact, or meaningful direction choice.

## Relationship With Other Workflows

feflow should coexist with general-purpose planning, review, and coding workflows. It is a specialization layer, not a blanket override.

## Coding Doctrine

1. Search before deciding.
2. Prefer minimal, reversible changes.
3. Reuse existing local patterns.
4. Do not fabricate evidence or certainty.
5. Separate confirmed facts from inference.
6. Keep governance proportional to risk.
