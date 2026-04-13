[English](./README.en.md)

# feflow

前端研发协作治理层。

feflow 的目标不是把每个请求都包装成“先立项、再分阶段确认”的流程，而是让 AI 在前端研发场景下：

- 该直接读仓库时直接读
- 该直接做小改动时直接做
- 该引入治理时再引入治理
- 该处理事故时优先止血

v2 的核心方向是：**默认体验接近强助手，治理能力按风险介入。**

## 它解决什么问题

通用编码助手在前端研发协作里，常见缺口有四类：

1. 缺少可持续的项目记忆
2. 缺少跨阶段的任务追踪
3. 缺少基于证据的完成判定
4. 缺少对事故、发布、跨模块改动的治理约束

feflow 保留这些能力，但不再把它们变成所有任务的默认负担。

## v2 设计哲学

### 1. 默认直接，不默认流程化

读仓库、解释代码、分析插件、评审架构，这些任务不应该先初始化、先建 Item、先走 flow。

### 2. 治理按风险介入

只有当任务真的需要追踪、证据、依赖管理、多人协作、回滚约束时，才进入更重的治理路径。

### 3. 控制平面隐藏

`skill`、`hook`、`gate`、`role`、`Item`、`memory layer` 是内部实现概念，不应该成为用户主要面对的产品语言。

### 4. 事故优先恢复，不优先补材料

线上故障、回滚、紧急修复，优先恢复业务与隔离影响，证据和复盘可以在稳定后补齐。

### 5. 证据只在有价值时强制

小而局部的低风险任务，不应该为了“完整性”强行拉起整套证据链。

## 三种模式

### Assist

只读分析模式，用于：

- 深度理解仓库或插件
- 解释模块、架构、数据流
- 评审 prompt / flow / 设计哲学
- 分析风险点、耦合点、体验问题

特点：

- 不要求 `.feflow/`
- 不默认创建 Item
- 不应该把阅读任务拆成很多轮确认

### Delivery

交付模式，用于：

- 改代码
- 改配置
- 写测试
- 调整脚本
- 修改文档或流程

特点：

- 先按风险判断
- L1 任务可直接做
- L2/L3 再逐步引入 Item、记忆、证据、门禁

### Incident

事件模式，用于：

- 线上事故
- 热修复
- 发布异常
- 高优先级稳定性问题

特点：

- 先止血
- 优先最小恢复方案
- 稳定后再补充复盘和长期修复

## 风险分级

| 级别 | 含义 | 默认策略 |
|------|------|----------|
| **L1** | 局部、小范围、低风险 | 直接分析/修改/验证，通常不建 Item |
| **L2** | 多文件或中等风险 | 轻量治理，Item 可选但通常有帮助 |
| **L3** | 跨模块、迁移、外部行为风险明显 | 应启用 Item、评审、证据、回滚约束 |
| **Incident** | 生产事件、时间敏感故障 | 先恢复，后补治理材料 |

## 快速开始

### 安装

```bash
claude plugins marketplace add lxqmoma/feflow
claude plugins install feflow@feflow-marketplace
```

### 推荐使用方式

```text
# 只读理解/评审
/feflow:assist 深度理解这个插件
/feflow:assist 评审当前 flow 的设计问题

# 仓库画像
/feflow:scan

# 实际交付
/feflow:task 修复构建失败
/feflow:task 实现用户登录页

# 事故处理
/feflow:incident 发布后首页白屏，先帮我止血
```

### 什么时候需要初始化

只有当你要启用完整治理能力时，才需要：

```text
/feflow:init
```

初始化会创建 `.feflow/` 工作区，用于：

- Item 持久化
- 项目记忆
- 证据沉淀
- 依赖关系与仪表盘

以下场景通常**不需要**初始化：

- 读仓库
- 架构分析
- 插件评审
- prompt / flow 评审
- 很多 L1 小改动

## 命令

| 命令 | 说明 |
|------|------|
| `/feflow:assist` | 只读分析入口 |
| `/feflow:task` | 交付入口，按风险决定治理深度 |
| `/feflow:incident` | 事故/热修复入口 |
| `/feflow:scan` | 仓库扫描与风险画像 |
| `/feflow:init` | 初始化 `.feflow/` 工作区 |
| `/feflow:memory` | 查看或管理持久化项目记忆 |

## 仓库结构

```text
feflow/
├── skills/      # 流程、扫描、记忆、证据、门禁等能力
├── agents/      # PM / Designer / FE / Backend / QA / Reviewer / Researcher
├── commands/    # assist / task / incident / scan / init / memory
├── adapters/    # Cursor / Windsurf / 通用 AGENTS 适配
├── hooks/       # SessionStart 检测与上下文注入
├── scripts/     # 本地 smoke 检查等辅助脚本
├── templates/   # 工作区与治理模板
├── examples/    # 最小 v2 工作区样例
├── README.md
└── CLAUDE.md
```

## 样例

仓库内提供了一个最小可读的 v2 工作区样例，方便直接检查 `.feflow` 在新设计下应该长什么样：

- [`examples/minimal-v2-workspace/README.md`](./examples/minimal-v2-workspace/README.md)

## 本地自检

仓库内提供了一个最小 smoke 检查脚本，用来确认 v2 的关键入口还在，且明显的 v1 官僚式话术没有重新混回核心路径：

```bash
./scripts/smoke-v2.sh
```

## Dogfood 验收

除了静态 smoke，仓库还提供了一份行为验收规范，用来人工回归 `Assist / Delivery-L1 / Delivery-L3 / Incident` 四类真实请求：

- [`V2-ACCEPTANCE-SUITE.md`](./V2-ACCEPTANCE-SUITE.md)

## 与 Superpowers 的关系

feflow 不应该和 Superpowers 竞争“谁来接管所有任务”，而应该形成分工：

| 维度 | Superpowers | feflow |
|------|-------------|--------|
| 默认体验 | 通用强助手 | 前端研发治理层 |
| 优势 | 直接做事、通用协作、通用 planning/review | Item/Memory/Evidence/Incident 治理 |
| 适合场景 | 通用开发与编码任务 | 研发协作、复杂交付、事故治理、可追踪执行 |

理想状态下：

- 小任务体验要接近 Superpowers
- 复杂任务治理能力要强于通用助手
- 事故处理要比通用 planning 更快进入恢复路径

## 当前改造方向

v2 第一阶段重点不是“再加更多 flow”，而是先修正默认交互：

1. 默认路由到 Assist / Delivery / Incident
2. 不再把初始化和 Item 变成所有任务的硬前置
3. 不再把内部治理术语暴露成用户负担
4. 让 quality gate 变成“阻塞器”，不是“朗读器”
5. 让 `scan` 和 `assist` 可以脱离 `.feflow/` 直接工作

## 方法论

**做得对** 仍然成立，但解释变了：

- **放得活**：流程要分层，不一刀切
- **管得住**：真正高风险任务可追踪、可回滚
- **记得住**：重要项目上下文可沉淀
- **接得稳**：AI 产出要能让人接手
- **啃得动**：旧仓库、脏仓库也能工作
- **查得到**：证据在需要时可审计

## License

[MIT](./LICENSE)
