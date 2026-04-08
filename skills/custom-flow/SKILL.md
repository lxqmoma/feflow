---
name: custom-flow
description: 流程模板自定义。允许用户定义自己的工作流程，扩展或覆盖内置流程。
---

# custom-flow：流程模板自定义

允许用户在 `.feflow/workflows/` 下定义自己的 Flow，扩展或覆盖内置流程。

---

## 存放路径

`.feflow/workflows/{flow-name}.md`，小写英文 + 连字符。与内置 flow skill 同名则覆盖。

## Flow 定义格式

Markdown + frontmatter，正文中每个二级标题为一个阶段：

```yaml
---
name: api-integration
description: 前后端 API 对接专用流程
extends: flow-feature          # 可选，继承内置流程
roles: [FE, Backend]
---
```

```markdown
## 阶段：接口对齐
- action: FE 与 Backend 确认接口定义
- output: api-contract.md
- review: true
- gate: 接口文档已双方确认

## 阶段：编码实施
- action: FE 基于接口文档开发
- output: implementation-log.md
- review: false
```

### 阶段字段

| 字段 | 必填 | 说明 |
|------|------|------|
| `action` | 是 | 该阶段做什么 |
| `output` | 否 | 产出文件名，写入 Item 目录 |
| `review` | 否 | 是否需要用户确认才推进，默认 false |
| `gate` | 否 | 门禁条件，不满足则阻止推进 |

## 注册机制

orchestrator 第七步分派流程时：先扫描 `.feflow/workflows/` 下所有 `.md`，读取 frontmatter `name`，有匹配则优先使用，无匹配回退内置 flow skill。

匹配规则：按 frontmatter `name` 声明，或按文件名自动匹配（`feature.md` → FEAT，`bugfix.md` → BUG）。

## 继承机制

声明 `extends` 时继承父流程全部阶段，只需定义差异部分：

- **覆盖** — 阶段名相同时替换整个定义
- **新增** — 阶段名不存在时追加到末尾
- **删除** — 阶段标记 `skip: true` 时跳过
- **未声明** — 原样继承

## 错误处理

| 场景 | 处理 |
|------|------|
| frontmatter 缺少 `name` | 跳过该文件，警告格式不完整 |
| `extends` 指向不存在的流程 | 报错，不回退 |
| 阶段缺少 `action` | 警告并跳过该阶段 |
| 同名文件重复 | 按修改时间取最新 |
