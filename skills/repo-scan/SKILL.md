---
name: repo-scan
description: 每次任务启动前使用。扫描 Git 仓库的分支状态、最近提交、发布态和工作项对账情况，产出结构化的态势感知报告。
---

# repo-scan：仓库态势感知

## 触发条件

- 每次 feflow 任务启动前自动调用
- 用户执行 `/feflow-scan` 或明确要求扫描仓库状态
- orchestrator 在分配任务前调用

## 前置检查

1. 确认当前目录是 Git 仓库，否则终止
2. 确认 `.feflow/` 目录存在，否则提示先运行 `feflow:project-init`
3. 读取 `.feflow/init-config.md` 获取项目配置参数

## 四层扫描

### 第一层：分支态扫描

获取当前分支完整状态：当前分支名、默认分支（远程 HEAD 或 main/master/develop 探测）、工作区脏状态、与默认分支的 ahead/behind、与远程追踪分支的同步状态、本地分支列表（按提交时间排序，前 15 个）、stash 数量。

### 第二层：最近提交扫描

分析最近 20 条提交：

- 提交历史（hash/作者/时间/信息）
- 活跃文件热度图（TOP 15）
- 活跃目录热度图（TOP 15）
- 作者分布（近 30 天）
- 最近 5 条合并提交
- 提交频率（近 7 天每天提交数）

**热度图标记规则：**
- 单文件 20 次提交中出现 >= 5 次 → 「高频修改文件」
- 单目录 20 次提交中出现 >= 8 次 → 「活跃模块」
- 多作者修改同一文件/目录 → 「潜在冲突区域」

### 第三层：工作项对账

将 Git 提交与 feflow 工作项交叉对账（依赖 `item_id_format` 配置，`none` 时跳过）。

| 状态 | 判断条件 |
|------|----------|
| 未登记改动 | commit 无 item_id 或 item_id 在 items/ 中不存在 |
| 未推进工作项 | Item 为 `in-progress` 但近 20 条 commit 无其 ID |
| 状态漂移 | Item 标记 `done` 但分支未合并，或 `in-progress` 超 7 天无提交 |

### 第四层：发布态扫描

检测发布状态，按证据强度分级：

| 证据强度 | 发布态 | 判断条件 |
|----------|--------|----------|
| 强 | 已发布 | HEAD 直接指向版本 tag |
| 强 | 发布准备中 | 存在活跃 release 分支且有近期提交 |
| 中 | 开发中 | HEAD 领先最近 tag >= 5 个提交 |
| 中 | 预发布 | 最近 tag 含 alpha/beta/rc |
| 弱 | 状态不明 | 无 tag 或无法确定版本策略 |

## 输出格式

在 `.feflow/` 下生成 `00-repo-scan.md`，frontmatter 包含：`generated_by` / `generated_at` / `scan_duration_ms` / `branch` / `default_branch` / `dirty` / `behind_default` / `ahead_default` / `release_state` / `release_evidence` / `unregistered_commits` / `stale_items` / `drifted_items` / `alerts`。

正文包含：分支状态表、最近提交表、活跃文件/目录 TOP 10、作者分布、工作项对账（未登记改动/未推进/状态漂移）、发布态信息、告警列表。

## 告警规则

| 告警类型 | 触发条件 | 建议 |
|----------|----------|------|
| 同步告警 | `behind_default >= 10` | 先 fetch + rebase |
| 冲突预警 | 目录被 >= 3 作者近期修改 | 先 pull、小粒度提交、确认范围 |
| 未登记改动 | `workflow_binding != "none"` 且存在未关联提交 | 补录工作项 |
| 发布窗口 | 存在活跃 release 分支 | 非发布改动避免合入 |
| 脏工作区 | `dirty_files > 0` | 提交/stash/清理后再开始 |
| 长期未推进 | 存在状态漂移工作项 | 更新 Item 状态 |

## 性能要求

- 全量扫描应在 10 秒内完成
- `git log` 耗时超 5 秒（大仓库）时，减少至近 10 条提交
- `.feflow/items/` 超 100 个文件时，只对账近 30 天工作项

## 错误处理

| 场景 | 处理 |
|------|------|
| 不在 Git 仓库 | 终止，输出错误信息 |
| `.feflow/` 不存在 | 终止，提示先运行 `project-init` |
| `init-config.md` 不存在 | 以默认配置运行，输出警告 |
| Git 远程不可达 | 跳过 ahead/behind 和远程分支检查，标记「远程信息不可用」 |
| `gh` CLI 不可用 | 跳过 GitHub Release 检查 |
| Item 文件解析失败 | 记录错误并跳过，继续处理其余项 |
