---
name: custom-flow
description: 流程模板自定义。v2 中自定义 flow 应被视为内部执行配方，继承 Assist/Delivery/Incident 与风险驱动原则，而不是重新制造用户可见的阶段广播。
---

# custom-flow：v2 自定义执行配方

允许用户在 `.feflow/workflows/` 下定义自己的 flow，用来补充某类任务的内部执行约束。

这里的 flow 本质上是 **内部执行配方**，不是一串必须对用户逐段播报的阶段。

## 存放路径

`.feflow/workflows/{flow-name}.md`

- 小写英文 + 连字符
- 与内置 flow 同名时视为覆盖

## 设计原则

自定义 flow 应遵守：

1. 风险驱动，而不是任务一来就重流程
2. 默认隐藏内部控制平面
3. 只有真正会改变方向或风险姿态的点，才值得暂停确认
4. 优先补充专用约束，而不是复制一整套大模板

## Flow 定义格式

Markdown + frontmatter。

正文中的每个二级标题表示一个 **内部执行切片**。为了兼容旧写法，标题里仍可写“阶段”，但语义上不应默认暴露给用户。

```yaml
---
name: api-integration
description: 前后端 API 对接专用 flow
extends: flow-feature
roles: [FE, Backend]
---
```

```markdown
## 切片：接口对齐
- action: FE 与 Backend 确认契约与兼容边界
- artifact: api-contract.md
- pause_on: 出现破坏性接口分歧
- expose_to_user: false

## 切片：联调验证
- action: 校对 mock、真实响应和错误路径
- artifact: test-evidence.md
- pause_on: 鉴权或数据安全风险无法确认
```

## 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `action` | 是 | 当前切片要完成的事实性动作 |
| `artifact` | 否 | 若需要持久化，可写入的产物文件 |
| `pause_on` | 否 | 只有遇到这些情况才应停下来确认 |
| `gate` | 否 | 内部判断条件，可静默通过 |
| `expose_to_user` | 否 | 是否值得把该切片显式告诉用户，默认 `false` |
| `skip` | 否 | 为 `true` 时跳过该切片 |

`pause_on` 代表真正的风险停顿点，不等于“到这里就问一次”。

## 注册机制

当 orchestrator 已判定任务适合某类 flow 时，可优先检查 `.feflow/workflows/` 是否有匹配配方。

匹配规则：

- frontmatter `name`
- 文件名兜底匹配

## 继承机制

声明 `extends` 时继承父 flow 的全部执行切片，只需定义差异部分：

- **覆盖**：同名切片替换父定义
- **新增**：父 flow 不存在该切片时追加
- **删除**：切片设置 `skip: true`
- **未声明**：沿用父定义

## 用户可见性约束

即使某个自定义 flow 很细，也不意味着用户要看到每个切片。

默认只向用户暴露：

- 当前在做什么
- 已发现什么
- 下一步是什么
- 为什么必须暂停

不要把 flow 自身变成产品界面。

## 错误处理

| 场景 | 处理 |
|------|------|
| frontmatter 缺少 `name` | 跳过该文件，警告格式不完整 |
| `extends` 指向不存在的 flow | 报错，不回退 |
| 切片缺少 `action` | 警告并跳过该切片 |
| 同名文件重复 | 按修改时间取最新 |
