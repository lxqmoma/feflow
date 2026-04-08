---
description: 创建或查看 feflow 工作项。/task [描述] 创建新任务，/task list 查看列表
---

# /task

创建新的工作项或查看已有工作项列表。

## 触发方式

```
/task 实现用户登录页面         # 创建新任务
/task list                    # 查看工作项列表
/task dashboard               # Item 状态全景仪表盘
/task evidence {ITEM-ID}      # 查看某个 Item 的证据链
/task deps                    # 查看 Item 依赖关系图
```

## 执行逻辑

### 创建新任务（/task [描述]）

当参数为任务描述时：

1. 调用 `feflow:orchestrator` skill
2. orchestrator 根据描述创建新 Item：
   - 分配唯一 Item ID
   - 评估任务级别（L1/L2/L3）
   - 创建 Item 文件到 `.feflow/items/`
   - 启动对应级别的工作流

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

调用 `feflow:evidence-chain` skill，展示指定 Item 从创建到完成的完整证据链。

### 依赖关系（/task deps）

调用 `feflow:item-orchestration` skill，展示当前所有活跃 Item 的依赖图和执行状态。

## 前置条件

- 项目已完成 feflow 初始化（`.feflow/` 目录存在）
- 若未初始化，提示用户先运行 `/init`
