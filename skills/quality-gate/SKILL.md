---
name: quality-gate
description: Internal governance checks for delivery and incident work. Prefer silent pass or compact blocker output over checklist broadcasting.
---

# Quality Gate — Internal Delivery Guardrails

`quality-gate` in v2 is an internal guardrail system.

Its default job is not to narrate process.
Its default job is to decide whether work may continue safely.

---

## 1. Output Levels

Every gate evaluation must resolve to one of three levels:

### `silent-pass`

All important checks passed.

Behavior:

- continue automatically
- do not emit full checklist output to the user

### `warn-but-continue`

The task may continue, but there is residual risk or missing non-critical governance.

Behavior:

- continue
- surface only the relevant warning summary
- do not dump the full checklist

### `hard-block`

The task must not continue without a user decision or corrective action.

Behavior:

- stop and explain the smallest set of blockers
- ask only for the decision required to move forward

---

## 2. Gate Selection

### Gate A — Before Meaningful Implementation

Apply for `Delivery-L2`, `Delivery-L3`, and `Incident` when relevant.

Check:

1. task scope is sufficiently understood
2. relevant code has actually been inspected
3. rollback thinking exists when risk is material
4. verification strategy exists at the level appropriate to risk
5. if tracked governance is required, the necessary item context exists

### Gate B — Before Externalizing the Change

Apply before:

- PR creation
- merge
- deployment
- release communication

Check:

1. implementation record is coherent enough to explain the change
2. verification has been run at the level appropriate to risk
3. actual changes still match the intended scope
4. build/lint/type checks are acceptable for the task class
5. evidence is sufficient for the release risk level

### Gate C — Special Risk Checks

Apply only when the changed area demands it.

Examples:

- auth / permission
- payment / money movement
- public/shared component APIs
- CI/CD or deploy surface
- env / secrets / irreversible data operations

---

## 3. Risk-Proportional Expectations

### `Delivery-L1`

Expected:

- relevant code inspected
- minimal verification completed
- no hidden high-risk scope

Do not require:

- formal requirement review
- formal dev plan review
- full evidence bundle

### `Delivery-L2`

Expected:

- short execution plan exists
- verification approach is explicit
- scope is still bounded

Warnings are preferred over blocks unless risk is clearly material.

### `Delivery-L3`

Expected:

- decision packet or equivalent tracked rationale exists
- rollback strategy exists
- verification strategy exists
- tracked context exists if the task is multi-session or cross-module

### `Incident`

Expected:

- immediate problem is understood well enough to act
- rollback or mitigation path is known
- minimum validation exists

Defer:

- full documentation
- full retrospective
- non-critical evidence packaging

---

## 4. User-Facing Behavior

When surfacing a gate result to the user:

- show only the blockers or warnings that matter
- keep wording operational
- do not expose internal gate numbering unless explicitly asked

Good:

- "This touches auth and still lacks a rollback path. I need that confirmed before I ship it."
- "The change is low-risk and verified locally. I see no blocker."

Bad:

- "Gate 1 result: PASS"
- "Checklist item 4.2 is incomplete"
- full checklist spam for a silent pass

---

## 5. Example Blockers

Legitimate `hard-block` examples:

1. high-risk module with no rollback path
2. destructive action with unclear user intent
3. public API break without scope confirmation
4. incident fix with no minimum validation
5. delivery task that silently expanded far beyond original scope

Non-blockers that should usually stay warnings:

1. missing formal requirement doc for an L1 task
2. missing evidence bundle for an internal low-risk change
3. lack of a tracked item for a one-shot local fix

---

## 6. Relation to Existing Flows

Legacy v1 flows may still reference explicit staged gate output.
When used through v2 routing, prefer:

- `silent-pass` for normal successful checks
- `warn-but-continue` for non-critical gaps
- `hard-block` only when continuation is genuinely unsafe
