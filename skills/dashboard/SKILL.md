---
name: dashboard
description: Item 状态视图。v2 中它只关注已追踪工作的健康度，不把没有立项的普通任务也强行拉进看板。
---

# dashboard：v2 Item 状态视图

展示所有已追踪工作项的状态分布、进度概览、风险提示和依赖阻塞情况。

## 触发方式

`/feflow:task dashboard` 或 `/feflow:dashboard`

## 数据来源

读取 `.feflow/items/` 下所有 Item 的 `meta.md` frontmatter：`id`、`type`、`level`、`status`、`created`。

只展示被追踪工作的情况，不推断未立项任务。

## 状态分组

按 status 分组展示，每组列出 Item 摘要（ID / 级别 / 状态 / 停留天数）。

这些状态是内部跟踪状态，不代表用户必须感知到的流程阶段：

```
进行中 (3)
  FEAT-20260405-001-user-avatar  L2  implementing  3d
  BUG-20260406-001-login-error   L1  implementing  2d
  MOD-20260407-001-search-filter L2  testing       1d
待启动 (1)
  FEAT-20260408-001-export-csv   L2  created       0d
已完成 (5)  — 最近 10 条，更早折叠
```

## 统计信息

总数、各状态数量、活跃项平均停留时间。

活跃项通常指非 `completed`、非 `archived` 的 Item，例如：

- `created`
- `implementing`
- `testing`
- `blocked`

## 风险提示

| 条件 | 标记 | 说明 |
|------|------|------|
| 非 completed 且停留 > 7 天 | `⚠️` | 需关注 |
| 非 completed 且停留 > 14 天 | `🔴` | 高风险，建议立即处理 |
| HOTFIX 且停留 > 1 天 | `🔴` | 紧急任务超时 |

风险项单独列出，附带建议（拆分 / 重新评估 / 关闭）。

## 依赖视图

读取 Item 的 `dependencies` 字段，展示阻塞链：

```
FEAT-001-export-csv
  └── 被阻塞于: FEAT-002-data-api (implementing)
```

无依赖关系时不展示此区域。

## 记忆健康度

读取 `.feflow/memory/` 统计条目状态（active / stale）。`stale` 定义：超过 30 天未更新。只有 stale 占比明显偏高时，才建议执行 `memory-decay`。

## 错误处理

| 场景 | 处理 |
|------|------|
| `.feflow/items/` 不存在 | 提示项目未初始化 |
| Item 缺少 frontmatter | 跳过该 Item，警告格式不完整 |
| 无任何 Item | 展示空状态 |
| `.feflow/memory/` 不存在 | 跳过记忆健康度区域 |
