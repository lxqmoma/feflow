---
description: 交付入口。用于真正要落地的研发任务；按风险决定是否创建 Item。
---

# /task

进入 feflow Delivery 模式，或查看已有工作项。

## 触发方式

```
/task 实现用户登录页面         # 开始交付任务
/task 修复构建失败             # 开始交付任务
/task list                    # 查看工作项列表
/task dashboard               # Item 状态全景仪表盘
/task evidence {ITEM-ID}      # 查看某个 Item 的证据链
/task deps                    # 查看 Item 依赖关系图
```

## 模式说明

`/task` 不是“任何任务都必须立项”的入口，而是“需要真正交付”的入口。

当用户要修改代码、配置、测试、脚本、文档或交付可执行结果时，进入 Delivery 模式。

## 执行逻辑

### 开始交付（/task [描述]）

当参数为任务描述时：

1. 调用 `feflow:orchestrator` 进行模式与风险判断。
2. 先判断任务级别和执行路径：
   - **L1 / 低风险**：可直接分析、修改、验证，不默认创建 Item。
   - **L2 / 中风险**：建议创建 Item，并记录计划、证据和关键决策。
   - **L3 / 高风险**：应创建 Item，并启用更严格的评审、验证和回滚约束。
   - **Incident / 事件型**：应改走 `/incident` 或等价事件路径。
3. 仅在以下场景默认创建 Item：
   - 任务跨多个会话、多人协作或存在明确依赖
   - 需要长期追踪、证据链或依赖关系
   - 用户明确要求走完整治理流程
4. 对于普通单点改动，不应为了“流程完整”强行要求初始化或立项。

### 查看列表（/task list）

当参数为 `list` 时：

1. 读取 `.feflow/items/` 目录下的所有 Item 文件
2. 按状态分组展示：
   - 进行中的 Item
   - 待处理的 Item
   - 已完成的 Item
3. 每个 Item 展示：ID、标题、级别、当前状态、创建时间

### 仪表盘（/task dashboard）

调用 `feflow:dashboard` skill，展示所有 Item 的状态分布、进度概览和风险提示。

### 证据链（/task evidence {ITEM-ID}）

调用 `feflow:evidence-chain` skill，展示指定 Item 在当前风险等级下的证据画像与关键缺口。

### 依赖关系（/task deps）

调用 `feflow:item-orchestration` skill，展示当前所有活跃 Item 的依赖图和执行状态。

## 前置条件与降级策略

- `/task list`、`/task dashboard`、`/task evidence`、`/task deps` 依赖 `.feflow/` 工作区。
- 若用户只是开始一个低风险交付任务，`.feflow/` 未初始化不应成为阻塞。
- 只有当任务需要治理能力时，才提示用户使用 `/init` 建立工作区。
