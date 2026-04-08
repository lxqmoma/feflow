---
name: project-init
description: 首次在项目中启用 feflow 时使用。执行全量项目研究（架构、技术栈、业务、CI/CD、测试、风险、UI 体系），进行校准问答，生成项目配置，并主动安装匹配的技术栈 skills。
---

# project-init：项目初始化

## 触发条件

- 用户执行 `/init` 或明确要求初始化 feflow
- 会话启动检测到 `status: uninitialized`（`.feflow/` 目录不存在）
- 会话启动检测到 `status: partial`（`.feflow/` 存在但缺少 `init-config.md`）

## 前置检查

1. 确认当前目录是 Git 仓库（`git rev-parse --git-dir`），否则终止并提示
2. 确认 `.feflow/` 目录不存在（如已存在，提示用户选择：跳过 / 覆盖 / 补全缺失部分）
3. 确认 `package.json` 存在（如不存在，提示这不是一个 Node.js 项目，询问是否继续）

## 执行流程

### 阶段一：自动扫描

不需要用户输入，完全由机器完成。按以下顺序执行全量项目研究：

#### 1.1 技术栈识别

读取 `package.json` 提取关键信息：

```bash
# 读取 package.json
cat package.json | jq '{
  name: .name,
  version: .version,
  private: .private,
  packageManager: .packageManager,
  engines: .engines,
  scripts: (.scripts | keys),
  dependencies: (.dependencies // {} | keys),
  devDependencies: (.devDependencies // {} | keys)
}'
```

从 dependencies/devDependencies 中识别：
- 框架：vue / react / nuxt / next / svelte / astro
- 构建工具：vite / webpack / rollup / esbuild / turbopack
- 测试框架：vitest / jest / mocha / cypress / playwright
- CSS 方案：tailwind / unocss / sass / less / styled-components
- 状态管理：pinia / vuex / redux / zustand / jotai
- 路由：vue-router / react-router
- 包管理器：通过 `packageManager` 字段或 lock 文件判断（pnpm-lock.yaml / yarn.lock / package-lock.json）
- Monorepo 工具：turborepo / nx / lerna

#### 1.2 目录结构分析

```bash
# 获取两层目录结构，排除 node_modules 和常见无关目录
find . -maxdepth 3 -type d \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  -not -path '*/.nuxt/*' \
  -not -path '*/.next/*' \
  -not -path '*/.output/*' \
  | head -80

# 统计文件类型分布
find . -type f \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/dist/*' \
  | sed 's/.*\.//' | sort | uniq -c | sort -rn | head -20
```

识别项目架构模式：
- 单体应用 vs Monorepo（检查 `workspaces` / `pnpm-workspace.yaml` / `turbo.json`）
- SSR / SSG / SPA / 混合渲染
- 前后端分离 vs 全栈
- 组件库 vs 应用项目 vs 工具库

#### 1.3 Git 信息采集

```bash
# 远程仓库信息
git remote -v

# 分支结构
git branch -a --sort=-committerdate | head -20

# 最近 tag（判断版本策略）
git tag --sort=-version:refname | head -10

# 提交统计（最近 30 天）
git shortlog -sn --since="30 days ago"

# .gitignore 检查
cat .gitignore 2>/dev/null | grep -v '^#' | grep -v '^$' | head -20
```

#### 1.4 UI 体系识别

检查以下配置文件和依赖：
- `uno.config.ts` / `unocss.config.ts` → UnoCSS
- `tailwind.config.*` → Tailwind CSS
- `ant-design-vue` / `element-plus` / `naive-ui` / `vuetify` → Vue 组件库
- `@arco-design` / `tdesign-vue-next` → 其他 Vue 组件库
- 自定义设计系统：检查 `components/ui/` / `design-system/` / `tokens/` 目录
- 主题配置：检查 `theme/` 目录或 CSS 变量定义文件

#### 1.5 测试现状检查

```bash
# 测试文件分布
find . -type f \( -name '*.test.*' -o -name '*.spec.*' -o -name '__tests__' \) \
  -not -path '*/node_modules/*' | head -30

# 测试覆盖率配置
cat vitest.config.* 2>/dev/null || cat jest.config.* 2>/dev/null || echo "无测试配置文件"

# 测试脚本
cat package.json | jq '.scripts | to_entries[] | select(.key | test("test|coverage|e2e"))'
```

#### 1.6 CI/CD 检查

检查以下路径：
- `.github/workflows/` → GitHub Actions
- `.gitlab-ci.yml` → GitLab CI
- `Jenkinsfile` → Jenkins
- `.circleci/` → CircleCI
- `Dockerfile` / `docker-compose.yml` → 容器化部署
- `vercel.json` / `netlify.toml` → 平台部署

#### 1.7 风险预扫描

- 检查 `TODO` / `FIXME` / `HACK` / `XXX` 注释数量和分布
- 检查依赖的 deprecated 警告（`npm ls 2>&1 | grep -i deprecated | head -10`）
- 检查 `.env` / `.env.*` 文件是否被 gitignore
- 检查 TypeScript 严格模式配置（`tsconfig.json` 中的 `strict`）

### 阶段二：校准问答

自动扫描完成后，向用户提出 6-7 个机器无法自动判断的关键问题。以交互式问答方式逐个确认。

**必问清单：**

1. **怎么发布上线**
   > 你们的发布流程是怎样的？（举例：打 tag 触发 CI 发布 / 合并到 release 分支 / 手动触发 / 其他）

2. **日常怎么开分支**
   > 日常开发用什么分支流程？（举例：feature → develop → release → main / feature → main / 只用 main 一条线 / 其他）

3. **提交关联任务编号**
   > 分支和提交信息里要不要自动带任务编号？（方便事后追踪哪个提交属于哪个任务）
   > 举例：JIRA-1234 / #123 / 不需要 / 其他格式

4. **哪些地方改起来要特别小心**
   > 项目里有没有「碰了容易出事」的模块或目录？（举例：支付模块、权限系统、数据库迁移、没有特别的）

5. **AI 不能碰的地方**
   > 有没有哪些文件或目录不希望 AI 直接改？（举例：安全相关配置、生产环境脚本、第三方 SDK 封装、没有特殊限制）

6. **方案确认节奏**
   > AI 什么时候需要先给你看方案才能动手写代码？
   > A) 除了改文案、调样式之类的小活，其他都要先看方案
   > B) 普通功能也可以直接干，只有高风险的才需要
   > C) 都不用，直接干就行

7. **合并前审批**（如检测到 CI/CD 配置则追加）
   > 代码合并到主分支之前，需要满足什么条件？（举例：至少 1 人 review / CI 全绿 / 无要求）

**问答规则：**
- 每个问题附带从扫描结果推断的默认值（如有）
- 用户回答「默认」或直接回车时采用推断值
- 用户可以一次性回答多个问题
- 记录原始回答，不做过度解读

### 阶段三：生成项目配置

#### 3.1 创建 .feflow/ 目录结构

```bash
mkdir -p .feflow/project
mkdir -p .feflow/items
mkdir -p .feflow/memory/project
mkdir -p .feflow/memory/modules
mkdir -p .feflow/memory/incidents
mkdir -p .feflow/memory/patterns
mkdir -p .feflow/templates
```

目录用途：
- `project/` — 项目级研究报告（架构、技术栈、风险等）
- `items/` — 工作项文件（每个 Item 一个 .md）
- `memory/project/` — 项目级记忆（不变量、编码戒律等）
- `memory/modules/` — 模块级记忆（按目录/模块存储上下文）
- `memory/incidents/` — 事故记录（生产问题、重大 bug 的经验教训）
- `memory/patterns/` — 模式记录（反复出现的解决方案模式）
- `templates/` — 模板文件（Item 模板、报告模板等）

#### 3.2 生成 init-config.md

```markdown
---
workspace_shape: "<monorepo|single-app|library|fullstack>"
release_detection: "<tag-trigger|branch-merge|manual|ci-pipeline>"
branch_strategy: "<gitflow|github-flow|trunk-based|custom>"
workflow_binding: "<required|optional|none>"
item_id_format: "<JIRA-\\d+|#\\d+|none|custom>"
backfill: "<enabled|disabled>"
testing_policy: "<strict|moderate|minimal|none>"
approval_gates: "<review-required|ci-green|both|none>"
high_risk_modules:
  - "<路径1>"
  - "<路径2>"
ai_restrictions:
  - "<路径1>"
  - "<路径2>"
initialized_at: "<ISO 8601 时间戳>"
initialized_by: "feflow:project-init"
---

# feflow 项目配置

本文件由 `feflow:project-init` 自动生成，记录项目级配置参数。
这些参数影响 feflow 所有 skills 和 agents 的行为。

## 配置说明

| 参数 | 值 | 说明 |
|------|-----|------|
| workspace_shape | ... | 项目结构类型 |
| release_detection | ... | 发布检测方式 |
| branch_strategy | ... | 分支策略 |
| workflow_binding | ... | 工作项绑定要求 |
| item_id_format | ... | 工作项 ID 格式 |
| backfill | ... | 是否允许事后补录 |
| testing_policy | ... | 测试策略严格程度 |
| approval_gates | ... | 合并审批门禁 |
```

frontmatter 中的值全部从阶段一扫描结果 + 阶段二问答回答中填充，不留占位符。

#### 3.3 生成项目研究报告

在 `.feflow/project/` 下生成以下文件：

**project-profile.md** — 项目概况
- 项目名称、版本、描述
- 仓库地址
- 团队规模推断（基于 git shortlog）
- 项目活跃度（最近 30 天提交频次）

**architecture-report.md** — 架构分析
- 项目类型（SPA / SSR / SSG / 混合）
- 目录结构说明（每个顶层目录的职责）
- 关键配置文件清单
- 模块间依赖关系推断

**stack-detection.md** — 技术栈检测结果
- 框架及版本
- 构建工具及版本
- 运行时要求
- 关键依赖清单（按类别分组）

**ui-design-system.md** — UI 体系报告
- CSS 方案
- 组件库
- 主题配置方式
- 设计令牌（如检测到）

**testing-report.md** — 测试现状报告
- 测试框架
- 测试文件数量和分布
- 覆盖率配置（如有）
- 测试脚本清单

**risk-report.md** — 风险预评估
- TODO/FIXME 分布热点
- 依赖风险（deprecated / 安全漏洞）
- 配置风险（env 文件暴露、strict mode 关闭等）
- 高风险模块（用户指定 + 扫描推断）

每个报告文件都包含 frontmatter：

```yaml
---
generated_by: "feflow:project-init"
generated_at: "<ISO 8601>"
version: 1
---
```

### 阶段四：安装技术栈 Skills

调用 `feflow:stack-detect` skill，基于阶段一的技术栈识别结果，自动安装匹配的 Claude Code skills。

```
调用 feflow:stack-detect
输入：阶段一识别的技术栈清单
输出：已安装 skills 列表
```

### 阶段五：初始化基础记忆文件

#### 5.1 invariants.md（不变量清单 — 空模板）

在 `.feflow/memory/project/invariants.md` 创建：

```markdown
---
type: invariants
updated_at: "<ISO 8601>"
updated_by: "feflow:project-init"
---

# 项目不变量

> 不变量是项目中绝对不可违反的规则。一旦记录，所有后续操作必须遵守。
> 违反不变量的修改必须被阻止或标记为高风险。

## 架构不变量

<!-- 示例：
- 所有 API 请求必须通过 `src/utils/request.ts` 统一封装
- 路由定义必须在 `src/router/` 目录下，不允许分散定义
-->

## 数据不变量

<!-- 示例：
- 用户敏感数据（手机号、身份证）必须脱敏后才能写入日志
- 金额字段统一使用分为单位，前端展示时再转换
-->

## 流程不变量

<!-- 示例：
- 合并到 main 分支必须通过 PR，不允许直接 push
- 数据库迁移脚本一旦合并到 main 不允许修改，只能追加新迁移
-->
```

#### 5.2 coding-doctrine.md（AI 编码戒律）

在 `.feflow/memory/project/coding-doctrine.md` 创建：

```markdown
---
type: coding-doctrine
updated_at: "<ISO 8601>"
updated_by: "feflow:project-init"
---

# AI 编码戒律

> 以下规则是 AI 在本项目中编写代码时必须遵守的戒律。
> 这些规则不可被单次对话中的临时指令覆盖，除非用户明确声明「临时豁免第 N 条」。

## 七条戒律

### 1. 不擅自扩大修改范围
只改任务要求的部分。不借题发挥，不顺手重构，不主动「优化」不相关代码。
改动的每一行都必须能回答：「这一行改动对应的是哪个需求或问题？」

### 2. 不伪造验证结果
不编造测试通过、构建成功、类型检查通过等结论。
如果没有实际运行过验证命令，必须明确说明「未经验证」。
声称「已确认无问题」之前，必须有对应的命令输出作为证据。

### 3. 不引入未经确认的依赖
安装新的 npm 包之前必须说明理由并等待确认。
优先使用项目中已有的工具和库。
引入依赖时必须检查其维护状态、体积和安全性。

### 4. 不破坏现有接口契约
不改变已有函数的参数签名、返回类型、字段命名。
不改变已有组件的 props/emits/slots 定义。
不改变已有 API 的请求/响应结构。
如果确实需要改变，必须先说明影响范围和迁移方案。

### 5. 不忽略错误处理
所有异步操作必须有错误处理。
所有用户输入必须有校验。
所有外部接口调用必须考虑超时和异常情况。
不允许空的 catch 块或静默吞掉错误。

### 6. 不硬编码环境相关值
不在代码中硬编码 URL、密钥、端口号、文件路径等环境相关值。
这些值必须通过环境变量、配置文件或运行时注入。
不将 `.env` 文件提交到版本控制。

### 7. 不跳过类型安全
TypeScript 项目中不使用 `any` 类型（除非有充分理由并添加注释说明）。
不使用 `@ts-ignore` / `@ts-expect-error` 绕过类型检查（除非确认是第三方类型定义问题）。
所有公开接口必须有明确的类型定义。
```

## 输出总结

初始化完成后，输出以下总结：

```
## feflow 初始化完成

### 项目概况
- 项目：{name} v{version}
- 类型：{workspace_shape}
- 框架：{主要框架}
- 构建：{构建工具}

### 已生成文件
- .feflow/init-config.md — 项目配置
- .feflow/project/project-profile.md — 项目概况
- .feflow/project/architecture-report.md — 架构分析
- .feflow/project/stack-detection.md — 技术栈检测
- .feflow/project/ui-design-system.md — UI 体系
- .feflow/project/testing-report.md — 测试现状
- .feflow/project/risk-report.md — 风险预评估
- .feflow/memory/project/invariants.md — 不变量清单（空模板）
- .feflow/memory/project/coding-doctrine.md — AI 编码戒律

### 已安装 Skills
- {skill-1}
- {skill-2}
- ...

### 配置摘要
| 参数 | 值 |
|------|-----|
| 发布方式 | {release_detection} |
| 分支策略 | {branch_strategy} |
| 工作项绑定 | {workflow_binding} |
| 测试策略 | {testing_policy} |
| 审批门禁 | {approval_gates} |

### 后续步骤
1. 检查 `.feflow/init-config.md` 中的配置是否准确
2. 在 `.feflow/memory/project/invariants.md` 中补充项目不变量
3. 运行 `feflow:repo-scan` 获取当前仓库态势
4. 开始使用 `feflow:flow-feature` 创建第一个工作项
```

## 错误处理

- `package.json` 不存在：提示非 Node.js 项目，询问是否继续（跳过技术栈识别）
- 不在 Git 仓库中：终止初始化，提示先执行 `git init`
- `.feflow/` 已存在且配置完整：提示已初始化，建议使用 `feflow:repo-scan` 而非重新初始化
- `feflow:stack-detect` 调用失败：记录错误，继续完成其余初始化步骤
- 用户中断校准问答：保存已收集的回答，使用默认值填充未回答问题，标记为 `backfill: enabled`
