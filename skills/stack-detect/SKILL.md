---
name: stack-detect
description: 技术栈检测。v2 中它优先提供项目事实画像；安装额外 skills 只是可选增强，不再作为初始化的默认副作用。
---

# stack-detect：v2 技术栈检测

`stack-detect` 的主要职责是回答：

1. 这是个什么技术栈项目
2. 哪些框架、工具、测试栈和包管理器在起作用
3. 哪些检测结果会影响后续 Assist / Delivery / Incident 判断

它不应该默认变成“自动安装一堆 skill”的隐式副作用。

## 触发条件

- `project-init` 或 `repo-scan` 需要技术栈画像
- 用户显式要求检测技术栈
- 项目框架或工具链发生显著变化后重新检测

## v2 原则

1. 检测优先，安装其次。
2. 静态分析优先，不执行构建或安装命令。
3. 即使不是标准 Node.js 项目，也尽量给出有限但可信的结果。
4. skill 安装必须是可选增强，不应阻断主流程。

## 检测来源

优先读取：

- `package.json`
- lock 文件
- 关键配置文件
- 目录结构信号

## 重点识别项

### 框架与运行形态

- Vue / Nuxt / React / Next / Svelte / Astro
- SPA / SSR / SSG / hybrid

### 构建与开发工具

- Vite / Webpack / Rollup / Turbopack / esbuild
- TypeScript
- lint / format 配置

### 测试栈

- Vitest / Jest / Playwright / Cypress
- Vue Test Utils / React Testing Library 等配套能力

### 样式与设计系统

- UnoCSS / Tailwind / Sass / Less
- 组件库
- 自定义设计系统痕迹

### 包管理与仓库管理

- pnpm / npm / yarn / bun
- workspace / monorepo 工具

## 输出要求

输出至少应包含：

1. 检测到的核心框架
2. 构建工具
3. 测试工具
4. 包管理方式
5. 影响后续协作的高价值结论

例如：

- “这是一个 Nuxt + Vite + Vitest + pnpm 项目”
- “检测到 monorepo 信号，后续扫描要注意子包边界”
- “没有测试配置，低风险任务可直接做，但高风险任务验证成本会更高”

## Skill 安装策略

只有在以下条件下才考虑安装额外 skills：

- 用户明确要求自动安装
- `project-init` 配置明确允许
- 当前环境已确认支持对应 skill

默认行为应是：

- 报告可匹配的 skills
- 说明哪些值得安装
- 不自动执行安装

## 错误处理

### 没有 `package.json`

继续基于配置文件和目录结构做有限检测。

### 配置文件缺失

按已找到的信号继续，不报硬错误。

### 检测结果不确定

明确标记为“推断”，不要伪装成确定事实。
