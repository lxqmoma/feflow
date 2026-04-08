---
name: topology-detect
description: 仓库拓扑识别。检测项目是单仓单应用/单仓多应用/monorepo，识别交付单元和依赖关系。
---

# topology-detect：仓库拓扑识别

## 触发条件

- 由 `feflow:project-init` 在阶段一自动调用
- 用户执行 `/feflow-topology` 或明确要求识别仓库结构

## 检测内容

### 1. 仓库形态（按优先级首个命中）

| 形态 | 判定条件 |
|------|----------|
| `monorepo` | 存在 `pnpm-workspace.yaml`/`lerna.json`/`nx.json`/`turbo.json`，或 `package.json` 含 `workspaces` |
| `multi-app` | 无 workspace 配置，但 `apps/`/`packages/` 下有多个含 `package.json` 的子目录 |
| `single-app` | 以上均不满足 |

### 2. Workspace 工具

pnpm（`pnpm-workspace.yaml`）/ yarn（`workspaces`+`yarn.lock`）/ npm（`workspaces`+`package-lock.json`）/ turbo（`turbo.json`）/ nx（`nx.json`）/ lerna（`lerna.json`）。可同时存在多个。

### 3. 交付单元

扫描 workspace 声明的目录，记录：名称、路径、private、类型。类型推断：`apps/`→app | `packages/`+非private→lib | `shared/`/`common/`→shared | 其他→unknown。

### 4. 共享依赖与发布边界

- **共享依赖** — `workspace:` 协议引用 >= 2 次的内部包
- **独立发布** — `private: false` 或含 `publishConfig`
- **仅内部消费** — `private: true` 或仅被内部引用
- **可部署应用** — 含 `build`/`start` script 且在 `apps/` 下

### 5. 影响图谱

以交付单元为节点、内部依赖为有向边，输出改动扩散路径。

## 产出

写入 `init-config.md` 的 `workspace_shape` 字段：

包含：形态、workspace 工具、交付单元表（名称/路径/类型/发布）、共享依赖列表、影响图谱。

## 错误处理

| 场景 | 处理 |
|------|------|
| 非 Node.js 项目 | 基于目录结构推断，标记「检测受限」|
| workspace 配置语法错误 | 回退为 single-app |
| 子包 package.json 缺失 | 跳过该目录，标记警告 |
| 循环依赖 | 报告循环路径，不中断 |
