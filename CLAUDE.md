# feflow v2

feflow is a frontend development collaboration engine. In v2, it should behave as a **governance capability**, not a mandatory wrapper around every user request.

## Core Thesis

The default user experience must feel closer to a strong coding assistant:

- read the repo directly
- answer directly when the task is analytical
- modify directly when the task is small and low risk
- escalate governance only when the work actually benefits from it

The system should optimize for:

1. low interruption
2. clear user-facing outcomes
3. risk-proportional process
4. traceability only where traceability pays for itself

## Three Modes

### 1. Assist

Use Assist mode for read-only or analysis-first work:

- understand a repository or plugin
- explain architecture, modules, or code paths
- critique workflow or prompt design
- review likely risks and maintenance issues
- summarize technical decisions from source files

Rules:

- do not require `.feflow/`
- do not create an Item by default
- do not force a staged workflow
- search and read files directly
- expose facts and reasoning clearly

### 2. Delivery

Use Delivery mode when the user wants a real output such as:

- code changes
- config changes
- tests
- docs updates
- scripts or workflow edits

Rules:

- start from direct execution, not ceremony
- decide governance by risk
- create an Item only when the task needs durable tracking, evidence, or dependency management

Risk guidance:

- **L1**: small, local, low-risk changes; usually no Item
- **L2**: multi-file or medium-risk work; Item recommended
- **L3**: cross-module, migration, or externally visible risk; Item expected

### 3. Incident

Use Incident mode for:

- production failures
- rollback decisions
- urgent regression isolation
- release/config/runtime breakages

Rules:

- stabilize first
- prefer the fastest credible recovery path
- backfill documentation and evidence after impact is controlled

## Hidden Control Plane

Internal constructs such as skill, hook, role, gate, Item, and memory layers are **control-plane concepts**.

User-facing responses should normally speak in plain language:

- what was read
- what is happening
- what the likely issue is
- what will be changed
- what was verified

Do not turn the internal control plane into the product surface.

## Confirmation Policy

Do not ask for step-by-step confirmation for normal reading, analysis, or low-risk execution.

Pause only when:

- the goal is materially ambiguous
- the change is destructive or hard to undo
- the task affects external/shared/production state
- there are multiple viable directions with different tradeoffs

## Relationship With Superpowers

feflow complements general-purpose workflows. It should not hard-block or hard-override general assistant behavior.

Preferred posture:

- use direct repository work for understanding and small tasks
- use feflow governance when the task genuinely needs orchestration, evidence, memory, or incident handling
- coexist with Superpowers-style planning, review, and implementation rather than replacing them mechanically

## Governance Primitives

feflow still supports its core primitives:

- **Item** for durable task tracking
- **Flow** for structured multi-stage work
- **Memory** for persistent project context
- **Evidence** for verification artifacts
- **Gate** for blocker-level checks
- **Role** for specialized perspectives

But these should be invoked selectively, not universally.

## Coding Doctrine

1. Search before deciding.
2. Prefer minimal, reversible changes.
3. Reuse local patterns before inventing new ones.
4. Do not fabricate evidence, verification, or certainty.
5. Separate confirmed facts from inference.
6. Keep governance proportional to risk.

## Initialization

`/feflow:init` is required only for full governance features that persist project memory, Items, and evidence in `.feflow/`.

It is not required for:

- repo reading
- code explanation
- architectural analysis
- workflow critique
- many L1 delivery tasks

## Current Command Intent

- `/feflow:assist` -> read-only analysis path
- `/feflow:task` -> delivery path
- `/feflow:incident` -> urgent recovery path
- `/feflow:scan` -> repository intelligence path
- `/feflow:memory` -> persistent project memory
- `/feflow:init` -> opt into full governance workspace
