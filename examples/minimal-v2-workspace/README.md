# minimal-v2-workspace

这是一个最小化的 `.feflow` v2 工作区样例。

它的目的不是演示“完整流程跑满”，而是演示 v2 的默认形态：

- 可以只初始化最小治理工作区
- 可以只追踪真正值得追踪的任务
- 文档产物保持短、实、可继续维护

## 目录说明

- `.feflow/project/`：最小项目画像和初始化配置
- `.feflow/memory/project/`：项目级不变量与协作戒律
- `.feflow/items/FEAT-EXAMPLE-001/`：一个被追踪的 L2 示例任务

## 示例任务

`FEAT-EXAMPLE-001` 模拟的是：

> 在已有搜索页上增加“最近搜索”入口，并保留旧搜索交互不变。

这个任务之所以被追踪，是因为它属于典型的 L2：

- 涉及页面和状态联动
- 需要一个短计划
- 需要保留最基本的验证和证据

## 你可以用这个样例检查什么

1. v2 下 `init-config.md` 是否足够简洁
2. `dev-plan.md` 是否还在写官样文章
3. `implementation-log.md` 是否只记录关键变化
4. `test-report.md` 是否只保留真正有判断价值的验证
5. `evidence.md` 是否能和实际 Git/PR/CI 证据模型对齐
