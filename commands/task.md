---
description: 交付入口。用于真正要落地的研发任务；按风险决定是否创建 Item。
disable-model-invocation: true
shell: bash
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# /task

进入 feflow Delivery 模式，或查看已有工作项。

```!
set -euo pipefail

task_input="$ARGUMENTS"
trimmed_input="$(printf '%s' "$task_input" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
dispatch_mode="delivery"

case "$trimmed_input" in
  list)
    dispatch_mode="list"
    ;;
  dashboard)
    dispatch_mode="dashboard"
    ;;
  deps)
    dispatch_mode="deps"
    ;;
  evidence*)
    dispatch_mode="evidence"
    ;;
esac

package_manager="unknown"
if [ -f pnpm-lock.yaml ]; then
  package_manager="pnpm"
elif [ -f package-lock.json ]; then
  package_manager="npm"
elif [ -f yarn.lock ]; then
  package_manager="yarn"
elif [ -f bun.lockb ] || [ -f bun.lock ]; then
  package_manager="bun"
fi

framework="unknown"
if find . -maxdepth 1 -type f -name 'nuxt.config.*' | grep -q .; then
  framework="Nuxt"
elif [ -f package.json ] && grep -qi '"vue"' package.json; then
  if find . -maxdepth 1 -type f -name 'vite.config.*' | grep -q .; then
    framework="Vue 3 + Vite"
  else
    framework="Vue"
  fi
fi

workspace_initialized="false"
if [ -d .feflow ]; then
  workspace_initialized="true"
fi

git_status_count="0"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git_status_count="$(git status --short | sed '/^$/d' | wc -l | tr -d ' ')"
fi

printf 'BEGIN_FEFLOW_TASK_DISPATCH\n'
printf 'task_input=%s\n' "${trimmed_input:-<empty>}"
printf 'dispatch_mode=%s\n' "$dispatch_mode"
printf 'project_root=%s\n' "$(pwd)"
printf 'workspace_initialized=%s\n' "$workspace_initialized"
printf 'package_manager=%s\n' "$package_manager"
printf 'framework=%s\n' "$framework"
printf 'git_status_count=%s\n' "$git_status_count"
printf 'top_level_files:\n'
find . \
  \( -path './.git' -o -path './node_modules' -o -path './dist' \) -prune \
  -o -maxdepth 2 -type f -print | sed 's#^\./##' | sort | sed -n '1,60p'

if [ "$dispatch_mode" = "delivery" ] && [ -n "$trimmed_input" ]; then
  printf 'filename_hits:\n'
  if command -v rg >/dev/null 2>&1; then
    printf '%s\n' "$trimmed_input" \
      | tr '[:space:]/:_-' '\n' \
      | sed 's/[^[:alnum:]]//g' \
      | sed '/^$/d' \
      | grep -E '.{3,}' \
      | sort -fu \
      | sed -n '1,5p' \
      | while read -r token; do
          printf '[%s]\n' "$token"
          rg --files . | sed 's#^\./##' | rg -i --fixed-strings "$token" | sed -n '1,5p' || true
        done
  else
    printf 'rg-missing\n'
  fi
fi

printf 'END_FEFLOW_TASK_DISPATCH\n'
```

## Dispatch 约束

上面的 task dispatch 已在你生成回复前执行。

因此：

- 不要再用“我先看一下 / 我先规划一下”作为开场
- 第一条用户可见文本必须引用已经检查到的文件面或边界
- `dispatch_mode=delivery` 时，不要把这轮回复写成治理流程介绍
- `dispatch_mode=list/dashboard/deps/evidence` 时，直接基于当前工作区继续，不要重讲 `/task` 的语义
- 不要在这个命令里再调用无关的外部 persona / workflow skill，例如 `pua:*`
- 不要输出 `★ Insight`
- 不要套用“1. 改动概述 / 2. 修改原因 / 3. 影响范围 ...”这种审计模板
- 如果接下来要继续用 `Read / Grep / Edit / Bash`，可以继续，但第一条文本必须已经带有检查后的事实
- L1 任务默认直接用 `Bash / Read / Write / Edit / Grep / Glob` 推进，不要再绕去外部 skill 或待办流程
- 如果需要补一句下一步，只保留一行，不要编号，不要展开多路线说明

## 触发方式

```
/task 实现用户登录页面         # 开始交付任务
/task 修复构建失败             # 开始交付任务
/task list                    # 查看工作项列表
/task dashboard               # Item 状态全景仪表盘
/task evidence {ITEM-ID}      # 查看某个 Item 的证据画像
/task deps                    # 查看 Item 依赖关系图
```

## 模式说明

`/task` 不是“任何任务都必须立项”的入口，而是“需要真正交付”的入口。

当用户要修改代码、配置、测试、脚本、文档或交付可执行结果时，进入 Delivery 模式。

## 执行逻辑

### 开始交付（/task [描述]）

当参数为任务描述时：

1. 在当前会话直接按 `orchestrator` 规则进行模式与风险判断。
2. 先用现有 repo / 文件工具读取最相关的文件、入口或搜索面，再根据事实判断风险。
3. 先判断任务级别和执行路径：
   - **L1 / 低风险**：可直接分析、修改、验证，不默认创建 Item。
   - **L2 / 中风险**：先给短计划并连续推进；只有在会话跨度、依赖或证据需求明显时再创建 Item。
   - **L3 / 高风险**：应创建 Item，并启用更严格的评审、验证和回滚约束。
   - **Incident / 事件型**：应改走 `/incident` 或等价事件路径。
4. 仅在以下场景默认创建 Item：
   - 任务跨多个会话、多人协作或存在明确依赖
   - 需要长期追踪、证据链或依赖关系
   - 用户明确要求走完整治理流程
5. 对于普通单点改动，不应为了“流程完整”强行要求初始化或立项。

## Tool-First Dispatch

`/task` 是交付调度命令，不是流程解说命令。

如果当前会话元数据已经暴露 `Bash / Read / Edit / Write / Grep / Glob`：

1. 把这些工具视为当前回合可用
2. 先读事实，再说风险和计划
3. 不要先输出“我会如何处理”，却不开始任何文件检查
4. 不要声称“当前没有可用文件工具”，除非具体工具调用已经返回失败
5. 如果上方 dispatch 已经给出了检查结果，则第一条用户可见文本应使用完成态，而不是“我先 …”

对于 L1：

- 理想路径是同一回合完成 inspect -> edit -> verify -> summarize
- 如果无法在同一回合完成 edit，至少也应在第一条用户可见文本里明确“已经检查了哪些文件/入口”

对于 L2/L3：

- 先 inspect -> compact risk note -> continue
- 不要把 FE / QA / Reviewer / PM 讲成显式串行交接

## 可见性约束

用户可见文本里不要出现：

- “使用 superpowers:using-superpowers”
- “使用 feflow:orchestrator”
- “使用 feflow:project-init”
- “我会调用 FE / QA / Reviewer”

应该直接面向任务说：

- 将检查哪些文件
- 为什么这里是风险边界
- 下一步直接做什么
- 若 dispatch 已完成初查，则直接说“已经定位到哪些文件/边界”

### 查看列表（/task list）

当参数为 `list` 时：

1. 读取 `.feflow/items/` 目录下的所有 Item 文件
2. 按状态分组展示：
   - 进行中的 Item
   - 待处理的 Item
   - 已完成的 Item
3. 每个 Item 展示：ID、标题、级别、当前状态、创建时间

### 仪表盘（/task dashboard）

按 `dashboard` 规则展示所有 Item 的状态分布、进度概览和风险提示。

### 证据链（/task evidence {ITEM-ID}）

按 `evidence-chain` 规则展示指定 Item 在当前风险等级下的证据画像与关键缺口。

### 依赖关系（/task deps）

按 `item-orchestration` 规则展示当前所有活跃 Item 的依赖图和执行状态。

## 前置条件与降级策略

- `/task list`、`/task dashboard`、`/task evidence`、`/task deps` 依赖 `.feflow/` 工作区。
- 若用户只是开始一个低风险交付任务，`.feflow/` 未初始化不应成为阻塞。
- 只有当任务需要治理能力时，才提示用户使用 `/init` 建立工作区。

## 首条用户可见输出契约

### L1 / 低风险

若 dispatch 已完成初查，则首条用户可见输出应直接指向**已经检查到**的文件或模块，并默认连续执行。

推荐形态：

- “我已经定位到 README 顶部这段文案，接下来直接改成更直接的表述，再做一次快速检查。”
- “我已经看到变更集中在 `src/router` 和登录态 store，先补最小修正再校验。”

不要这样开场：

- “我先创建 Item”
- “我先写需求文档”
- “第一阶段完成，请确认”
- “使用 superpowers:using-superpowers ...”
- “当前没有可用文件工具，我先说一下方案”
- “我先研究一下，再回来告诉你计划”
- “1. 改动概述 / 2. 修改原因 / 3. 影响范围 ...”

暂停预算：

- 理想值：`0`
- 最大可接受：`1`

### L2 / L3 / 中高风险

首条用户可见输出应先说明**已识别到**的风险来源，再说明会先继续压哪些边界。

如果真的需要确认，最多只在关键 scope / rollback 点停一次。

推荐形态：

- “我已经看到这次会碰到登录态、路由守卫和 SSR 边界，接下来先把相关模块和现有启动链路压实；只有范围或回滚边界不清时才停一次确认。”

不要把首条用户可见输出写成阶段播报或连续审批请求。
也不要把底层 skill/router 名称暴露给用户。

暂停预算：

- 理想值：`1`
- 最大可接受：`2`
