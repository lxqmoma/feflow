---
name: evidence-chain
description: 证据链可视化。展示一个 Item 从创建到完成的全部证据（文档、代码、测试、发布），形成可追溯的完整链条。
---

# evidence-chain：证据链可视化

展示一个 Item 从创建到完成的全部证据，检查各阶段产出完整性，形成可追溯链条。

## 触发方式

`/feflow:task evidence {ITEM-ID}`。未提供 ID 则列出所有活跃 Item 供选择。

## 证据收集

扫描 `.feflow/items/{ITEM-ID}/`，按阶段检查预期产出：

| 阶段 | 预期文件 |
|------|----------|
| 创建 | `meta.md` |
| 需求 | `role-pm/requirement-brief.md` |
| 计划 | `role-fe/dev-plan.md` |
| 实施 | `role-fe/implementation-log.md` |
| 测试 | `role-qa/test-report.md` |
| 证据 | `evidence/evidence.md` |
| 发布 | `evidence/release-note.md` |
| 复盘 | `retrospective.md` |

存在标记 `[OK]`，缺失标记 `[GAP]`。

## 证据链展示

```
FEAT-20260405-001-user-avatar 证据链
[OK]  meta.md → [OK] requirement-brief.md → [OK] dev-plan.md
→ [OK] implementation-log.md → [GAP] test-report.md
→ [OK] evidence.md → [GAP] release-note.md → [GAP] retrospective.md
完整度: 5/8 (62.5%)
```

## Git 证据关联

- **Commits** — `git log --all --grep="{ITEM-ID}"` → 表格（Hash / 时间 / Message）
- **Branches** — `git branch -a | grep {ITEM-ID}`
- **PRs** — `gh pr list --search "{ITEM-ID}"`（`gh` 不可用时标记待补充）

## 完整度评分

| 完整度 | 评级 |
|--------|------|
| 100% | 完整 |
| 75-99% | 良好，缺少非关键项 |
| 50-74% | 不足，建议补录 |
| < 50% | 严重不足，建议执行 backfill |

L1 级别仅检查 meta.md / implementation-log.md / evidence.md，其余可选。

## 错误处理

| 场景 | 处理 |
|------|------|
| Item ID 不存在 | 提示未找到，列出已有 Item |
| `.feflow/items/` 不存在 | 提示项目未初始化 |
| `gh` 不可用 | 跳过 PR 关联，标记待补充 |
| backfilled Item | 标注事后补录，完整度单独注释 |
