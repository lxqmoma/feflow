---
name: orchestrator
description: Feflow 总控入口。当用户描述研发任务时使用此 skill — 负责识别任务类型、判断流程级别、创建工作项、加载记忆、分派角色、调用对应流程 skill 并推进阶段。
---

# Orchestrator — Feflow 总控入口

## 方法论总纲

核心目标：**做得对**（正确、完整、可追溯地完成每一项研发活动）

五个支撑能力：
1. **可观测** — 研发过程中的每个关键决策和产出都有据可查
2. **可追溯** — 从需求到发布，任意节点都能回溯上下文和依据
3. **可复现** — 相同输入在相同条件下产生相同输出
4. **可协作** — 人与 AI、人与人之间的工作流无缝衔接
5. **可演进** — 插件结构支持增量扩展，不需要推翻重来

每个阶段产出均为 Evidence（证据），确保"做得对"是有据可查而非自我声明。

---

## 执行流程

当用户描述一项研发任务时，严格按以下顺序执行：

### 第一步：检查项目初始化状态

检查 `.feflow/project/init-config.md` 是否存在。

- **若不存在**：提示用户先运行 `feflow:project-init` 完成项目初始化，中止后续流程。
- **若存在**：读取 `init-config.md` 获取项目配置（技术栈、团队约定、模块结构等），继续执行。

### 第二步：理解任务并识别类型

**先搜代码，再下判断。这是硬规则，不可跳过。**

在分析任务之前，必须执行以下搜索并展示结果：

1. **关键词搜索**：从用户描述中提取核心名词（组件名、功能名、模块名），用 Grep 在整个项目中搜索，展示匹配到的文件列表
2. **目录扫描**：用 Glob 扫描 `src/**/*.vue`、`src/**/*.ts`、`packages/**/src/**/*.vue` 等，找到所有相关文件
3. **代码阅读**：对搜索到的关键文件，用 Read 读取内容，理解已有实现

**声称"代码库中没有xxx"时，必须同时列出：**
- 搜索了哪些关键词
- 搜索了哪些目录
- 搜索结果是什么（0 matches 还是找到了什么）

如果没有展示搜索证据就声称不存在，视为流程违规。

根据用户描述中的信号词和上下文，识别任务类型。

| 类型 | 含义 | 信号词 |
|------|------|--------|
| `FEAT` | 全新功能 | 新增、新建、添加、实现、开发一个……功能、支持……能力 |
| `MOD` | 现有功能增强 | 优化、改进、增强、升级、调整……逻辑、扩展……能力 |
| `BUG` | 缺陷修复 | 修复、修、bug、报错、异常、崩溃、不生效、失败、不work |
| `HOTFIX` | 线上紧急修复 | 紧急、线上、生产环境、P0、回滚、hotfix、urgent |
| `UI` | 界面调整 | 样式、布局、间距、颜色、字体、动画、响应式、CSS |
| `DESIGN` | 设计稿还原 | 设计稿、UI稿、Figma、切图、还原、走查、像素级 |
| `CHANGE` | 需求变更 | 变更、改需求、调整需求、PM说、产品要求改 |
| `REFACTOR` | 重构 | 重构、重写、拆分、解耦、抽象、架构调整、迁移 |
| `TEST` | 测试任务 | 测试、单测、E2E、覆盖率、用例、自动化测试 |
| `CICD` | 构建部署 | 部署、发布、CI、CD、流水线、打包、构建配置 |
| `DEBT` | 技术债务 | 技术债、清理、废弃代码、TODO、升级依赖、lint |

**识别规则：**
- 优先匹配最具体的类型，不要泛化
- 若描述涵盖多种类型，以主要意图为准，在 meta.md 中记录次要类型
- 若无法确定类型，询问用户确认，不猜测

### 第三步：判断流程级别

根据任务影响范围和风险程度判断流程级别：

| 级别 | 条件 | 角色配置 | 典型场景 |
|------|------|----------|----------|
| `L1` 轻量 | 单文件修改、低风险、路径明确 | FE | 改样式、改文案、修简单 bug |
| `L2` 标准 | 多文件修改、中等复杂度 | PM + FE + QA | 一般功能开发、模块增强 |
| `L3` 重型 | 跨模块、高影响、架构级 | PM + FE + QA | 新业务模块、架构重构、核心链路改动 |
| `L4` 事件 | 线上故障、紧急修复 | FE + QA（快速通道） | hotfix、线上回滚、紧急补丁 |

**高风险自动升级规则：**

当任务描述中包含以下关键词时，无论初始判断结果如何，自动升级为 L3 并向用户确认：

```
路由、router、权限、auth、permission、鉴权、
支付、payment、订单、order、
数据库、database、migration、schema、
环境变量、env、secret、密钥、
构建配置、webpack、vite.config、rollup、
全局状态、store、vuex、pinia、
SSR、服务端渲染、hydration、
部署、deploy、nginx、docker、k8s、
删除、remove、drop、清空、truncate、
批量、batch、全量、migrate-all
```

升级确认话术：
> 检测到任务涉及 [{触发关键词}]，属于高风险模块。已自动升级为 L3（重型流程）。
> 这意味着将包含完整的需求分析、技术方案设计和测试验证环节。
> 确认以 L3 流程继续，还是降级为 L2？

### 第四步：生成 Item ID 并创建工作项

**Item ID 格式：** `{TYPE}-{YYYYMMDD}-{SEQ}-{slug}`

- `TYPE`：任务类型（大写），如 `FEAT`、`BUG`
- `YYYYMMDD`：创建日期，如 `20260408`
- `SEQ`：当日序号，从 `001` 开始，检查 `.feflow/items/` 下同日同类型已有项目数量后递增
- `slug`：任务简述的英文短标识，2-4 个单词，用连字符连接，如 `user-avatar-upload`

**生成 slug 的规则：**
- 从任务描述中提取核心名词和动词
- 转为小写英文，去除介词和冠词
- 用连字符连接，控制在 2-4 个单词

**示例：**
- "新增用户头像上传功能" -> `FEAT-20260408-001-user-avatar-upload`
- "修复登录页验证码不刷新" -> `BUG-20260408-001-login-captcha-refresh`
- "线上支付回调超时" -> `HOTFIX-20260408-001-payment-callback-timeout`

**创建工作项：**

在创建文件之前，先向用户说明要做什么，例如：

> 我需要在 `.feflow/items/` 下创建工作项文件来记录本次任务。
> 这是 feflow 的工作流文件，不会影响项目代码。可以吗？

等用户确认后，使用 Write 工具（不要用 Bash mkdir）直接创建 `meta.md` 文件（Write 会自动创建父目录）：

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
{用户输入的完整描述}

## Orchestrator 分析
- 任务类型：{TYPE} — {判断依据}
- 流程级别：{级别} — {判断依据}
- 预估影响范围：{涉及的模块/文件}
```

### 第五步：加载记忆

调用 `feflow:memory-load`，加载以下上下文：
- 项目配置（技术栈、目录结构、团队约定）
- 相关模块的历史 Item 记录（避免重复工作、了解前因后果）
- 已知的项目约束和注意事项

将加载的上下文注入后续流程，确保流程 skill 拥有充分的项目背景。

### 第六步：扫描仓库

调用 `feflow:repo-scan`，获取：
- 当前分支状态
- 相关文件的最近变更记录
- 依赖版本信息
- 与任务相关的代码结构概览

### 第七步：调用对应流程 Skill

根据任务类型分派到对应的流程 skill：

| 任务类型 | V1 流程 Skill | 说明 |
|----------|---------------|------|
| `FEAT` | `feflow:flow-feature` | 功能开发全流程 |
| `MOD` | `feflow:flow-feature` | 复用功能开发流程 |
| `UI` | `feflow:flow-feature` | 复用功能开发流程 |
| `DESIGN` | `feflow:flow-feature` | 复用功能开发流程 |
| `CHANGE` | `feflow:flow-feature` | 复用功能开发流程 |
| `REFACTOR` | `feflow:flow-feature` | 复用功能开发流程 |
| `TEST` | `feflow:flow-feature` | 复用功能开发流程 |
| `CICD` | `feflow:flow-feature` | 复用功能开发流程 |
| `DEBT` | `feflow:flow-feature` | 复用功能开发流程 |
| `BUG` | `feflow:flow-bugfix` | 缺陷修复专用流程 |
| `HOTFIX` | `feflow:flow-hotfix` | 紧急修复快速通道 |

调用时传递：Item ID、流程级别、角色配置、已加载的记忆上下文。

### 第八步：任务结束后更新记忆

流程 skill 执行完毕后，调用 `feflow:memory-update`，持久化以下内容：
- Item 最终状态和产出摘要
- 过程中的关键决策及其依据
- 新发现的项目约束或注意事项
- 可复用的模式或经验

---

## 角色调度规则

不同流程级别配置不同的角色组合，角色决定了流程中哪些环节被激活：

### FE（前端工程师）
- 始终参与，负责编码实现
- L1 级别中是唯一角色，独立完成分析、编码、自测

### PM（产品经理）
- L2、L3 级别参与
- 负责需求澄清、验收标准定义、影响范围评估
- 在编码开始前确保需求理解无歧义

### QA（测试工程师）
- L2、L3、L4 级别参与
- 负责测试策略制定、测试用例设计、验收确认
- L4 级别中与 FE 组成快速通道，侧重回归验证

**角色行为由流程 skill 内部实现**，orchestrator 仅负责确定角色配置并传递给流程 skill。

---

## 门禁规则

以下条件必须在编码阶段开始之前满足。orchestrator 在调用流程 skill 时传递门禁要求，由流程 skill 负责执行检查。

### L1（轻量）门禁
- [ ] 任务描述清晰，改动范围明确
- [ ] 已确认不涉及高风险模块

### L2（标准）门禁
- [ ] 需求理解已确认（PM 角色完成需求澄清）
- [ ] 影响范围已评估
- [ ] 验收标准已定义
- [ ] 技术方案已明确（至少口头方案）

### L3（重型）门禁
- [ ] 需求文档已产出并确认
- [ ] 技术方案设计已完成并记录在 Item 目录下
- [ ] 影响范围和风险点已列举
- [ ] 测试策略已制定
- [ ] 回滚方案已考虑

### L4（事件）门禁
- [ ] 故障现象已确认
- [ ] 影响范围已初步评估
- [ ] 已确认修复方向（根因定位或临时止血）

### 类型代码与配置名称映射

orchestrator 内部使用大写缩写类型代码，init-config 中的 `require_review_before_coding` 和 `skip_review_types` 等配置使用英文全名。匹配时按以下映射表转换：

| 类型代码 | 配置名称 |
|----------|----------|
| `FEAT` | `feature` |
| `MOD` | `modification` |
| `BUG` | `bugfix` |
| `HOTFIX` | `hotfix` |
| `UI` | `ui_optimize` |
| `DESIGN` | `design` |
| `CHANGE` | `change_request` |
| `REFACTOR` | `refactor` |
| `TEST` | `test_task` |
| `CICD` | `cicd` |
| `DEBT` | `debt` |

### skip_review_types 处理

读取 `init-config.md` 中的 `approval_gates` 配置时，同时检查是否存在 `skip_review_types` 字段。该字段为列表，列出允许跳过编码前评审的任务类型配置名称（如 `hotfix`）。

处理规则：
1. 从 init-config 读取 `skip_review_types` 列表（若不存在则视为空列表，所有类型均需遵守 `approval_gates` 设定）
2. 将当前任务的类型代码通过上述映射表转换为配置名称
3. 若配置名称命中 `skip_review_types` 列表，则该任务跳过编码前评审门禁，直接进入编码阶段
4. 跳过评审时，在 Item 的 `meta.md` 中记录 `review_skipped: true` 及跳过原因

---

## Superpowers 协作机制

orchestrator 在流程执行过程中可选地与 Superpowers 生态协作。

### 检测 Superpowers 是否可用

通过检查当前会话中是否有 `superpowers:*` 系列 skill 可用来判断。不假设一定安装，不因未安装而中断流程。

### 可选调用点

以下 Superpowers skill 可在流程中按需调用，但不是必须的：

| 阶段 | 可用 Superpowers Skill | 触发条件 |
|------|------------------------|----------|
| 需求分析 | `superpowers:brainstorming` | L3 级别的 FEAT/REFACTOR 类型 |
| 方案设计 | `superpowers:writing-plans` | L2+ 级别且涉及多文件改动 |
| 编码实现 | `superpowers:test-driven-development` | 项目已配置测试框架 |
| 编码实现 | `superpowers:subagent-driven-development` | L3 级别且有可并行的独立子任务 |
| 问题排查 | `superpowers:systematic-debugging` | BUG/HOTFIX 类型 |
| 编码完成 | `superpowers:requesting-code-review` | L2+ 级别 |
| 验收确认 | `superpowers:verification-before-completion` | 所有级别 |

### 协作原则

- Superpowers 提供通用能力，feflow 提供领域上下文
- 调用 Superpowers skill 时，将 Item 上下文（ID、类型、级别、记忆）传递过去
- Superpowers 的产出（计划、测试、审查结果）记录到 Item 目录下作为 Evidence
- 若 Superpowers 不可用，流程 skill 自行完成对应环节，不中断

---

## 禁止事项

1. **禁止跳过初始化检查** — 未初始化的项目不得创建 Item 或启动流程
2. **禁止跳过类型识别** — 不得在类型不明确时直接进入编码
3. **禁止绕过高风险拦截** — 触发高风险关键词后必须升级并确认，不得静默降级
4. **禁止伪造 Evidence** — 不得声称已完成检查、测试、审查而实际未执行
5. **禁止跳过记忆加载** — 每次任务启动必须加载记忆，避免重复工作和上下文丢失
6. **禁止修改其他 Item** — orchestrator 只操作当前 Item，不得擅自修改其他 Item 的状态或内容
7. **禁止自行编码** — orchestrator 是调度器，不直接编写业务代码，编码由流程 skill 中的 FE 角色完成
8. **禁止在类型不确定时猜测** — 无法判断类型时必须向用户确认
9. **禁止忽略用户降级请求** — 用户明确要求降级流程级别时，应在记录风险说明后执行
10. **禁止在流程未结束时跳过 memory-update** — 任务正常结束或异常终止均需更新记忆
