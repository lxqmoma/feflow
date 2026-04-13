# Feflow v2 Dogfood Round 1 Worksheet

Use this worksheet when running the first real manual behavior pass against the v2 acceptance suite.

This file is intentionally operational.
It is for capturing what actually happened, not what should have happened.

---

## Session Meta

- **date**:
- **repo under test**:
- **assistant host**: Claude Code / Cursor / Windsurf / other
- **model / runtime**:
- **branch / commit**:
- **workspace had `.feflow/`**: yes / no
- **tester**:

---

## How To Use

For each scenario:

1. run the prompt from `V2-ACCEPTANCE-SUITE.md`
2. paste the actual first reply
3. record whether any hard fail happened
4. score all five dimensions
5. write the smallest actionable fix

Do not polish the transcript.
Raw interaction quality matters more than cleaned-up prose.

---

## Scenario `A0` — Deep Understanding

### Prompt

```text
深度理解这个插件的设计哲学，先别着急改。分析现在的缺陷。
```

### Actual First Reply

```text
{paste here}
```

### Hard Fail Check

- [ ] asked for initialization before helping
- [ ] asked user to gather files / paths it could discover directly
- [ ] exposed internal stage / role / gate narration
- [ ] gave conclusions before reading code
- [ ] told the user to run a `/feflow:*` command in shell form
- [ ] other:

### Pause Count

- **actual pauses before meaningful analysis**:

### Score

| Dimension | Score (0-2) | Note |
|-----------|-------------|------|
| Directness |  |  |
| Evidence grounding |  |  |
| Control plane hiding |  |  |
| Interruption cost |  |  |
| Risk handling |  |  |

- **total**:

### Trajectory Notes

- what it inspected:
- what felt good:
- what felt bureaucratic:

### Smallest Fix

- 

---

## Scenario `D1` — Low-Risk Delivery

### Prompt

```text
把 README 顶部的一句产品介绍改得更直接一点。
```

### Actual First Reply

```text
{paste here}
```

### Hard Fail Check

- [ ] required Item / requirement brief / init before editing
- [ ] asked for unnecessary approval between read and edit
- [ ] exposed workflow stage narration
- [ ] demanded full evidence flow
- [ ] claimed the command path depended on a missing skill/tool entry
- [ ] other:

### Pause Count

- **actual pauses before edit**:

### Score

| Dimension | Score (0-2) | Note |
|-----------|-------------|------|
| Directness |  |  |
| Evidence grounding |  |  |
| Control plane hiding |  |  |
| Interruption cost |  |  |
| Risk handling |  |  |

- **total**:

### Trajectory Notes

- files inspected:
- edit flow quality:
- verification quality:

### Smallest Fix

- 

---

## Scenario `G0` — Workspace Init

### Prompt

```text
/feflow:init
```

### Actual First Reply

```text
{paste here}
```

### Hard Fail Check

- [ ] asked for approval before safe bounded init
- [ ] told the user to run a `/feflow:*` command in shell form
- [ ] claimed init could not run because a skill/tool entry was unavailable
- [ ] turned init into a full repo interview
- [ ] other:

### Pause Count

- **actual pauses before workspace creation / repair**:

### Score

| Dimension | Score (0-2) | Note |
|-----------|-------------|------|
| Directness |  |  |
| Evidence grounding |  |  |
| Control plane hiding |  |  |
| Interruption cost |  |  |
| Risk handling |  |  |

- **total**:

### Trajectory Notes

- what it created or repaired:
- whether any pause felt justified:
- whether defaults stayed conservative:

### Smallest Fix

- 

---

## Scenario `D3` — High-Risk Delivery

### Prompt

```text
重构登录态与路由守卫，顺便解决 SSR hydration 问题。
```

### Actual First Reply

```text
{paste here}
```

### Hard Fail Check

- [ ] skipped boundary inspection and rushed into implementation
- [ ] repeated approval after each internal phase
- [ ] stage handoff narration dominated the interaction
- [ ] governance artifacts were created with no explained value
- [ ] claimed a command could not run because an internal skill/tool entry was unavailable
- [ ] other:

### Pause Count

- **actual pauses before meaningful implementation**:

### Score

| Dimension | Score (0-2) | Note |
|-----------|-------------|------|
| Directness |  |  |
| Evidence grounding |  |  |
| Control plane hiding |  |  |
| Interruption cost |  |  |
| Risk handling |  |  |

- **total**:

### Trajectory Notes

- risk framing quality:
- boundary inspection quality:
- whether pause count felt justified:

### Smallest Fix

- 

---

## Scenario `I4` — Incident / Hotfix

### Prompt

```text
发布后首页白屏，先帮我止血。
```

### Actual First Reply

```text
{paste here}
```

### Hard Fail Check

- [ ] asked for full governance flow before acting
- [ ] prioritized paperwork over stabilization
- [ ] treated incident like a normal feature
- [ ] exposed stage narration instead of recovery path
- [ ] told the user to run a `/feflow:*` chat command as shell input
- [ ] other:

### Pause Count

- **actual pauses before recovery work**:

### Score

| Dimension | Score (0-2) | Note |
|-----------|-------------|------|
| Directness |  |  |
| Evidence grounding |  |  |
| Control plane hiding |  |  |
| Interruption cost |  |  |
| Risk handling |  |  |

- **total**:

### Trajectory Notes

- blast-radius framing:
- stabilization bias:
- rollback / mitigation clarity:

### Smallest Fix

- 

---

## Summary

### Hard Fail Summary

- `A0`:
- `G0`:
- `D1`:
- `D3`:
- `I4`:

### Score Summary

| Scenario | Total | Pass/Fail |
|----------|-------|-----------|
| `A0` |  |  |
| `G0` |  |  |
| `D1` |  |  |
| `D3` |  |  |
| `I4` |  |  |

### Top 3 Issues

1. 
2. 
3. 

### Top 3 Fixes

1. 
2. 
3. 
