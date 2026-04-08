---
name: flow-test-task
description: 测试任务流程。补测试债、建立 e2e、专项测试验收。
---

# flow-test-task — 测试任务流程

当 orchestrator 将任务分类为 TEST 时，按本流程推进。核心原则：**只做测试，不改业务代码**。

用于：给老模块补测试覆盖、建立 e2e 测试、做专项测试验收。

## 前置条件

- feflow 已初始化，memory-load 已执行，Item 已生成（如 `TEST-001`）
- 分支命名：`test/{ITEM-ID}-{slug}`

---

## 阶段 1：测试范围定义

1. 明确测试目标：补覆盖 / 建 e2e / 专项验收
2. 确定目标模块，查询 memory 中的风险标记
3. **优先级**：高风险无测试 > 高风险低覆盖 > 常规补充
4. 产出至 `.feflow/items/{ITEM-ID}/test-scope.md`（含目标、模块列表、当前覆盖率、排除范围）

## 阶段 2：测试用例设计

1. 调用 QA agent 主导用例设计
2. 按模块组织，每个用例：场景描述、前置条件、操作步骤、预期结果
3. 覆盖维度：正常路径 / 边界场景 / 异常输入 / 并发异步
4. 产出至 `.feflow/items/{ITEM-ID}/test-cases.md`

## 阶段 3：测试实施

1. 创建分支 `test/{ITEM-ID}-{slug}`
2. 按用例编写测试代码，遵循项目既有测试风格和工具链
3. **硬规则：不修改业务代码**——发现 bug 记录后另开 BUG Item
4. 确保新增测试全部通过，记录至 `implementation-log.md`

## 阶段 4：测试报告

1. 产出至 `.feflow/items/{ITEM-ID}/test-report.md`：
   - 执行概要（总用例 / 通过 / 失败 / 跳过）
   - 覆盖率变化（前 → 后）
   - 发现的问题（+ 对应 BUG Item ID）
   - 仍未覆盖的风险区域、后续建议
2. 创建 PR（标题：`test({scope}): {描述} [{ITEM-ID}]`）
3. 调用 memory-update 记录覆盖率变化、发现的问题、风险区域

---

## 状态流转

```
test_scope_defined → cases_designed → implementing → report_generated → completed
```

## 异常处理

- **发现业务 bug**：不在此 Item 修复，记录后创建 BUG Item
- **模块不可测**（强耦合/无接口）：记录原因，建议先重构（另开 REFACTOR Item）
- **覆盖率目标未达成**：如实报告，说明原因和后续计划
