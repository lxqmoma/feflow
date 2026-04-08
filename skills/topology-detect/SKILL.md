---
name: topology-detect
description: 仓库拓扑识别。检测项目是单仓单应用/单仓多应用/monorepo，识别交付单元和依赖关系。
---

# topology-detect：仓库拓扑识别

## 触发条件

- 由 `feflow:project-init` 在阶段一自动调用
- 用户执行 `/feflow-topology` 或明确要求识别仓库结构

## 检测内容

### 1. 仓库形态

按优先级首个命中即确定：

| 形态 | 判定条件 |
|------|----------|
| `monorepo` | 存在 `pnpm-workspace.yaml` / `lerna.json` / `nx.json` / `turbo.json`，或 `package.json` 含 `workspaces` |
| `multi-app` | 无 workspace 配置，但 `apps/` 或 `packages/` 下有多个含 `package.json` 的子目录 |
| `single-app` | 以上均不满足 |

### 2. Workspace 工具

| 工具 | 判定条件 |
|------|----------|
| pnpm | `pnpm-workspace.yaml` 存在 |
| yarn | `workspaces` + `yarn.lock` |
| npm | `workspaces` + `package-lock.json` |
| turbo | `turbo.json` 存在 |
| nx | `nx.json` 存在 |
| lerna | `lerna.json` 存在 |

可同时存在多个（如 pnpm + turbo）。

### 3. 交付单元列表

扫描 workspace 声明的目录，每个交付单元记录：名称、路径、是否 private、类型。

类型推断：`apps/` → app | `packages/` + `private: false` → lib | `shared/` / `common/` → shared | 其他 → unknown。

### 4. 共享依赖

遍历所有交付单元的 `dependencies`/`devDependencies`，统计 `workspace:` 协议引用。被引用 >= 2 次标记为共享依赖。

### 5. 发布边界

| 分类 | 判定条件 |
|------|----------|
| 独立发布 | `private: false` 或含 `publishConfig` |
| 仅内部消费 | `private: true` 或仅被 workspace 内部引用 |
| 可部署应用 | 含 `build`/`start` script 且在 `apps/` 下 |

### 6. 影响图谱

以交付单元为节点、内部依赖为有向边，输出改动扩散路径（改动 B → 影响 A）。

## 产出

写入 `init-config.md` 的 `workspace_shape` 字段：

```markdown
## workspace_shape
- **形态**: monorepo
- **workspace 工具**: pnpm + turbo
- **交付单元数**: 8

### 交付单元
| 名称 | 路径 | 类型 | 发布 |
|------|------|------|------|

### 共享依赖
- @scope/utils — 被 web, admin 依赖

### 影响图谱
- 改动 @scope/utils → 影响 ui, web, admin
```

## 错误处理

| 场景 | 处理 |
|------|------|
| 非 Node.js 项目 | 基于目录结构推断，标记「检测受限」|
| workspace 配置语法错误 | 回退为 single-app |
| 子包 package.json 缺失 | 跳过该目录，标记警告 |
| 循环依赖 | 报告循环路径，不中断 |
