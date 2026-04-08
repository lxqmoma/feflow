[English](./README.en.md)

# feflow

前端研发协作引擎 -- AI 编程助手插件，为前端项目提供完整的研发工作流管理。

当前支持 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)。

## 特性亮点

- **全流程覆盖** -- 需求、设计、开发、测试、发布，10 种任务流程开箱即用
- **多角色协作** -- 7 个专业角色（PM/Designer/FE/Backend/QA/Reviewer/Researcher），由编排器按需调度
- **项目记忆** -- 5 层记忆系统（永久/模块/中期/事件/短期），跨会话持久化项目上下文
- **仓库态势感知** -- 4 层扫描，自动识别技术栈、目录结构和关键配置
- **证据驱动** -- 测试结果、审查记录、构建产物作为完成依据，拒绝"自我声明"
- **技术栈自动检测** -- 识别项目技术栈并自动安装对应 skill
- **Legacy 支持** -- 专用 legacy 叠加模式，啃屎山也有章法
- **补录机制** -- 支持事后补充证据和上下文，不强制线性流程

## 快速开始

### 安装

```bash
claude install-plugin https://github.com/lxqmoma/feflow
```

### 初始化

在项目根目录执行：

```bash
/init
```

初始化后会在项目中创建 `.feflow/` 目录，存储工作项、记忆和配置。

### 使用

```bash
# 创建任务并启动工作流
/task 实现用户登录页面

# 查看当前工作项
/task list

# 扫描仓库状态
/scan

# 查看项目记忆
/memory
```

## 核心概念

| 概念 | 说明 |
|------|------|
| **Item** | 研发活动的最小单元，拥有唯一标识、状态、上下文和产出物 |
| **Flow** | Item 的状态流转路径，定义阶段、准入条件和检查点 |
| **Memory** | 项目级持久化上下文，跨会话存储决策、约定和经验 |
| **Evidence** | 验证完成质量的客观依据（测试结果、审查记录等） |
| **Gate** | 阶段准入/准出检查，确保流程质量可控 |
| **Role** | 专业角色 agent，由编排器根据任务类型按需调度 |

## 插件结构

```
feflow/
├── skills/            # 26 个技能定义
│   ├── orchestrator/      # 任务编排与调度
│   ├── flow-feature/      # 需求开发流程
│   ├── flow-bugfix/       # 缺陷修复流程
│   ├── flow-hotfix/       # 紧急修复流程
│   ├── flow-modification/ # 功能修改流程
│   ├── flow-ui-optimize/  # UI 优化流程
│   ├── flow-design/       # 设计任务流程
│   ├── flow-change-request/ # 变更请求流程
│   ├── flow-cicd/         # CI/CD 流程
│   ├── flow-refactor/     # 重构流程
│   ├── flow-test-task/    # 测试任务流程
│   ├── flow-legacy/       # Legacy 叠加模式
│   ├── repo-scan/         # 仓库扫描
│   ├── stack-detect/      # 技术栈检测
│   ├── topology-detect/   # 拓扑检测
│   ├── memory-load/       # 记忆加载
│   ├── memory-update/     # 记忆更新
│   ├── memory-decay/      # 记忆衰减与归档
│   ├── project-init/      # 项目初始化
│   ├── quality-gate/      # 质量门禁
│   ├── evidence-ledger/   # 证据台账
│   ├── evidence-chain/    # 证据链可视化
│   ├── backfill/          # 证据补录
│   ├── item-orchestration/ # 多 Item 依赖编排
│   ├── custom-flow/       # 自定义流程模板
│   └── dashboard/         # 仪表盘
├── agents/            # 7 个角色 agent
│   ├── pm.md              # 产品/需求
│   ├── designer.md        # UI/UX 设计
│   ├── fe.md              # 前端实现
│   ├── backend.md         # 后端协作
│   ├── qa.md              # 测试/QA
│   ├── reviewer.md        # 架构守卫
│   └── researcher.md      # 深度调研
├── commands/          # 4 个命令
│   ├── init.md            # /init -- 初始化工作区
│   ├── task.md            # /task -- 创建/查看工作项
│   ├── scan.md            # /scan -- 扫描仓库
│   └── memory.md          # /memory -- 管理记忆
├── templates/         # 12 个文档模板
├── hooks/             # 生命周期钩子
├── package.json
├── CLAUDE.md
└── LICENSE
```

## 命令列表

| 命令 | 说明 | 用法 |
|------|------|------|
| `/init` | 初始化 feflow 工作区 | `/init` |
| `/task` | 创建工作项或查看列表 | `/task 实现登录页面` 或 `/task list` |
| `/scan` | 扫描仓库状态 | `/scan` |
| `/memory` | 查看/管理项目记忆 | `/memory` 或 `/memory add` |

## 流程类型

| 流程 | 适用场景 | Skill |
|------|----------|-------|
| Feature | 新功能开发 | `flow-feature` |
| Modification | 现有功能修改 | `flow-modification` |
| Bugfix | 缺陷修复 | `flow-bugfix` |
| Hotfix | 紧急线上修复 | `flow-hotfix` |
| UI Optimize | UI/交互优化 | `flow-ui-optimize` |
| Design | 设计相关任务 | `flow-design` |
| Change Request | 变更请求 | `flow-change-request` |
| CI/CD | 构建部署任务 | `flow-cicd` |
| Refactor | 代码重构 | `flow-refactor` |
| Test Task | 测试任务 | `flow-test-task` |
| Legacy (叠加) | 遗留代码改造，可叠加到任意流程 | `flow-legacy` |

## 角色一览

| 角色 | 职责 | 调度时机 |
|------|------|----------|
| **PM** | 需求理解、文档整理、歧义发现、验收标准 | 需求分析阶段 |
| **Designer** | UI 视觉设计、UX 交互设计 | UI/DESIGN 类任务、L3 任务 |
| **FE** | 技术方案、代码改动计划、模块影响分析、编码实施 | 开发阶段 |
| **Backend** | API 对接、接口协议、数据结构调整 | 前后端协同任务 |
| **QA** | 测试范围、回归清单、边界场景、多端验证 | 测试阶段 |
| **Reviewer** | 架构守卫、不变量检查、防止历史错误复现 | 代码审查、L3 任务 |
| **Researcher** | 深度阅读代码、参考资料、竞品分析、历史提交 | 按需启用 |

## 与 Superpowers 的关系

feflow 是 [Superpowers](https://github.com/jasonm/superpowers) 生态中的领域插件，两者各司其职：

| 维度 | Superpowers | feflow |
|------|-------------|--------|
| 定位 | 通用开发工作流 | 研发协作领域引擎 |
| 能力 | brainstorming、planning、TDD、code-review | Item/Flow/Memory/Evidence 管理 |
| 使用场景 | 通用开发任务 | 需求管理、版本规划、发布协调 |

协作方式：feflow 的 hooks 在 Superpowers 工作流的关键节点注入领域逻辑。两者的 skills 和 agents 可互相调用。

## 方法论

**总纲：做得对** -- 正确、完整、可追溯地完成每一项研发活动。

六条设计口号：

1. **放得活** -- 流程分级（L1/L2/L3），不一刀切
2. **管得住** -- 可追踪、可核对、可恢复
3. **记得住** -- 项目记忆外部化，跨会话持久
4. **接得稳** -- AI 产出人类能接手
5. **啃得动** -- 支持 legacy 和屎山
6. **查得到** -- 证据驱动，有据可查

## 路线图

### V3 计划

- [x] 多 Item 依赖与并行编排
- [x] 记忆自动衰减与归档策略
- [x] 流程模板自定义（用户自定义 Flow）
- [x] 仪表盘：Item 状态全景视图
- [x] 证据链可视化

### 多平台支持

- [x] Cursor 适配
- [x] Windsurf 适配
- [x] 其他 AI 编程助手适配（通用 AGENTS.md）

## 贡献指南

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feat/your-feature`
3. 提交改动：`git commit -m "feat: 你的改动描述"`
4. 推送分支：`git push origin feat/your-feature`
5. 提交 Pull Request

Commit 格式：`类型(范围): 描述`，类型包括 feat / fix / refactor / docs / test / chore。

## License

[MIT](./LICENSE)
