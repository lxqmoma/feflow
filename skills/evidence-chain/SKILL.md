---
name: evidence-chain
description: 证据链可视化。v2 中它用于查看已追踪任务在当前风险等级下是否具备足够证据，而不是拿一套固定流水线去要求所有任务。
---

# evidence-chain：v2 证据画像

`evidence-chain` 的作用是回答：

1. 这个已追踪任务当前属于哪种证据级别
2. 对这个级别来说，已经有了哪些关键材料
3. 缺失项里哪些真的影响信任，哪些只是可选补充

它不是一个“标准八件套检查器”。

## 触发方式

- `/feflow:task evidence {ITEM-ID}`
- 用户要求查看某个 Item 的材料完整度
- review / release / audit 前需要快速看证据状态

未提供 ID 时，可先列出活跃 Item 供选择。

## 适用范围

只针对 **已追踪 Item**。

如果项目没有 `.feflow/items/` 或当前没有活跃 Item，直接说明“当前没有可查看的追踪证据”即可，不要把未追踪任务视为失败。

## 证据级别判定

优先根据 `meta.md` 中的 `level`、`status`、任务类型和是否即将 externalize 判断：

| 级别 | 典型场景 | 目标 |
|------|----------|------|
| `minimal` | L1 / 内部低风险追踪项 | 证明改了什么、怎么验证、还有什么残余风险 |
| `partial` | L2 / 中等风险交付 | 在 `minimal` 基础上补足关键实现与测试证据 |
| `full` | L3 / 发布前 / 审查前 | 形成足够支撑 review、release、审计的证据包 |
| `incident-overlay` | Hotfix / 事故恢复 | 额外强调止血动作、回滚 awareness、恢复验证 |

如果无法确定，默认按 `partial` 展示，并明确这是推断。

## 证据槽位

不要按阶段死板检查，而应按“证据槽位”检查：

| 槽位 | 常见来源 | 说明 |
|------|----------|------|
| 追踪身份 | `meta.md` | 当前 Item 的基本身份与风险级别 |
| 目标与范围 | `requirement-brief.md` / 决策摘要 / issue 摘要 | 只有在任务确实需要范围澄清时才出现 |
| 实施事实 | `implementation-log.md` / commits / diff 摘要 | 至少应能说明实际改了什么 |
| 验证事实 | `test-report.md` / 测试输出 / 检查命令结果 | 至少应能说明验证做到了什么 |
| 发布事实 | `release-note.md` / PR / CI / deploy 记录 | 只在 externalize 或高风险交付时重要 |
| 复盘事实 | `retrospective.md` / incident note | 只在事故或高价值任务中重要 |

同一个槽位可以由不同材料满足，不要求固定文件名。

## 级别对应的期望

### `minimal`

必须看到：

- 追踪身份
- 实施事实
- 验证事实或明确的未验证风险

可选：

- 目标与范围
- 发布事实
- 复盘事实

### `partial`

必须看到：

- 追踪身份
- 实施事实
- 验证事实

建议看到：

- 目标与范围
- 至少部分 git 证据

### `full`

必须看到：

- 追踪身份
- 可追溯的目标与范围
- 实施事实
- 验证事实
- git 证据

若即将 externalize，建议补足：

- PR / CI / release 相关证据

### `incident-overlay`

在对应级别基础上，额外关注：

- 事故现象或影响摘要
- 止血动作
- 回滚或兜底路径
- 恢复验证

复盘和长期修复可后补，不应因为缺少复盘就判定当前恢复无效。

## 展示方式

建议按 `required / expected / optional` 展示，而不是按“漏了几个文件”打分：

```text
FEAT-20260405-001-user-avatar
evidence profile: partial

[required][OK]   identity        meta.md
[required][OK]   implementation  role-fe/implementation-log.md
[required][OK]   verification    role-qa/test-report.md
[expected][GAP]  scope           requirement-brief.md
[expected][OK]   git evidence    3 commits matched
[optional][NA]   release         not externalized

summary:
- required complete
- expected 1/2
- no release blocker
```

## Git 证据关联

按需补充：

- **Commits** — `git log --all --grep="{ITEM-ID}"` 或基于文件/时间范围的补充匹配
- **Branches** — `git branch -a | grep {ITEM-ID}`
- **PRs** — `gh pr list --search "{ITEM-ID}"`，不可用则标注 `N/A`
- **CI / Deploy** — 仅在 externalize 或 full evidence 场景中查看

## 结论规则

- `required` 缺失：说明这是信任缺口，需要补录或降级结论
- `expected` 缺失：作为警告，不直接判定失败
- `optional` 缺失：仅提示，不制造压力

不要再输出简单的 “5/8 = 62.5%” 机械完整度分数。

## 错误处理

| 场景 | 处理 |
|------|------|
| Item ID 不存在 | 提示未找到，列出已有 Item |
| `.feflow/items/` 不存在 | 说明当前无追踪证据工作区 |
| `gh` 不可用 | 跳过 PR/CI/Deploy，标记 `N/A` |
| 材料缺失 | 标记具体槽位缺口，而不是断言任务失败 |
