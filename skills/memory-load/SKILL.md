---
name: memory-load
description: 每次任务启动时使用。按当前任务类型、涉及模块和风险级别，从 .feflow/memory/ 中检索相关历史经验，产出记忆摘要。
---

# memory-load: 任务前记忆加载

## 触发时机

由 orchestrator 在创建 Item 后、分配执行 agent 前调用。
目的是将项目积累的历史经验注入当前任务上下文，避免重复踩坑。

## 输入

orchestrator 传入当前 Item 的基本信息：
`item_id` / `item_type`(feat/fix/refactor/hotfix/chore) / `modules`(模块列表) / `risk_level`(low/medium/high/critical) / `title` / `description`(可选)

## 加载步骤

### 第一步：读取全局不变量

读取 `.feflow/memory/project/invariants.md`，项目级硬性约束，任何任务都必须遵守。若文件不存在，跳过。

### 第二步：读取 AI 编码戒律

读取 `.feflow/memory/project/coding-doctrine.md`，团队编码规范和 AI 协作约定。若文件不存在，跳过。

### 第三步：按模块查找模块记忆

遍历 `.feflow/memory/modules/`，匹配规则：
1. 文件名包含模块名（如 `auth.md` 匹配 `auth`）
2. frontmatter `scope` 包含目标模块名
3. 仅加载 `status: active` 的记忆条目

提取每条记忆的场景、问题、根因、规避方式。

### 第四步：查找相关事件记忆

扫描 `.feflow/memory/incidents/` 和 `.feflow/memory/patterns/`。

匹配条件（任一命中）：scope 包含当前模块 / type 与任务类型相同 / 内容含模块名关键词。

`risk_level` 为 high 或 critical 时放宽匹配：额外加载所有 `type: incident` 和 `scope: global` 的记忆。

### 第五步：查找历史相似 Item

扫描 `.feflow/items/`，相似判定（满足两项及以上）：相同模块 / 相同类型 / 标题描述含相同关键词。

提取：实际耗时与预估偏差、未预见问题、最终方案变更。

## 筛选条件

1. **状态过滤** — 仅 `status: active`，跳过 `archived` / `superseded`
2. **scope 匹配** — 与当前模块有交集，或 scope 为 `global`
3. **内容相关性** — 含当前模块名、技术栈名或业务术语
4. **去重** — 同一 `memory_id` 仅保留一次

## 产出格式

生成 `00-memory-brief.md`（前缀 `00-` 确保排在最前），摘要控制在 20 行以内。核心结构：

```markdown
---
item_id: {id}
generated_at: {ISO 8601}
memory_count: {N}
risk_level: {level}
modules: [...]
---

# 记忆摘要

## 全局不变量
- **[INV-xxx]** {约束描述}

## 编码戒律
- **[DOC-xxx]** {规范描述}

## 模块记忆
### {模块名}
- **[MEM-xxx]** {标题} — 场景/问题/根因/规避方式

## 历史事件
- **[INC-xxx]** {日期} {事件标题} — 影响/根因/教训

## 本次必须额外检查
1. {检查项}
```

记忆库为空时输出最小化摘要：标注「项目刚初始化，暂无历史记忆记录」，各分区标注「暂无记录」。

## 执行约束

1. memory-load 是只读操作，不修改任何记忆文件
2. 文件解析错误时跳过并标注警告
3. 单次加载上限 30 条，超出按优先级截断：全局不变量 > 编码戒律 > 事件记忆(时间倒序) > 模块记忆(匹配度) > 历史 Item(最多 5 条)
4. 加载耗时不超过 5 秒，记忆库文件过多时优先加载 scope 精确匹配的文件

## 与其他 skill 的关系

- **上游**：orchestrator 创建 Item 后调用
- **下游**：执行 agent 读取 `00-memory-brief.md` 开始工作
- **对称**：memory-update 在任务后写入新记忆，供后续 memory-load 检索
