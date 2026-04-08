# feflow — 前端研发协作引擎

## 方法论总纲

核心目标：**做得对**（正确、完整、可追溯地完成每一项研发活动）

五个支撑能力：
1. **放得活** — 流程分级，不一刀切
2. **管得住** — 可追踪、可核对、可恢复
3. **记得住** — 项目记忆外部化
4. **接得稳** — AI 产出人类能接手
5. **啃得动** — 支持 legacy 和屎山

## 插件结构

```
feflow/
├── skills/          # 技能定义（Claude 可调用的领域能力）
├── agents/          # 智能体配置（组合 skills 完成复杂任务）
├── hooks/           # 生命周期钩子（SessionStart/PreCommit 等）
├── commands/        # 自定义命令（/feflow-xxx 形式）
├── templates/       # 模板文件（生成 Item 的初始结构）
├── hooks.json       # 钩子注册清单
├── package.json     # 插件元信息
└── CLAUDE.md        # 本文件，插件说明与约定
```

## 核心概念

### Item（工作项）
研发活动的最小单元。每个 Item 对应一个明确的任务（需求/缺陷/技术任务等），
拥有唯一标识、状态、上下文和产出物。

### Flow（工作流）
Item 的状态流转路径。定义 Item 从创建到完成经历的阶段，
每个阶段可绑定准入条件、自动化动作和检查点。

### Memory（记忆）
项目级的持久化上下文。存储在 `.feflow/` 目录下，
包含项目配置、历史决策、团队约定等，跨会话可用。

### Evidence（证据）
验证 Item 完成质量的客观依据。包括测试结果、审查记录、
构建产物等，确保"做得对"不是自我声明而是有据可查。

## 与 Superpowers 的关系

feflow 是 Superpowers 生态中的**领域插件**，不替代 Superpowers 的通用能力：

- Superpowers 提供：brainstorming、planning、TDD、code-review 等通用工作流
- feflow 提供：研发协作场景下的 Item/Flow/Memory/Evidence 管理
- 协作方式：feflow 的 hooks 在 Superpowers 工作流的关键节点注入领域逻辑

使用原则：
- 通用开发任务优先使用 Superpowers 工作流
- 涉及需求管理、版本规划、发布协调等场景时启用 feflow
- feflow 的 agents 可调用 Superpowers 的 skills，反之亦然

## 状态检测

feflow 通过 `hooks/session-start/detect.sh` 在会话启动时自动检测：
- `.feflow/` 目录是否存在（项目是否已初始化）
- `project/init-config.md` 是否存在（初始化配置是否完成）

检测结果以 JSON 格式注入会话上下文，供后续 skills 和 agents 使用。
