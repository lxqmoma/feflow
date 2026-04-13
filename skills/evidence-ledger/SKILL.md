---
name: evidence-ledger
description: 证据账本管理。v2 中它按风险选择 minimal / partial / full 证据级别，只收集当前判断真正需要的材料。
---

# evidence-ledger：v2 证据采集

## 触发条件

- 被追踪任务即将 externalize（PR / merge / deploy）
- 高风险任务需要可审计证据
- 用户显式要求查看或沉淀证据
- 事故恢复后需要补充最小恢复证据

## 前置条件

优先条件：

- 当前目录是 Git 仓库
- 存在 Item 或明确的任务上下文

若无 Item，可退化为临时证据摘要，不必报硬错误。

## 核心原则

1. 证据应服务于验证和追踪，而不是制造流程负担
2. 先收“能证明事实”的材料，再考虑包装
3. 当证据与文档说法冲突时，以证据为准
4. 不为低风险任务伪造完整证据包

## 证据级别

### `minimal`

适用于：

- L1
- 内部低风险修改
- 未追踪但用户要求快速给出证据摘要

至少收集：

- 改动文件或 diff 摘要
- 实际运行的检查 / 测试
- 残余风险说明

### `partial`

适用于：

- L2
- 已追踪但未 externalize 的一般交付

在 `minimal` 基础上补充：

- 相关 commits
- 更明确的验证证据

### `full`

适用于：

- L3
- externalize 前
- 审计或正式 review

在 `partial` 基础上补充：

- PR
- CI
- deploy / release
- 必要时 release note 或 retrospective

### `incident-overlay`

用于事故或 hotfix 任务，额外补充：

- 事故影响摘要
- 止血动作
- 回滚或兜底路径
- 恢复验证

## 证据收集

### Git 证据

1. **分支** — `git branch -a | grep {ITEM-ID}`
2. **提交** — `git log --all --grep="{ITEM-ID}"`，提取 hash、作者、时间、message
3. **Tag** — `git tag --contains {commit-hash}`
4. **Diff 统计** — 改动文件数、新增行数、删除行数

### PR / CI / Deploy 证据（按需）

依赖 `gh` CLI，不可用时标记「需手动补充」：

- **PR** — `gh pr list --search "{ITEM-ID}"`，获取编号、标题、状态、reviewer
- **CI** — `gh pr checks`，获取各检查项 pass/fail/pending
- **Deploy** — 从 PR bot 评论提取 preview 地址，或查询 GitHub Deployments API

## 产出策略

### 有 Item

写入 `.feflow/items/{ITEM-ID}/evidence/evidence.md`

### 无 Item

直接输出内联证据摘要

## 证据内容

frontmatter 至少应含：

- `item_id`
- `generated_at`
- `evidence_level`
- `evidence_source: auto`

正文按级别选取需要的区块：

- **改动事实** — 文件、diff 范围、主要改动点
- **验证事实** — 跑了什么、结果如何
- **提交记录** — Hash / 作者 / 时间 / Message
- **PR / CI** — 仅在对应级别需要时补充
- **部署 / 发布** — 仅在 externalize 或 incident 需要时补充
- **残余风险** — 当前还不能证明的部分

## 不一致检测（按需）

只在存在相应材料时才做对比：

- 若存在 `dev-plan.md`，可对比声明范围与实际改动范围
- 若存在 `implementation-log.md`，可对比记录步骤与实际提交/检查
- 若存在 `test-report.md`，可对比报告中的验证项与实际证据

不具备前置材料时，跳过该类对比，不要硬报缺失。

发现差异时标记为 `⚠️ 偏差`，并说明它影响的是范围信任、验证信任，还是发布信任。

## 错误处理

| 场景 | 处理 |
|------|------|
| 无匹配提交 | 警告「未找到包含 {ITEM-ID} 的提交」，允许退化为文件级证据 |
| `gh` 不可用 | 跳过 PR/CI/Deploy，标记待补充 |
| 部分信息缺失 | 已获取的正常输出，缺失项按级别判断为 required / expected / optional |
