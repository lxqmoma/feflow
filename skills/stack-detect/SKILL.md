---
name: stack-detect
description: 检测项目技术栈并主动安装对应的 Claude Code skills。在项目初始化时自动调用。
---

# stack-detect：技术栈检测与 Skill 安装

## 触发条件

- 由 `feflow:project-init` 在阶段四自动调用
- 用户执行 `/feflow-stack` 或明确要求重新检测技术栈
- 项目依赖发生重大变更后手动触发（如框架升级、新增构建工具）

## 前置检查

1. 确认 `package.json` 存在，否则终止并报告「非 Node.js 项目，无法检测技术栈」
2. 确认 `.feflow/` 目录存在（如从 project-init 调用则已保证）

## 执行步骤

### 步骤一：技术栈检测

#### 1.1 读取 package.json 依赖

```bash
# 提取所有依赖包名
DEPS=$(cat package.json | jq -r '(.dependencies // {} | keys[]) , (.devDependencies // {} | keys[])')
echo "$DEPS"
```

#### 1.2 检查配置文件

除 package.json 外，还需检查以下配置文件的存在情况，用于辅助判断：

| 配置文件 | 对应技术栈 |
|----------|-----------|
| `nuxt.config.ts` / `nuxt.config.js` | Nuxt |
| `vite.config.ts` / `vite.config.js` | Vite |
| `vitest.config.ts` / `vitest.config.js` / `vitest.workspace.ts` | Vitest |
| `uno.config.ts` / `unocss.config.ts` | UnoCSS |
| `tailwind.config.ts` / `tailwind.config.js` | Tailwind CSS |
| `pnpm-workspace.yaml` / `pnpm-lock.yaml` | pnpm |
| `turbo.json` | Turborepo |
| `nx.json` | Nx |
| `tsconfig.json` | TypeScript |
| `playwright.config.ts` | Playwright |
| `cypress.config.ts` / `cypress.config.js` | Cypress |
| `.eslintrc.*` / `eslint.config.*` | ESLint |
| `nest-cli.json` | NestJS |
| `.storybook/` | Storybook |
| `astro.config.*` | Astro |
| `svelte.config.*` | SvelteKit |
| `next.config.*` | Next.js |
| `webpack.config.*` | Webpack |
| `rollup.config.*` | Rollup |

```bash
# 批量检查配置文件存在情况
for config in \
  "nuxt.config.ts" "nuxt.config.js" \
  "vite.config.ts" "vite.config.js" \
  "vitest.config.ts" "vitest.config.js" "vitest.workspace.ts" \
  "uno.config.ts" "unocss.config.ts" \
  "tailwind.config.ts" "tailwind.config.js" \
  "pnpm-workspace.yaml" \
  "turbo.json" "nx.json" \
  "tsconfig.json" \
  "playwright.config.ts" \
  "cypress.config.ts" "cypress.config.js" \
  "nest-cli.json" \
  "next.config.ts" "next.config.js" "next.config.mjs" \
  "astro.config.mjs" "astro.config.ts" \
  "svelte.config.js" \
  "webpack.config.js" "webpack.config.ts" \
  "rollup.config.js" "rollup.config.ts" \
; do
  if [ -f "$config" ]; then
    echo "FOUND: $config"
  fi
done

# 检查目录
for dir in ".storybook" "cypress"; do
  if [ -d "$dir" ]; then
    echo "FOUND_DIR: $dir"
  fi
done

# 检查 lock 文件判断包管理器
for lock in "pnpm-lock.yaml" "yarn.lock" "package-lock.json" "bun.lockb"; do
  if [ -f "$lock" ]; then
    echo "LOCK: $lock"
  fi
done
```

#### 1.3 汇总检测结果

将依赖包和配置文件检测结果合并，生成检测到的技术栈清单。优先级规则：

- **配置文件优先**：如果存在 `nuxt.config.ts`，即使 dependencies 里没有 nuxt（可能通过 npx 运行），也判定为使用 Nuxt
- **dependencies 优先于 devDependencies**：框架类依赖通常在 dependencies 中
- **直接依赖优先于间接依赖**：只检测顶层依赖，不递归分析 node_modules

### 步骤二：Skill 安装映射

以下是技术栈到 Claude Code skill 的映射表：

| 检测条件（满足任一） | Skill 名称 | 说明 |
|-----------------------|------------|------|
| `vue` in deps | `vue-best-practices` | Vue 3 最佳实践 |
| `vue` in deps | `vue` | Vue 3 核心 API |
| `nuxt` in deps 或 `nuxt.config.*` 存在 | `nuxt` | Nuxt 框架 |
| `vite` in deps 或 `vite.config.*` 存在 | `vite` | Vite 构建工具 |
| `vitest` in deps 或 `vitest.config.*` 存在 | `vitest` | Vitest 测试框架 |
| `unocss` in deps 或 `uno.config.*` 存在 | `unocss` | UnoCSS 原子化 CSS |
| `pinia` in deps | `pinia` | Pinia 状态管理 |
| `vue-router` in deps | `vue-router-best-practices` | Vue Router 最佳实践 |
| `pnpm-lock.yaml` 存在 或 packageManager 含 pnpm | `pnpm` | pnpm 包管理器 |
| `turbo.json` 存在 或 `turbo` in deps | `turborepo` | Turborepo 构建系统 |
| `@vue/test-utils` in deps 或 `vue` + `vitest` 同时存在 | `vue-testing-best-practices` | Vue 测试最佳实践 |
| `typescript` in deps 或 `tsconfig.json` 存在 | _(TypeScript 内置支持，不需要额外 skill)_ | — |
| `tailwindcss` in deps 或 `tailwind.config.*` 存在 | _(暂无官方 tailwind skill)_ | 记录到检测结果 |
| `@nestjs/core` in deps 或 `nest-cli.json` 存在 | `nestjs-best-practices` | NestJS 最佳实践 |
| `playwright` / `@playwright/test` in deps | _(内置支持)_ | 记录到检测结果 |
| `cypress` in deps 或 `cypress.config.*` 存在 | _(暂无官方 cypress skill)_ | 记录到检测结果 |
| `vitepress` in deps | `vitepress` | VitePress 文档站点 |
| `slidev` / `@slidev/cli` in deps | `slidev` | Slidev 演示文稿 |
| `@vueuse/core` in deps | `vueuse-functions` | VueUse 工具函数 |
| `tsdown` in deps | `tsdown` | tsdown 打包工具 |
| `ant-design-vue` in deps | `antdv-next` | Ant Design Vue 组件库 |

### 步骤三：查询已安装 Skills

在安装前，先查询当前已安装的 skills，避免重复安装。

```bash
# 列出已安装的 skills
claude plugins list 2>/dev/null || echo "无法获取已安装 skills 列表"
```

将已安装 skill 列表存入变量 `INSTALLED_SKILLS`，用于后续过滤。

### 步骤四：过滤与批量安装

```bash
# 对于每个需要安装的 skill：
# 1. 检查是否已安装
# 2. 如果未安装，执行安装

SKILLS_TO_INSTALL=()
SKILLS_ALREADY_INSTALLED=()
SKILLS_FAILED=()
SKILLS_SUCCEEDED=()

for skill in "${DETECTED_SKILLS[@]}"; do
  if echo "$INSTALLED_SKILLS" | grep -q "$skill"; then
    SKILLS_ALREADY_INSTALLED+=("$skill")
    echo "[跳过] $skill — 已安装"
  else
    SKILLS_TO_INSTALL+=("$skill")
  fi
done

# 逐个安装（不使用并行，确保输出清晰）
for skill in "${SKILLS_TO_INSTALL[@]}"; do
  echo "[安装] 正在安装 $skill ..."
  if claude plugins install "$skill" 2>&1; then
    SKILLS_SUCCEEDED+=("$skill")
    echo "[成功] $skill 安装完成"
  else
    SKILLS_FAILED+=("$skill")
    echo "[失败] $skill 安装失败，继续处理下一个"
  fi
done
```

### 失败处理规则

- **单个 skill 安装失败不中断整体流程**：记录失败原因，继续安装下一个
- **全部失败**：输出警告，建议用户检查网络连接或手动安装
- **skill 名称不存在**：记录为「skill 不存在，可能尚未发布」，不视为严重错误
- **网络超时**：记录为「网络超时」，建议稍后重试
- **权限错误**：记录为「权限不足」，建议检查 Claude Code 配置

## 输出格式

检测和安装完成后，输出结构化结果：

```markdown
## 技术栈检测结果

### 检测到的技术栈

| 技术栈 | 版本 | 来源 |
|--------|------|------|
| Vue | ^3.4.0 | dependencies |
| Nuxt | ^3.12.0 | dependencies + nuxt.config.ts |
| Vite | ^5.3.0 | devDependencies |
| Vitest | ^1.6.0 | devDependencies + vitest.config.ts |
| UnoCSS | ^0.61.0 | devDependencies + uno.config.ts |
| Pinia | ^2.1.0 | dependencies |
| Vue Router | ^4.4.0 | dependencies |
| pnpm | 9.x | pnpm-lock.yaml |
| TypeScript | ^5.5.0 | devDependencies + tsconfig.json |

### Skill 安装结果

| Skill | 状态 | 说明 |
|-------|------|------|
| vue-best-practices | 已安装 | 本次跳过 |
| nuxt | 新安装 | 安装成功 |
| vite | 新安装 | 安装成功 |
| vitest | 新安装 | 安装成功 |
| unocss | 新安装 | 安装成功 |
| pinia | 新安装 | 安装成功 |
| vue-router-best-practices | 新安装 | 安装成功 |
| pnpm | 已安装 | 本次跳过 |
| vue-testing-best-practices | 安装失败 | skill 未找到，建议手动安装 |

### 未覆盖的技术栈

以下检测到的技术栈暂无对应的 Claude Code skill，已记录到检测结果供参考：

- Tailwind CSS v3.4.0 — 暂无官方 skill
- Playwright v1.45.0 — 内置支持，无需额外 skill

### 统计

- 检测到技术栈：{total_detected} 项
- 需要安装 skill：{to_install} 个
- 安装成功：{succeeded} 个
- 安装跳过（已安装）：{already_installed} 个
- 安装失败：{failed} 个
```

## 与 project-init 的协作

当由 `feflow:project-init` 调用时：

1. 接收阶段一扫描识别的技术栈清单作为输入，跳过步骤一的重复检测
2. 安装结果写入 `.feflow/project/stack-detection.md` 的已安装 skills 部分
3. 返回安装结果给 project-init，用于初始化总结输出

## 独立调用

当用户直接调用 `feflow:stack-detect` 时：

1. 执行完整的步骤一检测
2. 输出检测和安装结果
3. 如果 `.feflow/project/stack-detection.md` 存在，更新该文件
4. 如果 `.feflow/` 不存在，只输出结果，不写入文件

## 注意事项

- 检测基于静态分析（package.json + 配置文件），不执行 `npm install` 或 `pnpm install`
- 版本号从 package.json 中提取，可能含有 `^` / `~` 等范围标识
- Monorepo 项目需要检查根目录和各子包的 package.json，但 skill 安装只在根级别执行一次
- 如果项目使用 workspace 协议（`workspace:*`），需要到对应子包的 package.json 中读取实际版本
- 安装 skill 不会修改项目代码或配置，仅影响 Claude Code 的能力扩展
