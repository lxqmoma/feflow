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

1. 当前目录是 Git 仓库
2. `.feflow/` 目录存在（项目已初始化）
3. 存在可识别的未登记改动（分支/PR/提交）

## 补录流程

### 步骤一：收集证据

从 Git/PR/CI 反向收集已发生的事实：

1. **识别目标** — 用户指定分支名、PR 编号或 commit 范围；未指定时从 repo-scan 的未登记改动列表中获取
2. **Git 证据** — 提取相关提交（hash/作者/时间/message）、改动文件列表、diff 统计
3. **PR 证据** — `gh` 可用时获取 PR 标题、描述、reviewer、review 状态、合并时间
4. **CI 证据** — `gh` 可用时获取 CI 运行结果

### 步骤二：创建 Item

基于收集到的证据反向创建工作项：

```markdown
---
item_id: {TYPE}-{NNN}
title: {从 PR 标题或首条 commit message 推断}
type: {从 commit message 前缀推断：feat→FEAT, fix→FIX, refactor→REFACTOR, 无法推断→CHORE}
level: {从改动文件数推断：1-3 文件→L1, 4-10→L2, 10+→L3}
status: completed
record_mode: backfilled
backfill_reason: {用户说明或「流程外改动，事后补录」}
backfilled_at: {ISO 8601}
original_branch: {分支名}
original_pr: {PR 编号，如有}
---
```

### 步骤三：自动补全 meta

读取 `.feflow/init-config.md` 获取项目配置，填充：

- `modules` — 从改动文件路径推断涉及模块
- `created_at` — 取最早相关提交时间
- `completed_at` — 取最晚相关提交时间或 PR 合并时间

### 步骤四：生成简版文档

在 `.feflow/items/{ITEM-ID}/` 下生成精简版文档（不要求完整流程产出）：

1. **`role-pm/requirement-brief.md`** — 从 PR 描述和 commit message 反向提取需求摘要，标注「事后补录，非正式需求文档」
2. **`role-fe/dev-plan.md`** — 从实际改动文件列表生成改动清单，标注「事后补录，基于实际改动反向生成」
3. **`role-qa/test-report.md`** — 从 CI 结果生成测试摘要，标注「事后补录，基于 CI 结果」
4. **`evidence/evidence.md`** — 调用 evidence-ledger 生成完整证据

### 步骤五：输出缺失项清单

对比完整流程应有产出，列出缺失项：

```markdown
## 补录完整度评估

### 已补录
- ✅ Item 创建（backfilled）
- ✅ 证据账本
- ✅ 需求摘要（简版）
- ✅ 改动清单（简版）

### 缺失项
- ❌ 正式需求评审记录
- ❌ 开发计划评审记录
- ❌ 历史问题对照
- ❌ 完整测试报告

### 建议
- 如需补充，可手动编辑对应文件
- 缺失项不影响后续任务的记忆检索
```

## 批量补录

当 repo-scan 发现多条未登记改动时：

1. 按分支/PR 分组，逐个执行补录
2. 每个补录独立成 Item，不合并
3. 输出汇总表：补录数量 / 成功 / 失败 / 缺失项统计

## 错误处理

| 场景 | 处理 |
|------|------|
| 无法推断任务类型 | 默认 CHORE，标记「类型需人工确认」 |
| PR 已删除 | 仅从 git log 补录，标记「PR 信息不可用」 |
| `gh` 不可用 | 跳过 PR/CI 信息，仅从 git 补录 |
| Item ID 冲突 | 自动递增编号，避免覆盖已有 Item |
