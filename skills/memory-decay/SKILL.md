---
name: memory-decay
description: 记忆健康维护。v2 中它是低频整理工具，用来减少过时记忆噪音，而不是初始化时默认跑的重任务。
---

# memory-decay：v2 记忆健康维护

`memory-decay` 的目标不是“自动归档越多越好”，而是保持记忆库对未来任务仍然有用。

## 触发条件

- 用户执行 `/feflow:memory decay`
- 记忆库规模明显增大，且 stale 比例较高
- 仪表盘或人工检查发现记忆噪音在增加

默认不建议在 `project-init` 时自动全量执行。

## v2 原则

1. 保守衰减，避免误删高价值经验。
2. 优先降低检索权重，而不是急着归档。
3. 不改正文，只维护状态与元信息。

## 状态建议

| 状态 | 含义 | 处理 |
|------|------|------|
| `active` | 仍可信且常用 | 正常参与检索 |
| `stale` | 长时间未验证，但可能仍有价值 | 降低检索优先级 |
| `needs_review` | 很久未验证，且价值存疑 | 标记待人工判断 |
| `archived` | 明确过时或被替代 | 不参与默认检索 |
| `superseded` | 已被新记忆覆盖 | 不参与默认检索 |

## 扫描范围

检查：

- `modules/`
- `patterns/`
- `incidents/`

默认不处理：

- `project/invariants.md`
- `project/coding-doctrine.md`

## 衰减策略

### 第一步：识别候选项

综合这些信号：

- `last_verified_at`
- `created_at`
- `status`
- 是否已有 `superseded_by`
- 是否长期未被引用

### 第二步：优先降级

优先把 `active` 降为 `stale` 或 `needs_review`，而不是立即归档。

### 第三步：人工确认归档

只有在明确价值很低或已被替代时，才建议归档。

## 输出要求

输出应包括：

- 当前状态分布
- 新增的 stale / needs_review 项
- 建议归档但尚未归档的项目
- 健康度结论

## 约束

1. 单次处理保持小批量。
2. 没有充分理由时不要自动归档。
3. 发现互斥或被覆盖的旧记忆时，可优先标记 `superseded`。

## 关系

- `memory-load` 依赖这些状态决定检索优先级
- `memory-update` 写入新记忆时，可间接触发对旧记忆的 superseded 判断
