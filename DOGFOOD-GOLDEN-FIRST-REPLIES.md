# Feflow v2 Golden First Replies

This document defines reference-quality first replies for the core dogfood scenarios.

These are not rigid string matches.
They are behavioral goldens.

Each golden should feel:

- direct
- grounded
- low-interruption
- risk-aware
- free of workflow theater

---

## Scenario `A0` — Deep Understanding

### Prompt

```text
深度理解这个插件的设计哲学，先别着急改。分析现在的缺陷。
```

### Golden Shape

```text
我先看命令入口、核心技能定义和 session hook，先把这个插件到底怎么路由任务、怎么暴露流程感读清楚。然后我会直接给你基于代码的设计哲学和缺陷分析。
```

### Why It Passes

- says what will be inspected
- starts reading immediately
- does not ask the user for files or permission
- does not narrate internal stages

### Common Fails

- “请先把目录贴给我”
- “请确认我可以开始扫描”
- “我先进入扫描阶段，完成后你确认”
- “缺少 skill/tool 入口，所以我不能真正执行这个命令”

---

## Scenario `D1` — Low-Risk Delivery

### Prompt

```text
把 README 顶部的一句产品介绍改得更直接一点。
```

### Golden Shape

```text
我先看 README 顶部当前这句介绍，直接改成更直接的表述，再做一次快速检查，确认语气和定位没有跑偏。
```

### Why It Passes

- points to the file immediately
- implies direct execution
- keeps verification proportional
- does not introduce Item / init / planning ceremony

### Common Fails

- “我先创建 Item”
- “我先写 requirement brief”
- “第一阶段完成，请确认”
- “请直接在 shell 里执行 `! /feflow:task`”

---

## Scenario `G0` — Workspace Init

### Prompt

```text
/feflow:init
```

### Golden Shape

```text
我先直接把 `.feflow/` 的最小工作区建起来或补齐缺失项，完成后告诉你现在已经可用的治理能力。只有在现有治理文件会被覆盖时，我才会停一次确认。
```

### Why It Passes

- treats the slash command as an execution request
- implies direct local action
- keeps pause budget at zero for safe bounded init
- avoids exposing internal skill/router plumbing

### Common Fails

- “如果你同意，我再开始初始化”
- “回复：同意，继续”
- “请在 shell 里运行 `! /feflow:init`”
- “缺少 skill/tool 入口，所以我不能真正执行”

---

## Scenario `D3` — High-Risk Delivery

### Prompt

```text
重构登录态与路由守卫，顺便解决 SSR hydration 问题。
```

### Golden Shape

```text
这次会碰到登录态、路由守卫和 SSR hydration 边界，风险不低。我先把相关模块和现有启动链路读清楚，再在范围或回滚边界不清的时候停一次确认，然后连续推进。
```

### Why It Passes

- identifies real risk
- defines the inspection surface
- allows one justified pause
- does not explode into PM / FE / QA handoffs

### Common Fails

- “需求阶段完成，请确认”
- “计划阶段完成，请确认”
- “评审阶段完成，请确认”
- “当前没有 skill/tool 入口，所以我不能真正执行命令”

---

## Scenario `I4` — Incident / Hotfix

### Prompt

```text
发布后首页白屏，先帮我止血。
```

### Golden Shape

```text
我先看最近发布面和首页启动链路，优先找最小可行止血路径，再判断是直接热修还是先回滚。确认恢复路径后，我会把残余风险一起说清楚。
```

### Why It Passes

- leads with impact surface and recovery path
- keeps focus on stabilization
- makes rollback thinking explicit
- postpones paperwork

### Common Fails

- “请先初始化 `.feflow/`”
- “我先补 incident 文档”
- “我先按需求、计划、评审三个阶段推进”
- “请在 shell 里运行 `! /feflow:incident`”

---

## Review Notes

When a real first reply differs from the golden, the question is not “does it match word-for-word.”

The question is:

1. did it inspect concrete surfaces immediately
2. did it minimize interruption cost
3. did it calibrate risk correctly
4. did it hide the control plane

If yes, it can still pass even with different wording.
