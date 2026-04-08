---
name: evidence-ledger
description: 证据账本管理。自动收集和维护每个 Item 的 Git/PR/CI/Deploy 证据，确保流程可追溯。
---

# evidence-ledger：证据账本管理

## 触发条件

- flow 的发布阶段（阶段 7）由 orchestrator 自动调用
- quality-gate Gate 2 通过后、创建 PR 前调用
- 用户执行 `/feflow-evidence` 或明确要求收集证据

## 前置条件

1. 当前目录是 Git 仓库
2. `.feflow/items/{ITEM-ID}/` 目录存在
3. Item 已进入 implementing 或更后阶段

## 核心原则

**证据层是最高可信度来源**，优先于文档描述和人工声明。
当证据与文档矛盾时，以证据为准，并标记不一致项。

## 证据收集步骤

### 步骤一：Git 证据

从 git log/branch/tag 收集与当前 Item ID 关联的数据：

1. **分支** — 查找名称包含 Item ID 的分支（`git branch -a | grep {ITEM-ID}`）
2. **提交** — 查找 commit message 包含 Item ID 的提交（`git log --all --grep="{ITEM-ID}"`），提取 hash、作者、时间、message
3. **Tag** — 查找关联的版本标签（`git tag --contains {commit-hash}`）
4. **Diff 统计** — 统计改动文件数、新增行数、删除行数

### 步骤二：PR 证据

检测 `gh` CLI 是否可用：

- 可用：`gh pr list --search "{ITEM-ID}"` 获取 PR 编号、标题、状态、reviewer、review 状态
- 不可用：标记「gh CLI 不可用，PR 信息需手动补充」

### 步骤三：CI 证据

检测 PR 关联的 CI 状态：

- `gh` 可用：`gh pr checks` 获取 CI 运行状态（pass/fail/pending）
- 不可用：标记「CI 信息需手动补充」

### 步骤四：Deploy 证据

检测部署信息（按可用性逐级降级）：

1. PR 中的 preview 地址（bot 评论中提取）
2. GitHub Deployments API（`gh api repos/{owner}/{repo}/deployments`）
3. 无法自动获取时标记「部署信息需手动补充」

## 产出

写入 `.feflow/items/{ITEM-ID}/evidence/evidence.md`：

```markdown
---
item_id: {ITEM-ID}
generated_at: {ISO 8601}
evidence_source: auto
---

# 证据账本

## 分支
- 分支名: feature/{ITEM-ID}-xxx
- 基于: main @ {base-hash}

## 提交记录
| Hash | 作者 | 时间 | Message |
|------|------|------|---------|
| abc1234 | dev | 2026-04-08 | feat(auth): 添加登录页 [FEAT-001] |

## PR
- PR #123 — 标题 — 状态: open/merged
- Reviewer: @xxx — 状态: approved/pending

## CI
- lint: ✅ pass
- type-check: ✅ pass
- unit-test: ✅ pass (coverage: 85%)

## 部署
- Preview: https://preview-xxx.vercel.app
- Release: v1.2.0

## 统计
- 改动文件: 8
- 新增: +320 行 / 删除: -45 行
```

## 不一致检测

收集完成后自动对比：

- 证据中的文件列表 vs `dev-plan.md` 声明的改动范围
- 证据中的提交数 vs `implementation-log.md` 记录的步骤数
- 不一致项标记为 `⚠️ 偏差` 并附说明

## 错误处理

| 场景 | 处理 |
|------|------|
| 无匹配提交 | 输出警告「未找到包含 {ITEM-ID} 的提交」 |
| `gh` 不可用 | 跳过 PR/CI/Deploy，标记为手动补充项 |
| 部分信息缺失 | 已获取的正常输出，缺失的标记「待补充」 |
