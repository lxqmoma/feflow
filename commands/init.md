---
description: 初始化 feflow 治理工作区。仅在需要持久化 Item、Memory、Evidence 时使用。
disable-model-invocation: true
shell: bash
allowed-tools: Bash, Read, Write, Edit, Grep, Glob
---

# /init

为当前项目开启最小可用的 feflow 治理工作区。

```!
set -euo pipefail

render_list() {
  if [ "$#" -eq 0 ]; then
    printf 'none'
  else
    local IFS=', '
    printf '%s' "$*"
  fi
}

project_root="$(pwd)"
today="$(date +%F)"
in_git_repo="false"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  in_git_repo="true"
fi

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

language="unknown"
if [ -f tsconfig.json ] || find . -maxdepth 2 -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.vue' \) | grep -q .; then
  language="TypeScript"
elif find . -maxdepth 2 -type f \( -name '*.js' -o -name '*.jsx' \) | grep -q .; then
  language="JavaScript"
fi

project_type="unknown"
if [ -f package.json ]; then
  project_type="frontend-web"
fi

created_dirs=()
for dir in \
  .feflow \
  .feflow/project \
  .feflow/items \
  .feflow/memory \
  .feflow/memory/project \
  .feflow/templates
do
  if [ ! -d "$dir" ]; then
    mkdir -p "$dir"
    created_dirs+=("$dir")
  fi
done

created_files=()
preserved_files=()

write_if_missing() {
  local target_file="${1:-}"
  shift || true
  if [ -e "$target_file" ]; then
    preserved_files+=("$target_file")
    cat >/dev/null
    return
  fi
  cat >"$target_file"
  created_files+=("$target_file")
}

write_if_missing .feflow/project/init-config.md <<EOF
---
name: init-config
version: 0.1
status: active
initialized_at: $today
workspace_mode: minimal
---

# 项目初始化配置

## 基本信息
- project_root: .
- project_type: $project_type
- package_manager: $package_manager
- framework: $framework
- language: $language
- in_git_repo: $in_git_repo

## 当前能力
- items: enabled
- project_memory: enabled
- templates: enabled
- repo_scan: not_started

## 初始化策略
- overwrite_existing_files: false
- fill_unknown_with_placeholder: true
- conservative_defaults: true

## 待后续补充
- app_mode: unknown
- deployment_model: unknown
- test_strategy: unknown
EOF

write_if_missing .feflow/memory/project/invariants.md <<EOF
---
name: project-invariants
type: project-memory
status: active
updated_at: $today
---

# 项目不变量

## 已确认
- 当前目录已启用最小 feflow 治理工作区
- 项目类型: $project_type
- 包管理器: $package_manager
- 框架: $framework
- 语言: $language

## 暂未确认
- app_mode: unknown
- deployment_model: unknown
- test_strategy: unknown

## 使用原则
- 未确认的信息一律保持为 unknown
- 后续结论优先基于代码和验证更新
- 不以猜测替代项目事实
EOF

write_if_missing .feflow/memory/project/coding-doctrine.md <<EOF
---
name: coding-doctrine
type: project-memory
status: active
updated_at: $today
---

# 编码原则

## 默认原则
- 优先正确性、安全性、可维护性、可回滚性
- 优先最小必要修改
- 优先复用现有实现与现有模式
- 未验证的信息不得当作事实

## 执行原则
- 修改前先理解调用链、数据流和边界条件
- 优先修根因，不做脆弱补丁
- 非必要不改接口、目录结构、配置和依赖
- 修改后至少做最小必要验证

## 治理原则
- 先建立抓手，再逐步补全上下文
- 事实、决策、证据分层沉淀
- 治理文档先保守、再迭代，不一次性写满
EOF

printf 'BEGIN_FEFLOW_INIT_DISPATCH\n'
printf 'project_root=%s\n' "$project_root"
printf 'project_type=%s\n' "$project_type"
printf 'in_git_repo=%s\n' "$in_git_repo"
printf 'package_manager=%s\n' "$package_manager"
printf 'framework=%s\n' "$framework"
printf 'language=%s\n' "$language"
printf 'created_dirs=%s\n' "$(render_list "${created_dirs[@]}")"
printf 'created_files=%s\n' "$(render_list "${created_files[@]}")"
printf 'preserved_files=%s\n' "$(render_list "${preserved_files[@]}")"
printf 'workspace_tree:\n'
find .feflow -maxdepth 3 | sort
printf 'END_FEFLOW_INIT_DISPATCH\n'
```

## Dispatch 约束

上面的 init dispatch 已在你生成回复之前执行。

因此：

- 不要再以“我先 / 我会 / 接下来初始化”作为主句
- 不要把这次回复写成初始化思路说明
- 首条用户可见文本必须直接基于 `BEGIN_FEFLOW_INIT_DISPATCH` 的结果汇报
- 不要在这个命令里再调用无关的外部 persona / workflow skill，例如 `pua:*`
- 不要输出 `★ Insight`
- 不要套用“1. 改动概述 / 2. 修改原因 / 3. 影响范围 ...”这种审计模板
- 如果 `created_*` 为 `none`，说明这是一次幂等校验或补全，不要假装刚刚新建了不存在的内容
- 如果 `preserved_files` 不为 `none`，明确说明已有文件被保留、未覆盖
- 先给结果，再给下一步建议
- 如果需要给后续建议，只保留一行，不要编号，不要列多条路线
- 默认直接用 `Bash / Read / Write / Edit / Grep / Glob` 推进，不要再绕去外部 skill 或待办流程

## 触发方式

```
/init
```

## 执行逻辑

1. 在当前会话直接按 `project-init` 规则执行初始化
2. 把 `/init` 当成**可能只有一回合完成机会**的执行请求；不要把整轮命令浪费在开场白上
3. 若宿主提供 `Bash` / `Write` / `Edit` / `Read` 这类正常文件工具，优先立刻用它们检查、创建、补齐、验证
4. 最小工作区至少包括：
   - `.feflow/project/`
   - `.feflow/items/`
   - `.feflow/memory/project/`
   - `.feflow/templates/`
   - `.feflow/project/init-config.md`
   - `.feflow/memory/project/invariants.md`
   - `.feflow/memory/project/coding-doctrine.md`
5. 若存在轻量扫描能力，可补入保守默认值；若暂时无法确认，则标记为 `unknown`，不阻塞初始化
6. 若宿主提供正常文件工具，必须在**当前这一回合**真实完成至少一次目录创建、文件生成、或缺失项补全；不能只描述“接下来会做什么”
7. 初始化完成后输出最小状态摘要和推荐的下一步

## 命令语义

`/init` 是聊天命令，不是 shell 命令。

不要：

- 让用户去输入 `! /feflow:init`
- 声称“缺少 skill/tool 入口所以不能执行”

如果当前宿主允许正常文件操作，就应该直接创建或补齐工作区。

## Harness 约束

`/init` 不是“是否允许初始化”的讨论入口，而是一个执行请求。

因此：

- 不要把内部 `skill` 名称描述成外部运行时依赖
- 不要把 “TaskCreate / tool entry 不存在” 当成初始化失败原因
- 当前宿主有文件写入能力时，直接执行
- 在 Claude Code 这类带 `Bash / Write / Edit / Read` 的宿主里，先调用工具再讲长解释
- 如果当前会话元数据里已经列出了 `Bash / Read / Write / Edit`，不要再声称“没有可用文件工具”
- 当前宿主确实没有文件写入能力时，简短说明宿主限制，并给出可直接落盘的补丁或文件结果
- 当前宿主有文件工具时，不要在只输出一段“我先去做”之后直接结束当前回合
- 不要要求用户“再发一次 `/feflow:init`”来触发真正执行
- 不要在用户可见文本里说“使用 superpowers:using-superpowers”或“使用 feflow:project-init”

## 行为边界

`/init` 的职责是开启治理工作区，不是顺手执行一轮完整仓库研究。

它应该：

- 建立最小目录和配置
- 修复已有但不完整的工作区
- 说明现在哪些能力已经可用

它不应该：

- 把初始化包装成一轮重流程问答
- 在没有必要时自动跑完整 repo-scan
- 把普通分析任务重定向成“先 init 再说”
- 把用户卡在“继续手动初始化 / 同意，继续”这类低价值确认上
- 把首轮回复写成“准备执行”的口头承诺，然后没有任何真实落盘动作就结束

## 前置条件

- 当前目录为有效的项目目录（包含 `package.json` 或其他项目配置文件）

## 何时使用

适用于需要完整治理能力时：

- 持久化 Item
- 管理项目记忆
- 沉淀证据链
- 查看依赖关系或仪表盘

以下场景通常不需要先执行 `/init`：

- 只读理解仓库
- 架构或插件分析
- 普通总结和解释
- 很多 L1 小范围任务

## 幂等性

重复执行时：
- 若已初始化，提示当前状态并跳过
- 若部分初始化（目录存在但配置缺失），补全缺失部分

## 确认策略

以下情况默认**不需要**用户再确认一次：

- 创建缺失的 `.feflow/` 目录
- 生成缺失的基础 Markdown 配置文件
- 以保守默认值填充初始化元信息
- 修复“不完整但无冲突”的治理工作区

只有这些情况才允许暂停一次：

- 现有 `.feflow/` 文件明显由用户手写，且初始化模板会覆盖它
- 当前路径是否为项目根目录存在实质歧义
- 用户请求的其实不是“最小初始化”，而是顺带跑一轮更重的仓库治理扫描

## 首条用户可见输出契约

如果上方 dispatch 已成功执行，则第一条用户可见文本应是**执行后的状态摘要**，不是执行前的计划说明。

如果宿主有文件操作能力，则命令在当前这一回合里已经有了真实工具动作；不要再把这轮回复写成“准备开始”。
如果宿主是 Claude Code 一类会在 slash command 后直接 `end_turn` 的环境，更应该让第一条文本承担“结果汇报”而不是“流程铺陈”。
如果当前会话已经列出 `Bash / Read / Write / Edit`，则应把“工具可用”视为已知事实，而不是待猜测前提。

推荐形态：

- “已补齐 `.feflow/` 最小工作区：新建了 …，保留了 …，当前仍为 `unknown` 的是 …。”
- “我已检查当前目录并完成幂等初始化；已有治理文件未覆盖，只补了缺失项。”

不要这样开场：

- “我先直接把 `.feflow/` 的最小工作区建起来 …”
- “我会开始初始化 …”
- “我先做一轮全量项目研究”
- “初始化分五个阶段，请逐步确认”
- “先确认是否允许我创建每个目录”
- “回复：同意，继续”
- “如果你同意，我再开始初始化”
- “我先说明一下初始化思路，下一条再真正执行”
- “请你再发一次 `/feflow:init`，我就开始真正落盘”
- “使用 superpowers:using-superpowers 和 feflow:project-init ...”
- “当前没有可用文件工具，所以我先给你一份方案”
- “★ Insight …” 后面仍然没有任何创建结果
- “1. 改动概述 / 2. 修改原因 / 3. 影响范围 ...”

暂停预算：

- 理想值：`0`
- 最大可接受：`1`，仅在目标目录存在明显冲突或会覆盖用户已有治理结构时
