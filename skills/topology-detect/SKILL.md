---
name: topology-detect
description: 仓库拓扑识别。检测项目是单仓单应用/单仓多应用/monorepo，识别交付单元和依赖关系。
---

# topology-detect：仓库拓扑识别

## 触发条件

- 由 `feflow:project-init` 在阶段一自动调用
- 用户执行 `/feflow-topology` 或明确要求识别仓库结构
- 项目结构发生重大变更后手动触发

## 前置条件

确认当前目录包含 `package.json`，否则报告「非 Node.js 项目，拓扑检测受限」并尝试基于目录结构推断。

## 检测内容

### 1. 仓库形态判定

按优先级依次检测，首个命中即确定形态：

| 形态 | 判定条件 |
|------|----------|
| `monorepo` | 存在 `pnpm-workspace.yaml` / `lerna.json` / `nx.json` / `turbo.json`，或 `package.json` 含 `workspaces` 字段 |
| `multi-app` | 无 workspace 配置，但 `apps/` 或 `packages/` 下存在多个含 `package.json` 的子目录 |
| `single-app` | 以上均不满足，仅根目录有 `package.json` |

### 2. Workspace 工具识别

检测项目使用的 workspace 管理工具：

| 工具 | 判定条件 |
|------|----------|
| pnpm | `pnpm-workspace.yaml` 存在 |
| yarn | `package.json` 含 `workspaces` + `yarn.lock` 存在 |
| npm | `package.json` 含 `workspaces` + `package-lock.json` 存在 |
| turbo | `turbo.json` 存在 |
| nx | `nx.json` 存在 |
| lerna | `lerna.json` 存在 |

可同时存在多个（如 pnpm + turbo）。

### 3. 交付单元列表

扫描 workspace 配置声明的目录，列出所有交付单元：

```bash
# pnpm 示例：解析 pnpm-workspace.yaml 中的 packages 字段
# 遍历匹配目录，读取每个 package.json 的 name、version、private 字段
```

每个交付单元记录：名称、路径、是否 private、类型推断（app/lib/shared/config/tool）。

类型推断规则：
- 路径含 `apps/` → app
- 路径含 `packages/` 且 `private: false` → lib
- 路径含 `shared/` 或 `common/` → shared
- 路径含 `config/` 或 `tools/` → config/tool
- 无法推断 → unknown

### 4. 共享依赖与公共层

识别被多个交付单元依赖的内部包：

1. 遍历所有交付单元的 `package.json`
2. 提取 `dependencies` 和 `devDependencies` 中以 `workspace:` 协议引用的包
3. 统计每个内部包被引用次数，>= 2 次标记为共享依赖

### 5. 发布边界

区分独立发布和内部消费的交付单元：

| 分类 | 判定条件 |
|------|----------|
| 独立发布 | `private: false`，或含 `publishConfig`，或有对应 npm 包名 |
| 仅内部消费 | `private: true`，或仅被 workspace 内部引用 |
| 可部署应用 | 含 `build`/`start`/`dev` script，且路径在 `apps/` 下 |

### 6. 影响图谱

构建改动扩散路径：

1. 以每个交付单元为节点
2. 以 workspace 内部依赖为有向边
3. 输出依赖关系列表（A → B 表示改动 B 可能影响 A）

## 产出

检测结果写入 `.feflow/init-config.md` 的 `workspace_shape` 字段：

```markdown
## workspace_shape

- **形态**: monorepo
- **workspace 工具**: pnpm + turbo
- **交付单元数**: 8

### 交付单元

| 名称 | 路径 | 类型 | 发布 |
|------|------|------|------|
| @scope/web | apps/web | app | 可部署 |
| @scope/admin | apps/admin | app | 可部署 |
| @scope/ui | packages/ui | lib | 独立发布 |
| @scope/utils | packages/utils | shared | 仅内部 |

### 共享依赖
- @scope/ui — 被 web, admin 依赖
- @scope/utils — 被 ui, web, admin 依赖

### 影响图谱
- 改动 @scope/utils → 影响 ui, web, admin
- 改动 @scope/ui → 影响 web, admin
```

## 错误处理

| 场景 | 处理 |
|------|------|
| workspace 配置语法错误 | 报告解析失败，回退为 single-app |
| 子包 package.json 缺失 | 跳过该目录，标记警告 |
| 循环依赖 | 检测并报告循环路径，不中断 |
