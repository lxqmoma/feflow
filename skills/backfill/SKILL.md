---
name: backfill
description: 事后补录流程。当检测到已有代码改动但没有对应 Item 时，从 Git/PR/CI 反向生成工作记录。
---

# backfill：事后补录流程

## 触发条件

- repo-scan 发现未登记改动时，由 orchestrator 建议调用
- 用户执行 `/feflow-backfill` 或明确要求补录
- 代码已改完 / PR 已提 / 已 merge，但没走 feflow 流程

## 前置条件

`.feflow/` 目录存在，当前目录是 Git 仓库，存在可识别的未登记改动。

## 补录流程

### 步骤一：收集证据

用户指定分支名/PR 编号/commit 范围，未指定时从 repo-scan 未登记列表获取。

- **Git** — 相关提交（hash/作者/时间/message）、改动文件列表、diff 统计
- **PR** — `gh` 可用时获取标题、描述、reviewer、合并时间
- **CI** — `gh` 可用时获取运行结果

### 步骤二：创建 Item

基于证据反向创建工作项，标记 `record_mode: backfilled`：

- `type` — 从 commit message 前缀推断（feat→FEAT, fix→FIX, refactor→REFACTOR, 无法推断→CHORE）
- `level` — 从改动文件数推断（1-3→L1, 4-10→L2, 10+→L3）
- `status: completed`
- `backfill_reason` — 用户说明或「流程外改动，事后补录」
- `modules` — 从改动文件路径推断
- `created_at` / `completed_at` — 取最早/最晚提交时间

### 步骤三：生成简版文档

在 `.feflow/items/{ITEM-ID}/` 下生成精简版（均标注「事后补录」）：

1. `role-pm/requirement-brief.md` — 从 PR 描述和 commit message 反向提取需求摘要
2. `role-fe/dev-plan.md` — 从实际改动文件列表生成改动清单
3. `role-qa/test-report.md` — 从 CI 结果生成测试摘要
4. `evidence/evidence.md` — 调用 evidence-ledger 生成完整证据

### 步骤四：输出缺失项清单

对比完整流程应有产出，列出已补录项（✅）和缺失项（❌）：

- 通常缺失：正式需求评审记录、开发计划评审记录、历史问题对照、完整测试报告
- 缺失项不影响后续任务的记忆检索

## 批量补录

多条未登记改动时：按分支/PR 分组，逐个独立成 Item，输出汇总表。

## 错误处理

| 场景 | 处理 |
|------|------|
| 无法推断类型 | 默认 CHORE，标记「需人工确认」|
| PR 已删除 | 仅从 git log 补录 |
| `gh` 不可用 | 跳过 PR/CI，仅从 git 补录 |
| Item ID 冲突 | 自动递增编号 |
