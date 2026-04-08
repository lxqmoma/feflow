---
name: orchestrator
description: Feflow 总控入口。识别任务类型、判断流程级别、创建工作项、加载记忆、分派角色、调用流程 skill。
---

# Orchestrator — Feflow 总控入口

> 方法论总纲见 `CLAUDE.md`，此处不重复。

---

## 执行流程

当用户描述研发任务时，严格按以下顺序执行：

### 第一步：检查项目初始化状态

检查 `.feflow/project/init-config.md` 是否存在。不存在则提示用户运行 `feflow:project-init`，中止流程；存在则读取项目配置后继续。

### 第二步：理解任务并识别类型

**硬规则：先搜代码，再下判断，不可跳过。**

1. 用 Grep 搜索用户描述中的核心名词（组件名、功能名、模块名），展示匹配文件
2. 用 Glob 扫描相关目录（`src/**/*.vue`、`src/**/*.ts` 等）
3. 用 Read 读取关键文件，理解已有实现

声称"代码库中没有xxx"时，必须列出搜索关键词、目录和结果。无搜索证据即声称不存在，视为流程违规。

根据信号词识别任务类型：

| 类型 | 含义 | 信号词 |
|------|------|--------|
| `FEAT` | 全新功能 | 新增、添加、实现、开发……功能 |
| `MOD` | 功能增强 | 优化、改进、增强、调整逻辑 |
| `BUG` | 缺陷修复 | 修复、bug、报错、异常、崩溃 |
| `HOTFIX` | 线上紧急修复 | 紧急、线上、P0、hotfix |
| `UI` | 界面调整 | 样式、布局、间距、颜色、动画 |
| `DESIGN` | 设计稿还原 | 设计稿、Figma、还原、走查 |
| `CHANGE` | 需求变更 | 变更、改需求、产品要求改 |
| `REFACTOR` | 重构 | 重构、拆分、解耦、架构调整 |
| `TEST` | 测试任务 | 测试、单测、E2E、覆盖率 |
| `CICD` | 构建部署 | 部署、发布、CI/CD、流水线 |
| `DEBT` | 技术债务 | 技术债、清理、废弃代码、lint |

识别规则：优先匹配最具体类型；多类型时以主要意图为准，次要类型记录在 meta.md；无法确定时询问用户，不猜测。

### 第三步：判断流程级别

| 级别 | 条件 | 角色 | 典型场景 |
|------|------|------|----------|
| `L1` 轻量 | 单文件、低风险 | FE | 改样式、改文案、简单 bug |
| `L2` 标准 | 多文件、中等复杂度 | PM+FE+QA | 功能开发、模块增强 |
| `L3` 重型 | 跨模块、架构级 | PM+FE+QA | 新模块、重构、核心链路 |
| `L4` 事件 | 线上故障 | FE+QA | hotfix、回滚、紧急补丁 |

**高风险自动升级：** 任务描述包含以下关键词时，自动升级为 L3 并向用户确认：

路由/router、权限/auth、支付/payment、订单/order、数据库/migration/schema、环境变量/env/secret、构建配置/webpack/vite.config、全局状态/store/pinia、SSR/hydration、部署/deploy/docker/k8s、删除/drop/truncate、批量/batch/migrate-all

> 检测到任务涉及 [{触发关键词}]，属于高风险模块。已自动升级为 L3。确认继续，还是降级为 L2？

### 第四步：生成 Item ID 并创建工作项

**Item ID 格式：** `{TYPE}-{YYYYMMDD}-{SEQ}-{slug}`

- `TYPE`：大写任务类型  |  `YYYYMMDD`：创建日期  |  `SEQ`：当日序号（从 `001` 递增）  |  `slug`：2-4 个小写英文单词，连字符连接

示例：`FEAT-20260408-001-user-avatar-upload`、`BUG-20260408-001-login-captcha-refresh`

**创建工作项：** 先向用户确认将在 `.feflow/items/` 下创建工作项文件，确认后用 Write 创建 `meta.md`：

```markdown
---
id: {item-id}
type: {TYPE}
level: {L1|L2|L3|L4}
status: CREATED
created: {YYYY-MM-DD HH:mm}
roles: [{角色列表}]
secondary_types: [{次要类型，若有}]
---
# {任务标题}
## 用户原始描述
{完整描述}
## Orchestrator 分析
- 任务类型：{TYPE} — {判断依据}
- 流程级别：{级别} — {判断依据}
- 预估影响范围：{涉及的模块/文件}
```

### 第五步：加载记忆

调用 `feflow:memory-load`，加载项目配置、相关模块历史 Item、已知约束，注入后续流程。

### 第六步：扫描仓库

调用 `feflow:repo-scan`，获取分支状态、相关文件变更记录、依赖版本、代码结构概览。

### 第七步：调用对应流程 Skill

| 流程 Skill | 适用类型 |
|------------|----------|
| `feflow:flow-feature` | `FEAT`、`DEBT` |
| `feflow:flow-modification` | `MOD` |
| `feflow:flow-refactor` | `REFACTOR` |
| `feflow:flow-test-task` | `TEST` |
| `feflow:flow-ui-optimize` | `UI` |
| `feflow:flow-design` | `DESIGN` |
| `feflow:flow-change-request` | `CHANGE` |
| `feflow:flow-cicd` | `CICD` |
| `feflow:flow-bugfix` | `BUG` |
| `feflow:flow-hotfix` | `HOTFIX` |

涉及 legacy/高耦合区域的任务，在正常流程前叠加 `feflow:flow-legacy` 模式。

调用时传递：Item ID、流程级别、角色配置、已加载的记忆上下文。

### 第八步：任务结束后更新记忆

调用 `feflow:memory-update`，持久化 Item 最终状态、关键决策依据、新发现的约束、可复用模式。

---

## 角色调度规则

| 角色 | 参与条件 | 职责 |
|------|----------|------|
| FE | 全部任务 | 技术方案、编码实施；L1 独立完成全流程 |
| PM | L2、L3 | 需求澄清、验收标准、影响评估 |
| Designer | UI/DESIGN 类型任务，或 L3 任务 | 视觉/交互方案、设计系统一致性、状态完整性 |
| Backend | 涉及 API/接口/数据结构变更的任务 | 接口评审、数据结构对齐、联调方案 |
| QA | L2、L3、L4 | 测试策略、用例设计、验收确认 |
| Reviewer | L3，或代码审查阶段 | 不变量检查、历史错误防重犯、技术债评估 |
| Researcher | 按需（任务涉及陌生模块/技术） | 深度代码阅读、历史 commit 分析、技术调研 |

角色行为由流程 skill 内部实现，orchestrator 仅确定角色配置并传递。

---

## 门禁规则

编码开始前必须满足对应级别门禁，由流程 skill 执行检查。

- **L1：** 任务描述清晰、改动范围明确、不涉及高风险模块
- **L2：** 需求已确认、影响范围已评估、验收标准已定义、技术方案已明确
- **L3：** 需求文档已产出、技术方案已记录、风险点已列举、测试策略已制定、回滚方案已考虑
- **L4：** 故障现象已确认、影响范围已评估、修复方向已确认

### 类型代码与配置名称映射

类型代码与 init-config 中配置名称的对应关系：

`FEAT`→`feature`、`MOD`→`modification`、`BUG`→`bugfix`、`HOTFIX`→`hotfix`、`UI`→`ui_optimize`、`DESIGN`→`design`、`CHANGE`→`change_request`、`REFACTOR`→`refactor`、`TEST`→`test_task`、`CICD`→`cicd`、`DEBT`→`debt`

### skip_review_types 处理

从 init-config 读取 `skip_review_types` 列表（不存在则视为空）。将当前类型代码转换为配置名称后，若命中该列表则跳过编码前评审，并在 meta.md 中记录 `review_skipped: true` 及原因。

---

## Superpowers 协作

通过检查 `superpowers:*` skill 是否可用来判断。不假设一定安装，不因未安装而中断流程。

可选调用点（非必须）：

| 阶段 | Skill | 触发条件 |
|------|-------|----------|
| 需求分析 | `brainstorming` | L3 的 FEAT/REFACTOR |
| 方案设计 | `writing-plans` | L2+ 多文件改动 |
| 编码实现 | `test-driven-development` | 已配置测试框架 |
| 编码实现 | `subagent-driven-development` | L3 有可并行子任务 |
| 问题排查 | `systematic-debugging` | BUG/HOTFIX |
| 编码完成 | `requesting-code-review` | L2+ |
| 验收确认 | `verification-before-completion` | 所有级别 |

调用时传递 Item 上下文，产出记录到 Item 目录作为 Evidence。Superpowers 不可用时流程 skill 自行完成。

---

## 禁止事项

1. **禁止跳过初始化检查** — 未初始化不得创建 Item
2. **禁止绕过高风险拦截** — 触发关键词后必须升级确认，不得静默降级
3. **禁止伪造 Evidence** — 不得声称已完成而实际未执行
4. **禁止修改其他 Item** — 只操作当前 Item
5. **禁止自行编码** — orchestrator 是调度器，编码由流程 skill 的 FE 角色完成
6. **禁止跳过 memory-update** — 正常结束或异常终止均需更新记忆
