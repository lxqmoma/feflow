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

1. 确认当前目录是 Git 仓库（`git rev-parse --git-dir`），否则终止
2. 确认 `.feflow/` 目录存在（项目已初始化），否则提示先运行 `feflow:project-init`
3. 读取 `.feflow/init-config.md` 获取项目配置参数（branch_strategy、workflow_binding、item_id_format 等）

## 四层扫描

### 第一层：分支态扫描

获取当前分支的完整状态信息。

```bash
# 当前分支名
CURRENT_BRANCH=$(git branch --show-current)

# 默认分支（远程 HEAD 指向）
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
# 如果上面失败，尝试常见默认分支
if [ -z "$DEFAULT_BRANCH" ]; then
  for branch in main master develop; do
    if git show-ref --verify --quiet "refs/remotes/origin/$branch" 2>/dev/null; then
      DEFAULT_BRANCH="$branch"
      break
    fi
  done
fi

# 本地是否有未提交的修改
DIRTY=$(git status --porcelain | head -20)
if [ -n "$DIRTY" ]; then
  DIRTY_STATUS="dirty"
  DIRTY_FILES=$(git status --porcelain | wc -l | tr -d ' ')
else
  DIRTY_STATUS="clean"
  DIRTY_FILES=0
fi

# 与默认分支的 ahead/behind 差距
AHEAD_BEHIND=$(git rev-list --left-right --count "origin/${DEFAULT_BRANCH}...HEAD" 2>/dev/null)
BEHIND=$(echo "$AHEAD_BEHIND" | awk '{print $1}')
AHEAD=$(echo "$AHEAD_BEHIND" | awk '{print $2}')

# 与远程追踪分支的同步状态
TRACKING=$(git for-each-ref --format='%(upstream:short)' "refs/heads/${CURRENT_BRANCH}" 2>/dev/null)
if [ -n "$TRACKING" ]; then
  TRACK_AHEAD_BEHIND=$(git rev-list --left-right --count "${TRACKING}...HEAD" 2>/dev/null)
  TRACK_BEHIND=$(echo "$TRACK_AHEAD_BEHIND" | awk '{print $1}')
  TRACK_AHEAD=$(echo "$TRACK_AHEAD_BEHIND" | awk '{print $2}')
else
  TRACKING="none"
  TRACK_BEHIND=0
  TRACK_AHEAD=0
fi

# 所有本地分支列表（按最近提交时间排序）
git branch --sort=-committerdate --format='%(refname:short) %(committerdate:relative)' | head -15

# stash 数量
STASH_COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
```

### 第二层：最近提交扫描

分析最近的提交历史，识别活跃区域和协作模式。

```bash
# 最近 20 条提交（单行格式）
git log --oneline --decorate -20

# 最近 20 条提交的详细信息（用于后续分析）
git log --format='%H|%an|%ae|%ad|%s' --date=iso -20

# 活跃文件热度图：最近 20 次提交中被修改最多的文件
git log -20 --pretty=format: --name-only | sort | uniq -c | sort -rn | head -15

# 活跃目录热度图：最近 20 次提交中被修改最多的目录
git log -20 --pretty=format: --name-only | xargs -I{} dirname {} 2>/dev/null | sort | uniq -c | sort -rn | head -15

# 作者分布（最近 30 天）
git shortlog -sn --since="30 days ago" --no-merges

# 最近合并提交
git log --merges --oneline -5

# 提交频率（最近 7 天每天提交数）
for i in $(seq 0 6); do
  DATE=$(date -v-${i}d "+%Y-%m-%d" 2>/dev/null || date -d "${i} days ago" "+%Y-%m-%d")
  COUNT=$(git log --oneline --after="${DATE} 00:00:00" --before="${DATE} 23:59:59" | wc -l | tr -d ' ')
  echo "${DATE}: ${COUNT}"
done
```

**热度图分析规则：**
- 单个文件在 20 次提交中出现 >= 5 次：标记为「高频修改文件」
- 单个目录在 20 次提交中出现 >= 8 次：标记为「活跃模块」
- 多个不同作者修改同一文件/目录：标记为「潜在冲突区域」

### 第三层：工作项对账

将 Git 提交与 feflow 工作项进行交叉对账。此层依赖 `.feflow/init-config.md` 中的 `item_id_format` 配置。

```bash
# 读取 item_id_format 配置
ITEM_PATTERN=$(grep 'item_id_format' .feflow/init-config.md | sed 's/.*: *//' | tr -d '"')

# 如果 item_id_format 为 none，跳过对账
if [ "$ITEM_PATTERN" = "none" ]; then
  echo "工作项绑定未启用，跳过对账"
else
  # 提取最近 20 条提交中的工作项 ID
  git log -20 --format='%H %s' | grep -oP "$ITEM_PATTERN" | sort -u > /tmp/feflow_commit_items.txt

  # 获取 .feflow/items/ 下已登记的工作项
  ls .feflow/items/ 2>/dev/null | sed 's/\.md$//' | sort -u > /tmp/feflow_registered_items.txt
fi
```

**对账结果分类：**

| 状态 | 含义 | 判断条件 |
|------|------|----------|
| 未登记改动 | 有 commit 但无对应 Item | commit message 中无 item_id，或 item_id 在 `.feflow/items/` 中不存在 |
| 未推进工作项 | 有 Item 但无对应 commit | `.feflow/items/` 中存在状态为 `in-progress` 的 Item，但近 20 条 commit 中无其 ID |
| 状态漂移 | Item 状态与实际不符 | Item 标记为 `done` 但关联分支未合并，或标记为 `in-progress` 但超过 7 天无新提交 |

### 第四层：发布态扫描

检测当前的发布状态，按证据强度分级判断。

```bash
# 最近的 tag（版本号格式）
LATEST_TAG=$(git tag --sort=-version:refname --list 'v*' | head -1)
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG=$(git tag --sort=-version:refname | head -1)
fi

# tag 对应的提交时间
if [ -n "$LATEST_TAG" ]; then
  TAG_DATE=$(git log -1 --format='%ai' "$LATEST_TAG" 2>/dev/null)
  TAG_COMMIT=$(git rev-list -1 "$LATEST_TAG" 2>/dev/null)
  # 当前 HEAD 与最近 tag 之间的提交数
  COMMITS_SINCE_TAG=$(git rev-list "${LATEST_TAG}..HEAD" --count 2>/dev/null)
fi

# 检查 release 分支
RELEASE_BRANCHES=$(git branch -a --list '*release*' --sort=-committerdate 2>/dev/null | head -5)

# 检查是否存在预发布 tag（alpha/beta/rc）
PRERELEASE_TAGS=$(git tag --list '*alpha*' '*beta*' '*rc*' --sort=-version:refname | head -5)

# 最近的 GitHub Release（如果使用 gh CLI）
gh release list --limit 3 2>/dev/null || echo "gh CLI 不可用或非 GitHub 仓库"
```

**发布态判断规则（按证据强度分级）：**

| 证据强度 | 发布态 | 判断条件 |
|----------|--------|----------|
| 强证据 | 已发布 | HEAD 直接指向一个版本 tag |
| 强证据 | 发布准备中 | 存在活跃的 release 分支，且有近期提交 |
| 中等证据 | 开发中 | HEAD 领先最近 tag >= 5 个提交 |
| 中等证据 | 预发布 | 最近 tag 包含 alpha/beta/rc 标识 |
| 弱证据 | 状态不明 | 无 tag 或无法确定版本策略 |

## 输出格式

在 `.feflow/` 目录下生成 `00-repo-scan.md`：

```markdown
---
generated_by: "feflow:repo-scan"
generated_at: "<ISO 8601>"
scan_duration_ms: <扫描耗时毫秒数>
branch: "<当前分支>"
default_branch: "<默认分支>"
dirty: <true|false>
behind_default: <behind 数量>
ahead_default: <ahead 数量>
release_state: "<released|preparing|developing|prerelease|unknown>"
release_evidence: "<strong|medium|weak>"
unregistered_commits: <未登记改动数量>
stale_items: <未推进工作项数量>
drifted_items: <状态漂移工作项数量>
alerts: <告警数量>
---

# 仓库态势感知报告

> 生成时间：{generated_at}
> 扫描分支：{branch}

## 分支状态

| 指标 | 值 |
|------|-----|
| 当前分支 | {branch} |
| 默认分支 | {default_branch} |
| 远程追踪 | {tracking} |
| 工作区 | {dirty_status}（{dirty_files} 个未提交文件） |
| 落后默认分支 | {behind} 个提交 |
| 领先默认分支 | {ahead} 个提交 |
| 落后远程追踪 | {track_behind} 个提交 |
| 领先远程追踪 | {track_ahead} 个提交 |
| Stash | {stash_count} 条 |

## 最近提交

| 时间 | 作者 | 提交信息 |
|------|------|----------|
| ... | ... | ... |

### 活跃文件 TOP 10

| 修改次数 | 文件路径 |
|----------|----------|
| ... | ... |

### 活跃目录 TOP 10

| 修改次数 | 目录路径 |
|----------|----------|
| ... | ... |

### 作者分布（近 30 天）

| 提交数 | 作者 |
|--------|------|
| ... | ... |

## 工作项对账

### 未登记改动
> 以下提交未关联任何工作项

| 提交 | 时间 | 作者 | 信息 |
|------|------|------|------|
| ... | ... | ... | ... |

### 未推进工作项
> 以下工作项状态为进行中，但近期无关联提交

| 工作项 ID | 标题 | 最后活跃 |
|-----------|------|----------|
| ... | ... | ... |

### 状态漂移
> 以下工作项的登记状态与实际证据不符

| 工作项 ID | 登记状态 | 实际状态 | 原因 |
|-----------|----------|----------|------|
| ... | ... | ... | ... |

## 发布态

| 指标 | 值 |
|------|-----|
| 最近 tag | {latest_tag} |
| tag 时间 | {tag_date} |
| tag 后提交数 | {commits_since_tag} |
| 发布态判断 | {release_state} |
| 证据强度 | {release_evidence} |
| Release 分支 | {release_branches} |

## 告警

{根据下方规则生成的告警列表}
```

## 模式切换规则

扫描结果产出后，根据以下规则生成告警并建议操作模式：

### 同步告警

**触发条件：** `behind_default >= 10`

```
[告警] 当前分支落后默认分支 {behind} 个提交，建议在开始新任务前先同步：
  git fetch origin
  git rebase origin/{default_branch}
```

### 冲突预警

**触发条件：** 活跃目录 TOP 10 中，某个目录被 >= 3 个不同作者在近 20 次提交中修改

```
[告警] 模块 {目录} 近期被多人修改（{作者列表}），存在潜在合并冲突风险。
建议：
1. 开始修改前先 pull 最新代码
2. 提交粒度尽量小
3. 与相关开发者确认修改范围是否重叠
```

### 未登记改动提醒

**触发条件：** `workflow_binding != "none"` 且存在未关联工作项的提交

```
[提醒] 发现 {count} 个未关联工作项的提交。
建议：使用 feflow 补录工作项，或在后续提交中关联已有工作项 ID。
未登记提交列表：
  - {commit_hash} {commit_message}
  - ...
```

### 发布窗口提醒

**触发条件：** 存在活跃的 release 分支

```
[提醒] 检测到活跃的发布分支 {branch_name}，当前可能处于发布窗口期。
建议：
1. 非发布相关的改动避免合入 release 分支
2. 确认当前任务是否与发布相关
```

### 工作区脏状态提醒

**触发条件：** `dirty_files > 0`

```
[提醒] 工作区有 {dirty_files} 个未提交的文件：
{文件列表前 10 个}
建议：提交、暂存（stash）或清理后再开始新任务。
```

### 长期未推进提醒

**触发条件：** 存在状态漂移的工作项

```
[提醒] 以下工作项状态与实际情况不符，建议更新：
  - {item_id}: 登记为 {registered_status}，但 {drift_reason}
```

## 性能要求

- 全量扫描应在 10 秒内完成
- 如果 `git log` 耗时超过 5 秒（大仓库），减少扫描范围至近 10 条提交
- 如果 `.feflow/items/` 下工作项文件超过 100 个，只对账近 30 天的工作项

## 错误处理

- 不在 Git 仓库中：终止扫描，输出错误信息
- `.feflow/` 不存在：终止扫描，提示先运行 `feflow:project-init`
- `init-config.md` 不存在：以默认配置（`workflow_binding: none`）运行扫描，输出警告
- Git 远程不可达：跳过 ahead/behind 计算和远程分支检查，标记为「远程信息不可用」
- `gh` CLI 不可用：跳过 GitHub Release 检查，不影响其他扫描
- 对账过程中某个 item 文件解析失败：记录错误并跳过该 item，继续处理其余项
