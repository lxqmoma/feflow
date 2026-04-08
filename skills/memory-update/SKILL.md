---
name: memory-update
description: 任务结束后使用。评估本次任务是否产生了值得沉淀的经验，按升级策略将经验写入对应层级的记忆文件。
---

# memory-update: 任务后经验提炼

## 触发时机

由 orchestrator 在任务完成后、Item 状态流转为 `done` 时调用。

## 输入

orchestrator 传入当前 Item 完整信息：
`item_id` / `item_type` / `modules` / `risk_level` / `title` / `description` / `evidence`(测试结果、审查记录等) / `duration` / `review_comments` / `rework_count`

## 评估清单

对本次任务进行 7 项自查，任一为是则进入升级策略判定：

1. **新坑发现** — 遇到未记录的非预期阻塞、隐含约束、API 行为偏差
2. **复发问题** — `00-memory-brief.md` 已提及但仍踩坑，说明现有规避方式不够有效
3. **评审反馈** — 收到通用价值的反馈（架构/安全/性能等全局性问题、API 错误用法纠正）
4. **返工发生** — `rework_count > 0` 且非需求变更导致（需求偏差/方案不合理/遗漏边界）
5. **方案否决** — 初始方案被否定且原因有参考价值
6. **设计偏差** — 实现与设计文档假设不符，需回溯更新
7. **流程绕过** — 因紧迫跳过测试/审查，或使用临时方案，需后续补齐

7 项全否则不写入记忆库。

## 升级策略

| Level | 条件 | 处理 | 写入位置 |
|-------|------|------|----------|
| 1 | 新坑首次出现，影响有限，不涉及安全/数据 | 仅在 Item 的 `lessons_learned` 留痕，不写记忆库 | Item 文件 |
| 2 | 相同问题第二次出现 | 写入模块记忆，追加不修改 | `.feflow/memory/modules/{module}.md`；跨模块写入 `patterns/` |
| 3 | 涉及安全/数据完整性/资金/线上事故/critical 任务 | 升格为不变量，同时在模块记忆添加引用 | `.feflow/memory/project/invariants.md` |
| 4 | 同一问题出现三次及以上 | 标记 `needs_automation`，给出自动化建议（测试/lint/CI/模板） | 更新对应记忆条目 |

## 记忆写入格式

每条记忆的 frontmatter 必含字段：

| 字段 | 说明 |
|------|------|
| `memory_id` | `MEM-{模块首字母大写}{3位序号}`，如 `MEM-A012`。新 ID 从目标文件最大序号 +1 生成 |
| `type` | `pitfall` / `pattern` / `incident` / `convention` / `invariant` |
| `scope` | 模块名列表，跨模块用 `["global"]` |
| `created_at` | ISO 8601 带时区 |
| `status` | `active` / `archived` / `superseded` / `needs_automation` |
| `source_type` | `new_discovery` / `recurrence` / `review_feedback` / `rework` / `plan_rejection` / `design_deviation` / `process_bypass` |
| `source_refs` | 关联 Item ID 列表 |
| `created_by` | 固定值 `memory-update` |

正文结构：标题 → 场景 → 问题 → 根因 → 规避方式 → 来源 Item → 记录时间

## 输出格式

有新经验时输出：新增记忆汇总表（memory_id/类型/范围/层级/写入位置）+ 每条记忆详情 + 建议后续操作。

无新经验时输出：7 项评估结果（全否）+ 「无需更新记忆库」。

## 执行约束

1. 只追加不修改已有记忆条目
2. 写入前必须读取目标文件已有内容，避免覆盖
3. 目标文件不存在时创建（含标准文件头）
4. 每次最多写入 5 条，优先级：Level 3 > Level 4 > Level 2
5. 记忆必须具备可操作性 —— "注意 XXX" 不是有效规避方式，需具体到做什么、怎么做
6. 不确定是否构成经验时，宁可不写入

## 与其他 skill 的关系

- **上游**：orchestrator 在 Item 完成后调用
- **下游**：写入的记忆供后续 memory-load 检索
- **对称**：memory-load 读取 + memory-update 写入 = 完整经验循环
- **关联**：quality-gate 检查结果可作为评估输入
