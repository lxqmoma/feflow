[中文](./README.md)

# feflow

Frontend development governance for coding assistants.

feflow v2 is built around one idea:

**the default experience should feel like a strong assistant, while governance should appear only when the task actually needs it.**

## What feflow is for

feflow focuses on gaps that appear in real frontend delivery work:

- persistent project memory
- durable task tracking
- evidence-backed completion
- incident and rollback handling
- governance for cross-module and release-sensitive changes

It keeps those capabilities, but stops forcing them onto every request.

## Three Modes

### Assist

For read-only work:

- repo understanding
- architecture explanation
- workflow critique
- plugin evaluation
- risk analysis

No `.feflow/` workspace is required, and no Item should be created by default.

### Delivery

For actual output:

- code changes
- config changes
- tests
- docs
- scripts and workflow updates

Governance depth is risk-based:

- **L1**: usually direct execution
- **L2**: lightweight governance helps
- **L3**: stronger tracking and verification are expected

### Incident

For urgent failures:

- production incidents
- hotfixes
- rollback paths
- release breakages

Stabilize first, backfill process artifacts later.

## Commands

| Command | Purpose |
|---------|---------|
| `/feflow:assist` | Read-only analysis path |
| `/feflow:task` | Delivery path |
| `/feflow:incident` | Incident and hotfix path |
| `/feflow:scan` | Repository intelligence |
| `/feflow:init` | Initialize persistent governance workspace |
| `/feflow:memory` | View or manage persistent project memory |

## When Initialization Is Required

Run `/feflow:init` only when you want full governance features such as:

- persisted Items
- project memory
- evidence storage
- dependency graphs and dashboards

Initialization is not required for:

- reading a repo
- explaining code
- critiquing architecture
- evaluating a plugin
- many L1 delivery tasks

## Relationship With Superpowers

feflow should complement, not mechanically override, general-purpose assistant workflows.

The target shape is:

- small tasks feel as direct as Superpowers
- complex tasks gain stronger governance than a generic assistant
- incidents route into recovery faster than a generic plan-first workflow

## Repository Layout

```text
feflow/
├── skills/
├── agents/
├── commands/
├── adapters/
├── hooks/
├── scripts/
├── templates/
├── examples/
├── README.md
└── CLAUDE.md
```

## Example Workspace

A minimal v2 workspace example is included so you can inspect what `.feflow` artifacts should look like under the new model:

- [`examples/minimal-v2-workspace/README.md`](./examples/minimal-v2-workspace/README.md)

## Local Smoke Check

The repository also includes a minimal smoke check so you can verify that the critical v2 entry points still exist and that obvious v1-style workflow language has not crept back into the core path:

```bash
./scripts/smoke-v2.sh
```

## Dogfood Acceptance

In addition to the static smoke check, the repo includes a behavior acceptance suite for manually validating `Assist / Delivery-L1 / Delivery-L3 / Incident` interactions against realistic prompts:

- [`V2-ACCEPTANCE-SUITE.md`](./V2-ACCEPTANCE-SUITE.md)

## Principle

feflow still stands for "get it right", but v2 interprets that in a risk-proportional way:

- be flexible about process depth
- stay traceable where traceability matters
- preserve important memory
- keep outputs handoff-ready
- handle messy codebases pragmatically
- require evidence only when evidence adds real value

## License

[MIT](./LICENSE)
