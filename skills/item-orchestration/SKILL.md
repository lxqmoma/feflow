---
name: item-orchestration
description: 多 Item 依赖与并行编排。管理工作项之间的依赖关系，识别可并行的独立任务，协调执行顺序。
---

# item-orchestration: 多 Item 依赖与并行编排

## 触发条件

- orchestrator 创建新 Item 时自动检查是否存在依赖关系
- 用户执行 `/feflow:task deps` 查看当前依赖图和执行状态

## 前置条件

`.feflow/items/` 目录存在，且至少有一个活跃 Item（status 非 `done` / `cancelled`）。

## 依赖声明

在 Item 的 `meta.md` frontmatter 中增加以下可选字段：

```yaml
depends_on: [ITEM-ID-1, ITEM-ID-2]   # 当前 Item 依赖的前置 Item
blocks: [ITEM-ID-3]                    # 当前 Item 阻塞的后续 Item
```

`depends_on` 和 `blocks` 互为镜像关系。写入一方时自动校验另一方的一致性。

## 依赖图构建

1. 扫描 `.feflow/items/` 下所有活跃 Item 的 `meta.md`
2. 提取每个 Item 的 `depends_on` 和 `blocks` 字段
3. 构建有向无环图（DAG），节点为 Item，边为依赖关系
4. **环检测** — 发现循环依赖时立即报错，列出环路径，阻止创建

## 并行与串行规则

| 场景 | 处理 |
|------|------|
| 无依赖关系的 Item | 可并行推进（使用 subagent 并行调度） |
| 有 `depends_on` 的 Item | 等待所有前置 Item 完成对应阶段后才能开始 |
| 前置 Item 被 `cancelled` | 通知依赖方，由用户决定是否继续 |
| 前置 Item 被 `blocked` | 依赖方同步标记为 `waiting`，附注原因 |

## 冲突检测

多个并行 Item 修改同一文件或模块时发出警告：

1. 从各 Item 的 `dev-plan.md` 提取声明的改动文件范围
2. 对比多个 Item 的文件范围，存在交集则标记 `conflict_risk`
3. 输出冲突警告：涉及的 Item ID、冲突文件列表、建议处理方式（串行化 / 先合并）

## 状态看板

输出当前所有活跃 Item 的依赖图和执行状态：

```
## Item 依赖看板

FEAT-20260408-001-user-avatar  [implementing]
  ├── MOD-20260408-002-upload-api  [implementing] (并行)
  └── BUG-20260408-003-image-crop  [waiting]
       └─ depends_on: FEAT-20260408-001

独立 Item（无依赖）:
  - UI-20260408-004-dark-mode  [implementing]

冲突警告:
  - FEAT-001 与 MOD-002 均修改 src/utils/upload.ts
```

## 执行约束

1. 不自动修改 Item 状态，仅提供建议和警告
2. 依赖关系变更需写入对应 Item 的 `meta.md`，保持双向一致
3. 单次扫描上限 50 个 Item，超出时仅处理最近 30 天创建的 Item
4. 并行调度遵循 Superpowers 的 `dispatching-parallel-agents` 规范

## 与其他 skill 的关系

- **上游**：orchestrator 创建 Item 时调用
- **下游**：流程 skill 根据依赖状态决定是否启动
- **关联**：quality-gate 可将依赖检查纳入 Gate 1 前置条件
