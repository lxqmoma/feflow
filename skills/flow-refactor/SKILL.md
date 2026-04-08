---
name: flow-refactor
description: 重构流程。先建安全网再动手，优先保证行为不变。
---

# flow-refactor — 重构流程

当 orchestrator 将任务分类为 REFACTOR 时，按本流程推进。核心原则：**先建安全网再动手，行为不变是底线**。

## 前置条件

- feflow 已初始化，memory-load 已执行，Item 已生成（如 `REFACTOR-001`）
- 分支命名：`refactor/{ITEM-ID}-{slug}`

---

## 阶段 1：重构目标定义

明确要重构什么、为什么重构、预期收益。**"让代码更好"不是合格目标**。

合格示例：消除循环依赖 / 拆分组件以支持复用 / 统一错误处理模式。产出至 `.feflow/items/{ITEM-ID}/refactor-goal.md`。

## 阶段 2：安全边界建立（不可跳过）

1. 检查目标模块现有测试覆盖率
2. 覆盖不足时补充：关键路径 snapshot、核心输入输出断言、边界场景防御
3. 确认重构前所有测试通过，记录基线状态
4. 产出至 `.feflow/items/{ITEM-ID}/safety-baseline.md`

**硬规则：安全边界未建立，不进入实施阶段。**

## 阶段 3：重构计划

1. 拆分为**可独立验证的步骤**，每步改动小、可回滚
2. 每步标注：改什么、预期行为变化（应为"无"）、验证方式
3. **禁止在重构中混入功能变更**——需要改行为时另开 Item
4. 呈现给用户确认，**未确认不可实施**
5. 产出至 `.feflow/items/{ITEM-ID}/role-fe/dev-plan.md`

## 阶段 4：分步实施

1. 创建分支，调用 quality-gate 门禁检查
2. 按计划逐步执行，每步完成后：运行测试确认通过 → 对比行为一致性 → 记录至 `implementation-log.md`
3. 发现功能缺陷不在此 Item 修复，记录后另开 Item

## 阶段 5：行为一致性验证

1. 运行全部测试（lint / type-check / unit / e2e）
2. 对比：公共 API / 组件 Props / 接口签名 / 关键路径输出 / 性能表现
3. 建议调用 QA agent 执行回归测试
4. 产出至 `.feflow/items/{ITEM-ID}/role-qa/test-report.md`

## 阶段 6：收尾

1. 创建 PR（标题：`refactor({scope}): {描述} [{ITEM-ID}]`）
2. 调用 memory-update 记录：重构决策、模块结构变化、后续改进点
3. 更新 Item 状态为 `completed`

---

## 状态流转

```
refactor_goal_defined → safety_baseline_built → plan_approved → implementing → behavior_verified → completed
```

## 异常处理

- **测试覆盖无法补充**：缩小重构范围，只动有安全网覆盖的部分
- **重构中发现 bug**：不在此 Item 修复，另开 BUG Item
- **行为不一致**：立即停止，回退到上一个通过点，分析原因
- **步骤不可回滚**：拆分为更小步骤，确保每步可独立回退
