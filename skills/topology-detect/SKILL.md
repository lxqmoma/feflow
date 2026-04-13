---
name: topology-detect
description: 仓库拓扑识别。v2 中它用于明确交付边界和扫描范围，而不是只为初始化生成一个静态分类标签。
---

# topology-detect：v2 仓库拓扑识别

`topology-detect` 的目标是识别：

1. 这是单应用、多应用还是 monorepo
2. 实际交付单元有哪些
3. 共享包、共享组件和应用边界在哪里
4. 哪些边界会影响风险判断和扫描范围

## 触发条件

- `project-init` 需要建立最小仓库画像
- `repo-scan` 需要决定扫描深度和影响范围
- 用户显式要求识别仓库结构

## v2 原则

1. 识别边界，服务执行。
2. 不把拓扑识别变成只读标签收集。
3. 结果应能指导后续 search、scan、delivery 风险判断。

## 核心输出

### 仓库形态

- `single-app`
- `multi-app`
- `monorepo`
- `unknown`

### Workspace 工具

- pnpm / npm / yarn workspace
- turbo / nx / lerna

### 交付单元

识别：

- apps
- packages
- shared
- docs
- tooling

### 共享边界

识别这些高风险结构：

- 被多个应用依赖的内部包
- 共享 UI / design system
- 公共配置与构建脚本
- 多应用共用的 API 层或基础设施

## 输出要求

最终输出应足够回答：

1. 后续改动应该落在哪个交付单元
2. 哪些包或目录的改动会外溢
3. 哪些目录只是局部应用，哪些是共享基础设施

## 错误处理

### workspace 配置有误

降级为目录结构推断，不中止。

### 非 Node.js 项目

继续基于目录结构给出近似拓扑。

### 子包信息不完整

跳过损坏项，保留警告。
