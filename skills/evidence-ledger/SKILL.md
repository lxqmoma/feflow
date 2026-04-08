---
name: evidence-ledger
description: 证据账本管理。自动收集和维护每个 Item 的 Git/PR/CI/Deploy 证据，确保流程可追溯。
---

# evidence-ledger：证据账本管理

## 触发条件

- flow 发布阶段（阶段 7）由 orchestrator 自动调用
- quality-gate Gate 2 通过后、创建 PR 前调用
- 用户执行 `/feflow-evidence` 或明确要求收集证据

## 前置条件

1. 当前目录是 Git 仓库
2. `.feflow/items/{ITEM-ID}/` 目录存在
3. Item 已进入 implementing 或更后阶段

## 核心原则

**证据层是最高可信度来源**，优先于文档描述和人工声明。当证据与文档矛盾时，以证据为准，并标记不一致项。

## 证据收集

### Git 证据

1. **分支** — `git branch -a | grep {ITEM-ID}`
2. **提交** — `git log --all --grep="{ITEM-ID}"`，提取 hash、作者、时间、message
3. **Tag** — `git tag --contains {commit-hash}`
4. **Diff 统计** — 改动文件数、新增行数、删除行数

### PR / CI / Deploy 证据

依赖 `gh` CLI，不可用时标记「需手动补充」：

- **PR** — `gh pr list --search "{ITEM-ID}"`，获取编号、标题、状态、reviewer
- **CI** — `gh pr checks`，获取各检查项 pass/fail/pending
- **Deploy** — 从 PR bot 评论提取 preview 地址，或查询 GitHub Deployments API

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

## PR
- PR #{N} — {标题} — 状态: {open/merged}

## CI
- lint: ✅/❌ | type-check: ✅/❌ | unit-test: ✅/❌

## 部署
- Preview: {URL} | Release: {version}

## 统计
- 改动文件: {N} | +{N} 行 / -{N} 行
```

## 不一致检测

收集完成后自动对比：
- 证据文件列表 vs `dev-plan.md` 声明的改动范围
- 证据提交数 vs `implementation-log.md` 记录的步骤数
- 不一致项标记为 `⚠️ 偏差`

## 错误处理

| 场景 | 处理 |
|------|------|
| 无匹配提交 | 警告「未找到包含 {ITEM-ID} 的提交」|
| `gh` 不可用 | 跳过 PR/CI/Deploy，标记待补充 |
| 部分信息缺失 | 已获取的正常输出，缺失项标记「待补充」|
