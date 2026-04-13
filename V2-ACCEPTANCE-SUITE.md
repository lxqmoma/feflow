# Feflow v2 Acceptance Suite

This document defines the manual dogfood suite for validating whether `feflow` v2 actually behaves like:

- a strong assistant by default
- a governance layer when needed
- a recovery-oriented system under incident pressure

It is not a marketing checklist.
It is a behavior acceptance contract.

---

## 1. What This Suite Is Testing

The suite focuses on four product promises:

1. **Directness**: normal work should not be wrapped in ceremony
2. **Risk proportionality**: governance should scale with task risk
3. **Hidden control plane**: users should not manage `skill`, `hook`, `gate`, `role`, or `Item`
4. **Recovery bias**: incident work should optimize for stabilization, not paperwork

---

## 2. How To Run It

For each scenario:

1. start from a realistic repo context
2. issue the prompt as written, or with only minor repo-specific edits
3. inspect the first reply and the full task trajectory
4. score the result against the pass/fail rules below

This suite is intentionally manual.
The goal is to judge actual interaction quality, not only static wording.

---

## 3. Global Failure Signals

Any scenario should be considered a **hard fail** if the assistant does one or more of the following without strong justification:

1. asks for initialization before it has tried to help
2. asks the user to collect files or paths that the assistant can read directly
3. creates or insists on an `Item` for a clearly low-risk or read-only task
4. narrates internal stages, roles, or gates as if they were the product
5. pauses after every internal step for approval
6. claims conclusions without file or code evidence
7. demands a full evidence bundle for low-risk work
8. treats incident work like a normal multi-stage delivery workflow

---

## 4. Scenario Matrix

| ID | Scenario | Expected Route | Core Standard |
|----|----------|----------------|---------------|
| `A0` | Repo / plugin understanding | Assist | read first, answer directly |
| `D1` | Low-risk local delivery | Delivery-L1 | implement directly |
| `D3` | High-risk delivery | Delivery-L3 | brief alignment, tracked governance, no stage spam |
| `I4` | Incident / hotfix | Incident | stabilize first |

---

## 5. Scenario `A0` — Deep Understanding

### Prompt

Chinese:

```text
深度理解这个插件的设计哲学，先别着急改。分析现在的缺陷。
```

English equivalent:

```text
Deeply understand this plugin's design philosophy first. Do not modify it yet. Analyze its current flaws.
```

### Expected Route

- `Assist`
- no `Item`
- no `.feflow/` requirement

### Must Do

1. read repo files directly
2. identify concrete design choices from files
3. distinguish facts from inference
4. produce a critique grounded in actual repo evidence

### Must Not Do

1. ask the user to confirm every read step
2. request that the user paste directory listings or file contents first
3. pretend analysis is complete before reading the code
4. expose role/gate/orchestrator narration

### Pause Budget

- preferred: `0`
- maximum acceptable: `1`, and only if a critical repo boundary is genuinely unknowable from context

### Pass Shape

Good interaction shape:

- short update about what will be inspected
- direct repo reading
- evidence-backed critique
- clear summary of key defects

Bad interaction shape:

- “I will first enter scan stage, then requirement stage”
- “Please confirm I may read files”
- “Send me the path”

---

## 6. Scenario `D1` — Low-Risk Delivery

### Prompt

Chinese:

```text
把 README 顶部的一句产品介绍改得更直接一点。
```

English equivalent:

```text
Make the product description at the top of the README more direct.
```

### Expected Route

- `Delivery-L1`
- no default `Item`
- no default `/init`

### Must Do

1. inspect the relevant file directly
2. make the smallest reasonable edit
3. report what changed and how it was checked

### Must Not Do

1. require a PM-style requirement brief
2. require a dev plan before editing
3. ask for approval between reading and editing when scope is obvious
4. require a full evidence package

### Pause Budget

- preferred: `0`
- maximum acceptable: `1`, only if the wording materially changes product positioning

### Pass Shape

Good:

- “I checked the README header and rewrote the description for directness.”

Bad:

- “I need to create an Item and a requirement brief first.”
- “Please confirm phase 1 is complete.”

---

## 7. Scenario `D3` — High-Risk Delivery

### Prompt

Chinese:

```text
重构登录态与路由守卫，顺便解决 SSR hydration 问题。
```

English equivalent:

```text
Refactor auth state and route guards, and fix the SSR hydration issue.
```

### Expected Route

- `Delivery-L3`
- tracked governance is appropriate
- one compact alignment pause may be appropriate

### Must Do

1. identify why the task is high risk
2. inspect the relevant modules before proposing implementation
3. define bounded scope, rollback thinking, and verification approach
4. use tracked governance if the workspace exists or if the task clearly needs durable tracking

### Must Not Do

1. force multiple approval rounds for each internal step
2. narrate stage handoffs to PM / FE / QA / reviewer
3. create governance artifacts without explaining why they matter
4. start implementation while key auth / routing boundaries are still unclear

### Pause Budget

- preferred: `1`
- maximum acceptable: `2`

The pause should happen around:

- scope alignment
- destructive or externally visible risk

It should not happen after every internal phase.

### Pass Shape

Good:

- brief risk framing
- concise plan
- direct repo inspection
- one alignment pause if needed
- continuous execution after that

Bad:

- “Requirement phase complete, please approve”
- “Planning phase complete, please approve”
- “Review phase complete, please approve”

---

## 8. Scenario `I4` — Incident / Hotfix

### Prompt

Chinese:

```text
发布后首页白屏，先帮我止血。
```

English equivalent:

```text
The homepage is blank after release. Help me stop the bleeding first.
```

### Expected Route

- `Incident`
- recovery bias
- governance backfilled later

### Must Do

1. focus first on impact, likely blast radius, and recent change surface
2. look for the fastest credible stabilization path
3. mention rollback or mitigation thinking
4. make residual risk explicit

### Must Not Do

1. insist on writing a complete retrospective first
2. demand a full Item/evidence/review flow before acting
3. treat the incident as a normal feature request
4. force user-visible stage narration

### Pause Budget

- preferred: `0` or `1`
- maximum acceptable: `1`

The only acceptable pause is a high-value directional choice such as:

- rollback vs hotfix
- mitigation vs revert

### Pass Shape

Good:

- “I’m checking the likely release surface first, then I’ll pick the smallest safe recovery path.”

Bad:

- “Please initialize `.feflow/` so I can begin incident handling.”
- “Let me first create the incident documentation set.”

---

## 9. Scoring Rubric

Each scenario is scored from `0` to `2` on five dimensions:

| Dimension | 0 | 1 | 2 |
|-----------|---|---|---|
| Directness | blocked by ceremony | mixed | direct |
| Evidence grounding | mostly unsupported | partly grounded | file-grounded |
| Control plane hiding | internal jargon dominates | some leakage | mostly hidden |
| Interruption cost | repeated pauses | one awkward pause | minimal pause |
| Risk handling | under/over-reacts | partly proportional | well calibrated |

Total per scenario: `0-10`

### Acceptance Threshold

Minimum acceptable bar:

- no hard fail
- `A0 >= 8`
- `D1 >= 8`
- `D3 >= 7`
- `I4 >= 8`

Target bar:

- all scenarios `>= 9`

---

## 10. Release Readiness Interpretation

`feflow` v2 should be considered behaviorally credible only when:

1. Assist feels clearly better than “workflow theater”
2. L1 delivery feels nearly as direct as Superpowers
3. L3 delivery is safer without becoming bureaucratic
4. Incident handling feels materially faster than plan-first systems

If the suite passes only because the wording changed while the interaction pattern is still fragmented, treat that as a fail.

The suite is judging behavior, not just prose.
