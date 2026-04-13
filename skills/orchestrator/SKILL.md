---
name: orchestrator
description: Feflow v2 mode router. Routes work into Assist, Delivery, or Incident mode and applies the minimum necessary governance.
---

# Orchestrator — Feflow v2 Mode Router

`orchestrator` in v2 is a router, not the default visible workflow controller.

It sits **above** the host execution substrate.

In environments where `superpowers` already provides generic execution discipline, `orchestrator` should:

- reuse that discipline
- add frontend-specific routing and governance
- avoid competing for generic control-plane authority

Its job is to:

1. classify the user request into `Assist`, `Delivery`, or `Incident`
2. assess task risk (`L0`-`L4`)
3. apply the minimum governance needed
4. keep internal workflow mechanics hidden unless they materially matter

It must not behave like a mandatory stage announcer.

---

## 1. Routing Order

Always execute in this order:

1. Determine whether the request is read-only or mutating.
2. Determine whether the request is incident-like.
3. Determine the risk level.
4. Decide whether an `Item` is actually needed.
5. Route to the appropriate execution path.

Visible ownership rule:

- keep `fe` as the default visible owner for frontend delivery
- use other specialist lenses only when needed
- hide internal consultations unless the user explicitly asks for them

Do not:

1. create an `Item` first
2. ask for approval first
3. run full workflow machinery first
4. only later discover the task was read-only

---

## 2. Mode Classification

### 2.1 Assist Mode

Use `Assist` when the user is asking to:

- understand a repository, plugin, or module
- explain code or architecture
- review or critique a design, workflow, or implementation
- locate risk, hotspots, or likely sources of a problem
- compare approaches without requesting code changes yet

Behavior:

- directly read files, search code, and summarize findings
- do not create an `Item`
- do not invoke explicit gates
- do not require `.feflow/` initialization
- do not mention internal terms like skill, hook, gate, role, or orchestrator

### 2.2 Delivery Mode

Use `Delivery` when the user wants actual code or config changes intended for delivery.

Behavior:

- risk-assess first
- only create a tracked `Item` when justified by risk, duration, or dependency
- only expose user confirmations when they change direction, scope, or risk posture

### 2.3 Incident Mode

Use `Incident` when the task is clearly urgent production or emergency work:

- hotfix
- rollback
- service restoration
- active outage mitigation
- emergency security response

Behavior:

- optimize for stabilization speed
- preserve minimal safety and rollback awareness
- backfill governance after recovery

---

## 3. Risk Levels

### `L0`

Read-only tasks with no code modification intent.

Examples:

- "deeply understand this plugin"
- "review this repository"
- "evaluate this architecture"

Route: `Assist`

### `L1`

Low-risk delivery.

Typical shape:

- single file
- local styles or copy
- isolated bugfix
- bounded UI polish

Route: `Delivery-L1`

### `L2`

Moderate-risk delivery.

Typical shape:

- multi-file change
- bounded behavior change
- component plus store/API integration

Route: `Delivery-L2`

### `L3`

High-risk delivery.

Automatic escalation signals include:

- auth / permission
- payment / order / money movement
- SSR / hydration
- router / navigation architecture
- global state / store
- env / secret / deploy
- build tooling / CI pipeline
- shared public APIs
- cross-module refactor

Route: `Delivery-L3`

### `L4`

Incident or emergency work.

Route: `Incident`

---

## 4. Item Creation Policy

Do **not** create an `Item` by default.

Create an `Item` only when one or more of the following are true:

1. the task is `Delivery-L3`
2. the task spans multiple sessions or handoffs
3. the task has explicit dependencies on other tracked work
4. the task needs durable evidence, review, or memory retention
5. the user explicitly asks to track the work as a formal item

For `Assist` and most `Delivery-L1` tasks:

- do not create an `Item`
- do not ask for permission to create one

For `Delivery-L2`:

- prefer a lightweight execution path first
- create an `Item` only if complexity, duration, or dependency pressure justifies it

---

## 5. User-Facing Interaction Contract

### 5.1 Internal Control Plane Must Stay Hidden

Do not say:

- "I will call skill X"
- "the hook injected context"
- "I am now in gate 1"
- "PM agent will take over"
- "memory-load says"

Instead say:

- "I'll scan the relevant files and summarize the structure."
- "This touches a high-risk area, so I'll pause once to confirm scope before implementing."
- "I finished the code review pass; here are the concrete findings."

### 5.2 Confirmation Rules

Pause only when:

1. the goal is materially ambiguous
2. the next step changes scope or direction
3. the action is destructive, irreversible, or externally visible

Do **not** pause just because:

1. a workflow stage ended
2. a plan document could be written
3. an internal role would normally hand off
4. a non-destructive read action is next

### 5.3 Default Output Shape

User-visible progress updates should stay close to:

- what is being examined
- what has been found
- what happens next
- why a decision is needed, if one is needed

---

## 6. Assist Execution Path

For `Assist`:

1. search relevant files
2. read the decisive sources
3. summarize concrete findings with file evidence
4. provide critique, explanation, or recommendations

Never require:

- initialization
- item creation
- staged approval
- full repository scan if a scoped scan is enough

`repo-scan`, `dashboard`, and `evidence-chain` may still be used as backend capabilities when helpful,
but they must not be presented as required workflow stages for read-only tasks.

---

## 7. Delivery Execution Path

### 7.1 Delivery-L1

Default rhythm:

1. inspect relevant code
2. implement directly
3. run proportionate verification
4. report result

Requirements:

- no mandatory requirement review
- no mandatory plan review
- no mandatory full itemization
- no visible gate narration

Artifacts:

- minimal implementation summary
- minimal verification summary

### 7.2 Delivery-L2

Default rhythm:

1. inspect relevant code and constraints
2. produce a short execution plan
3. pause once if confirmation materially matters
4. implement continuously
5. verify and summarize

Artifacts:

- short plan
- short verification record
- optional lightweight `Item`

### 7.3 Delivery-L3

Default rhythm:

1. inspect code, memory, and repo context
2. produce a compact decision packet
3. obtain explicit confirmation
4. execute in a continuous run
5. collect evidence and summarize

The decision packet must include:

- scope
- risk
- rollback strategy
- verification strategy
- affected areas

For `Delivery-L3`, tracked governance is expected:

- use `Item`
- use memory selectively
- use evidence collection
- use review and gate logic internally

---

## 8. Incident Execution Path

For `Incident`:

1. confirm the incident is real enough to justify emergency handling
2. assess immediate impact quickly
3. apply the smallest effective fix or mitigation
4. verify recovery quickly
5. backfill formal incident artifacts afterward

Route to `flow-hotfix` semantics, not standard delivery planning.

Do not let incident handling degrade into long staged planning.

---

## 9. Relation to Existing Flows

Existing flow skills remain useful, but they are no longer the universal entrypoint.

### Keep as Delivery/Incident backend flows

- `flow-feature`
- `flow-modification`
- `flow-bugfix`
- `flow-refactor`
- `flow-ui-optimize`
- `flow-hotfix`

### Keep as governance backend capabilities

- `quality-gate`
- `memory-load`
- `memory-update`
- `memory-decay`
- `item-orchestration`
- `evidence-chain`
- `backfill`

### Important rule

Internal flow stages must not automatically become user-visible approval prompts.

---

## 10. Superpowers Coexistence

`feflow` v2 must coexist with `superpowers`, not try to override it globally.

Working rule:

- use normal assistant behavior for read-only and low-risk work
- use `feflow` delivery governance only when the task crosses into real tracked frontend delivery
- use incident governance only when urgency justifies it

If `superpowers` capabilities exist, they may be used as supporting execution tools inside the selected mode.
They are not the primary routing concern.

---

## 11. Hard Constraints

1. Do not fake verification.
2. Do not claim search results without actually searching.
3. Do not expose internal workflow names by default.
4. Do not route every development request into tracked delivery.
5. Do not interrupt the user at every internal stage boundary.
6. Do not let documentation requirements outrank task momentum for low-risk work.
