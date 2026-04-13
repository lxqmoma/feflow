# Feflow v2 Dogfood Round 1 Baseline

This document is a **pre-live baseline assessment** for `feflow` v2.

It is based on the current promptware, command surface, acceptance suite, and smoke checks.
It is **not** a substitute for running real host transcripts.

Its purpose is to answer:

1. where the current design is likely to pass
2. where it is still likely to wobble
3. which scenario should be attacked first in live dogfood

---

## 1. Assessment Scope

This baseline is derived from:

- `CLAUDE.md`
- command docs
- core skills
- acceptance suite
- golden first replies
- smoke constraints

It does **not** claim that a real host already behaved exactly this way.

---

## 2. Overall Read

Current v2 is likely to pass the **static design bar**:

- default posture is now direct
- governance is largely risk-proportional
- control-plane language is much better hidden
- incident handling is structurally biased toward stabilization

The remaining uncertainty is mainly **runtime behavior drift**, not missing design philosophy.

That is a good sign.

---

## 3. Scenario Baseline

| Scenario | Predicted Score | Baseline Read |
|----------|-----------------|---------------|
| `A0` | `9/10` | strong |
| `G0` | `8/10` | good, but host command semantics still need proof |
| `D1` | `9/10` | strong |
| `D3` | `7/10` | acceptable but still the weakest |
| `I4` | `8/10` | good, with some residual risk |

---

## 4. Scenario Notes

### `A0` — Deep Understanding

**Predicted score:** `9/10`

Why it should pass:

- Assist path is now explicitly direct
- repo reading is the default behavior
- first-reply contract is clear
- initialization and Item creation are clearly banned for this class

Residual risk:

- some host integrations may still leak internal nouns if they over-literalize internal docs
- deep analysis quality still depends on whether the assistant really reads enough files before concluding

Most likely failure shape:

- slightly too much explanation of process before actual reading

### `G0` — Workspace Init

**Predicted score:** `8/10`

Why it should mostly pass:

- slash-command semantics are now explicit
- bounded init is defined as direct local execution
- confirmation is now conflict-only instead of default

Residual risk:

- some hosts may still over-literalize “skill” language and expose backend plumbing
- some conservative runtimes may still ask one extra permission question before file creation

Most likely failure shape:

- explaining why init cannot run instead of simply running it
- asking for an unnecessary “同意继续”

### `D1` — Low-Risk Delivery

**Predicted score:** `9/10`

Why it should pass:

- L1 now strongly defaults to direct execution
- command docs explicitly reject Item-first behavior
- first-reply contract is tight and practical

Residual risk:

- some hosts may still over-plan because they are generally conservative around edits
- verification could become a bit wordy if the host overcompensates

Most likely failure shape:

- one unnecessary planning sentence before editing

### `D3` — High-Risk Delivery

**Predicted score:** `7/10`

Why it is only borderline strong:

- the high-risk path now has bounded pauses and clearer first-reply rules
- tracked governance is justified here
- rollback and verification language is much better than before

Residual risk:

- this is still the path most likely to regress into ceremony
- some L3 language still naturally attracts heavier structure
- hosts may convert “one justified pause” into “multiple cautious pauses”

Most likely failure shape:

- too many scope / plan / review check-ins
- governance artifacts explained too late or too abstractly

### `I4` — Incident / Hotfix

**Predicted score:** `8/10`

Why it should generally pass:

- incident route is now explicitly stabilize-first
- first-reply contract is aligned with blast-radius and rollback thinking
- paperwork is clearly deferred

Residual risk:

- some hosts may still mix delivery-style governance into incident handling
- evidence/backfill could reappear too early if runtime behavior is overly policy-heavy

Most likely failure shape:

- a little too much documentation talk before recovery action

---

## 5. Cross-Cutting Residual Risks

### 1. Runtime Drift Across Hosts

The same promptware may behave differently in Claude Code, Cursor, and Windsurf.
The biggest remaining uncertainty is host-specific conservatism.

### 2. L3 Is Still the Pressure Point

`Delivery-L3` is where good governance and bad bureaucracy are closest together.
If live dogfood fails anywhere first, it will probably fail here.

### 3. Internal Vocabulary Still Exists In Backend Documents

That is acceptable, but poor host integrations could still surface more of it than intended.
The design is much improved; runtime presentation still has to prove it.

---

## 6. What This Means Before Live Dogfood

Current state is good enough to begin a real round-1 run.

Recommended execution order:

1. run `A0` first to confirm Assist really feels direct
2. run `G0` second to confirm workspace init behaves like a harness action instead of a permission dialog
3. run `D1` third to confirm low-risk delivery is not over-governed
4. run `I4` fourth to verify incident recovery bias
5. run `D3` last, because it is the most likely to reveal remaining bureaucracy

---

## 7. First Fix Targets If Live Runs Fail

If live round-1 exposes issues, attack them in this order:

1. reduce extra pauses in `D3`
2. remove any remaining “missing skill/tool entry” language from `G0`
3. remove any remaining control-plane leakage in first replies
4. shorten over-explanatory verification narration in `D1`
5. keep incident path from inheriting delivery paperwork too early

---

## 8. Success Criterion For Moving Past Round 1

`feflow` v2 is ready to move beyond round 1 only if:

- `A0` and `D1` feel clearly close to Superpowers-level directness
- `G0` behaves like a direct harness action, not a permission workflow
- `I4` feels faster than a plan-first workflow
- `D3` is safer without feeling like stage theater

If `D3` still feels bureaucratic, the system is not done, even if the other three scenarios score well.
