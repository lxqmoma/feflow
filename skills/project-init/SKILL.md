---
name: project-init
description: 首次在项目中启用 feflow 时使用。执行全量项目研究（架构、技术栈、业务、CI/CD、测试、风险、UI 体系），进行校准问答，生成项目配置，并主动安装匹配的技术栈 skills。
---

# project-init：项目初始化

## 触发条件

- 用户执行 `/init` 或明确要求初始化 feflow
- 会话启动检测到 `status: uninitialized`（`.feflow/` 目录不存在）
- 会话启动检测到 `status: partial`（`.feflow/` 存在但缺少 `project/init-config.md`）

## 前置检查

1. 确认当前目录是 Git 仓库（`git rev-parse --git-dir`），否则终止并提示
2. 确认 `.feflow/` 目录不存在（如已存在，提示用户选择：跳过 / 覆盖 / 补全缺失部分）
3. 确认 `package.json` 存在（如不存在，提示这不是一个 Node.js 项目，询问是否继续）

## 执行流程

### 阶段一：自动扫描

不需要用户输入，完全由机器完成。

#### 1.1 技术栈识别

读取 `package.json` 提取 name、version、scripts、dependencies、devDependencies 等关键信息。

从依赖中识别：
- 框架：vue / react / nuxt / next / svelte / astro
- 构建工具：vite / webpack / rollup / esbuild / turbopack
- 测试框架：vitest / jest / mocha / cypress / playwright
- CSS 方案：tailwind / unocss / sass / less / styled-components
- 状态管理：pinia / vuex / redux / zustand / jotai
- 路由：vue-router / react-router
- 包管理器：通过 `packageManager` 字段或 lock 文件判断
- Monorepo 工具：turborepo / nx / lerna

#### 1.2 目录结构分析

获取三层目录结构（排除 node_modules/.git/dist 等），统计文件类型分布。

调用 `feflow:topology-detect` 识别仓库拓扑。

识别项目架构模式：
- 单体应用 vs Monorepo（检查 `workspaces` / `pnpm-workspace.yaml` / `turbo.json`）
- SSR / SSG / SPA / 混合渲染
- 前后端分离 vs 全栈
- 组件库 vs 应用项目 vs 工具库

#### 1.3 Git 信息采集

采集远程仓库、分支结构、最近 tag、提交统计（近 30 天）、.gitignore 配置。

#### 1.4 UI 体系识别

检查配置文件和依赖：UnoCSS / Tailwind / 组件库（ant-design-vue / element-plus / naive-ui 等）、自定义设计系统（`components/ui/` / `design-system/` / `tokens/`）、主题配置。

#### 1.5 测试现状检查

扫描测试文件分布、测试覆盖率配置、测试脚本。

#### 1.6 CI/CD 检查

检查：`.github/workflows/` / `.gitlab-ci.yml` / `Jenkinsfile` / `.circleci/` / `Dockerfile` / `vercel.json` / `netlify.toml`。

#### 1.7 风险预扫描

- TODO / FIXME / HACK / XXX 注释数量和分布
- 依赖 deprecated 警告
- `.env` 文件是否被 gitignore
- TypeScript 严格模式配置

### 阶段二：校准问答

自动扫描完成后，向用户提出 6-7 个机器无法自动判断的关键问题。以交互式问答方式逐个确认。

**必问清单：**

1. **怎么发布上线** — 打 tag 触发 CI / 合并到 release 分支 / 手动触发 / 其他
2. **日常怎么开分支** — feature → develop → release → main / feature → main / trunk-based / 其他
3. **提交关联任务编号** — JIRA-1234 / #123 / 不需要 / 其他格式
4. **哪些地方改起来要特别小心** — 支付模块、权限系统、数据库迁移等
5. **AI 不能碰的地方** — 安全配置、生产脚本、第三方 SDK 封装等
6. **方案确认节奏** — A) 除小活外都要先看方案 B) 只有高风险才需要 C) 都不用
7. **合并前审批**（检测到 CI/CD 时追加）— 至少 1 人 review / CI 全绿 / 无要求

**问答规则：**
- 每个问题附带从扫描结果推断的默认值（如有）
- 用户回答「默认」或直接回车时采用推断值
- 用户可以一次性回答多个问题
- 记录原始回答，不做过度解读

### 阶段三：生成项目配置

#### 3.1 创建 .feflow/ 目录结构

```bash
mkdir -p .feflow/{project,items,memory/{project,modules,incidents,patterns},templates}
```

目录用途：`project/` 项目级研究报告 | `items/` 工作项文件 | `memory/` 分层记忆 | `templates/` 模板文件

#### 3.2 生成 init-config.md

frontmatter 包含以下配置字段，全部从扫描结果 + 问答回答中填充，不留占位符：

`workspace_shape` / `release_detection` / `branch_strategy` / `workflow_binding` / `item_id_format` / `backfill` / `testing_policy` / `approval_gates` / `high_risk_modules` / `ai_restrictions` / `skip_review_types: [hotfix]` / `initialized_at` / `initialized_by`

#### 3.3 生成项目研究报告

在 `.feflow/project/` 下生成以下文件（每个文件包含 `generated_by` / `generated_at` / `version` frontmatter）：

| 文件 | 内容 |
|------|------|
| project-profile.md | 项目名称、版本、仓库地址、团队规模、活跃度 |
| architecture-report.md | 项目类型、目录职责、关键配置、模块依赖 |
| stack-detection.md | 框架版本、构建工具、运行时要求、关键依赖 |
| ui-design-system.md | CSS 方案、组件库、主题配置、设计令牌 |
| testing-report.md | 测试框架、文件分布、覆盖率配置、测试脚本 |
| risk-report.md | TODO/FIXME 热点、依赖风险、配置风险、高风险模块 |

### 阶段四：安装技术栈 Skills

调用 `feflow:stack-detect` skill，基于阶段一的技术栈识别结果，自动安装匹配的 Claude Code skills。

### 阶段五：初始化基础记忆文件

在 `.feflow/memory/project/` 下创建：

- **invariants.md** — 项目不变量（空模板），含架构不变量、数据不变量、流程不变量三个分区
- **coding-doctrine.md** — AI 编码戒律，内容从 `templates/` 加载（详见模板文件）

## 输出总结

初始化完成后输出：项目概况（名称/类型/框架/构建）、已生成文件清单、已安装 Skills、配置摘要表、后续步骤。

## 错误处理

| 场景 | 处理 |
|------|------|
| `package.json` 不存在 | 提示非 Node.js 项目，询问是否继续 |
| 不在 Git 仓库中 | 终止，提示先 `git init` |
| `.feflow/` 已存在且完整 | 提示已初始化，建议用 `repo-scan` |
| `stack-detect` 调用失败 | 记录错误，继续完成其余步骤 |
| 用户中断校准问答 | 保存已收集回答，默认值填充未回答问题，标记 `backfill: enabled` |
