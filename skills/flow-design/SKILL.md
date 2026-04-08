---
name: flow-design
description: 设计落地流程。设计稿还原或前端补设计。当有 Figma/设计稿时做还原对齐，无设计稿时由 designer agent 出方案。
---

# flow-design — 设计落地/前端补设计流程

当 orchestrator 将任务分类为 DESIGN 时，按本流程推进。

核心原则：**有稿还原，无稿补方案；方案基于项目已有风格，不凭空创作。** 必须调用 designer agent。

## 前置条件

- feflow 已初始化（`.feflow/` 目录存在且 `project/init-config.md` 配置完整）
- orchestrator 已完成任务分类并生成 Item（如 `DESIGN-001`）
- memory-load 已执行

复杂度等级定义同 flow-feature。分支命名：`design/{ITEM-ID}-{slug}`。
**产出文件路径约定**：所有产出文件存放在 `.feflow/items/{ITEM-ID}/` 下。

## 路径判定（进入流程时立即判断）

| 条件 | 路径 |
|------|------|
| 提供了设计稿（Figma 链接 / 截图 / 标注文件） | 路径 A — 设计稿还原 |
| 无设计稿，仅有功能描述或需求文档 | 路径 B — 前端补设计方案 |

---

## 路径 A：设计稿还原

### A1. 设计稿分析

1. **强制代码调研（不可跳过）**：用 Grep/Glob 搜索项目已有组件和设计系统 token，用 Read 读取相关文件。**声称"不存在"时必须展示搜索证据。**
2. 获取设计稿（Figma 链接用 Figma MCP 读取 / 截图直接分析 / 标注文件解析）
3. 提取：布局结构、色彩体系、字体规范、间距节奏、组件层级、交互说明
4. 与项目已有设计系统对照，标注可复用项和需新建项
5. 产出：`role-designer/design-analysis.md`

| 维度 | L1 | L2 | L3 |
|------|-----|-----|-----|
| 解析深度 | 核心元素 | 全部元素+token 映射 | 全部+设计系统扩展方案 |
| designer agent | 建议调用 | 必须调用 | 必须调用+设计系统审查 |

### A2. 组件拆分

将设计稿拆解为组件树，标注每个组件：复用已有 / 修改已有 / 新建。产出：`role-fe/component-breakdown.md`

### A3. 实施

参照 flow-feature 阶段 5，额外要求：优先使用已有组件和 token，标注还原偏差（意图不明确 / 技术限制 / 响应式差异）。

### A4. 走查对齐

调用 designer agent 对照设计稿走查：逐屏对比（布局 / 色彩 / 字体 / 间距）、交互验证（动效 / 过渡 / 状态切换）、多端检查（响应式 / 暗黑）。产出：`role-designer/design-review.md`，偏差项逐条标注处理方式（修复 / 接受 / 降级）。

---

## 路径 B：前端补设计方案

### B1. 约束收集

1. **强制代码调研（不可跳过）**：扫描项目已有页面 / 组件库 / 设计系统确定视觉基调。**声称"不存在"时必须展示搜索证据。**
2. 梳理已知输入材料（需求文档 / 原型 / 口头描述）
3. 明确设计约束（品牌规范 / 技术限制 / 时间预算）

### B2. 方案产出（必须调用 designer agent）

产出 `role-designer/design-proposal.md`（使用模板 `templates/design-proposal.md`），包含：已知输入材料、设计目标、方案 A/B（描述+适用场景+优劣）、推荐方案+理由、视觉原则（引用已有页面/组件）、交互原则。**必须基于项目已有风格，不凭空搞艺术创作。**

### B3. 方案评审

**所有级别必须经用户确认。AI 不可自行跳过评审。** 呈现方案 A/B 供用户选择。
通过 → B4 / 修改 → 回 B2 / 退回 → 回 B1。

### B4. 实施与走查

实施参照路径 A 的 A3，走查参照 A4。

---

## 后续阶段（两条路径汇合）

### 测试验证

运行测试套件（lint / type-check），视觉回归检查（多端 / 多主题），产出 `role-qa/test-report.md`。

### 收尾

1. 创建 PR（标题：`design({scope}): {描述} [{ITEM-ID}]`）
2. 调用 memory-update skill 写入项目记忆，记录：设计决策、token 变更、走查偏差处理
3. 更新 Item 状态为 `completed`

---

## 状态流转

```
# 路径 A: created → researching → plan_drafted → implementing → testing → completed
# 路径 B: created → researching → requirement_drafted → requirement_approved → implementing → testing → completed
```

任意阶段可退回前置阶段，退回原因记录在 `implementation-log.md`。

## 异常处理

- **设计稿不完整**：列出缺失项，询问用户补充或转入路径 B
- **设计稿与技术限制冲突**：记录冲突点，与用户确认降级方案
- **无设计稿且无参考**：基于项目现有风格最保守地补全，标注"前端自拟"
- **走查偏差超出容忍度**：回到实施阶段修复，不跳过走查
