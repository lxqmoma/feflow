# feflow 多平台适配器 / Multi-Platform Adapters

feflow 的核心内容（skills/、agents/、templates/）是平台无关的 Markdown 文件。
多平台适配只需要为每个平台提供入口文件，将 feflow 方法论注入对应工具的规则系统。

The core content of feflow (skills/, agents/, templates/) is platform-agnostic Markdown.
Multi-platform support only requires providing entry files for each platform,
injecting the feflow methodology into the tool's rule system.

## 适配方式 / How It Works

feflow 原生支持 Claude Code（通过 CLAUDE.md 和插件机制）。
其他平台通过复制适配文件到项目根目录来获得 feflow 的流程指引。

feflow natively supports Claude Code (via CLAUDE.md and plugin system).
Other platforms gain feflow workflow guidance by copying adapter files to the project root.

## 当前支持的平台 / Supported Platforms

| 平台 / Platform | 入口文件 / Entry File | 使用方式 / Usage |
|---------|------------|------|
| **Claude Code** | `CLAUDE.md` (原生) | `claude install-plugin` 直接安装 |
| **Cursor** | `cursor/rules.md` | 复制内容到项目根目录 `.cursorrules` |
| **Windsurf** | `windsurf/rules.md` | 复制内容到项目根目录 `.windsurfrules` |
| **通用 / Generic** | `generic/AGENTS.md` | 复制到项目根目录 `AGENTS.md`，适用于 Codex CLI 等工具 |

## 使用步骤 / Usage Steps

### Cursor

```bash
# 复制适配文件到项目根目录
cp adapters/cursor/rules.md /path/to/your/project/.cursorrules
```

### Windsurf

```bash
# 复制适配文件到项目根目录
cp adapters/windsurf/rules.md /path/to/your/project/.windsurfrules
```

### Generic (Codex CLI 等)

```bash
# 复制适配文件到项目根目录
cp adapters/generic/AGENTS.md /path/to/your/project/AGENTS.md
```

## 注意事项 / Notes

- 适配文件包含精简版方法论，完整定义需初始化 `.feflow/` 目录后使用
- 升级 feflow 后建议重新复制适配文件
- Adapter files contain a condensed methodology; full definitions require `.feflow/` init
- Re-copy adapter files after upgrading feflow
