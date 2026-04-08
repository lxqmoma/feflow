---
name: flow-feature
description: 新功能开发流程。当 orchestrator 识别任务类型为 FEAT 时调用（V1 中也复用于 MOD/UI/DESIGN/CHANGE 等类型）。按阶段推进：需求理解→评审→开发计划→评审→实施→测试→发布。
---

# flow-feature — 新功能开发流程

当 orchestrator 将任务分类为 FEAT（V1 中也复用于 MOD / UI / DESIGN / CHANGE / REFACTOR / TEST / CICD / DEBT）时，按本流程推进。

## 前置条件

- feflow 已初始化（`.feflow/` 目录存在且 `init-config.md` 配置完整）
- orchestrator 已完成任务分类并生成 Item（包含唯一 ID，如 `FEAT-001`）
- memory-load 已执行

## 复杂度等级定义

| 等级 | 判断标准 | 典型场景 |
|------|---------|---------|
| L1 | 单文件，无跨模块影响 | 改文案、调样式、加工具函数 |
| L2 | 多文件联动，涉及组件/接口/状态 | 新页面、对接接口、重构组件 |
| L3 | 跨模块/跨系统，架构决策 | 新框架、全局重构、SSR 改造 |

**产出文件路径约定**：所有产出文件存放在 `.feflow/items/{ITEM-ID}/` 下，后续各阶段用相对路径简写。

---

## 阶段 1：需求理解

**目标**：将用户输入转化为结构化需求简报。

1. 读取用户输入，调用 memory-load 获取项目上下文
2. **强制代码调研（不可跳过）**：
   - 提取核心名词，用 Grep 搜索整个项目，用 Glob 扫描相关文件类型
   - Read 搜索到的文件，理解现有实现
   - **声称"不存在"时必须展示搜索证据**（关键词、目录、结果），否则视为流程违规
3. L1 自行分析；L2/L3 调用 PM agent
4. 产出：`role-pm/requirement-brief.md`（使用模板 `templates/requirement-brief.md`）

| 维度 | L1 | L2 | L3 |
|------|-----|-----|-----|
| 分析方式 | 自行分析 | PM agent | PM + architect agent |
| 验收标准 | 1-2 条 | 3-5 条 | 5+ 条，含非功能性 |
| 风险分析 | 可省略 | 必须列出 | 列出 + 缓解方案 |

---

## 阶段 2：需求评审

**所有级别必须经用户确认。AI 不可自行跳过评审或降级任务级别。**

- **通过** → `requirement_approved`，进入阶段 3
- **补充** → 修订后重新呈现
- **退回** → `requirement_rejected`，回到阶段 1

呈现详细度：L1 一句话确认 / L2 摘要+验收标准 / L3 全文+架构影响。

---

## 阶段 3：开发计划

1. L1 自行制定；L2 调用 FE agent；L3 调用 FE + architect agent
2. **深度代码调研（不可跳过）**：搜索相关代码，确认复用/修改/新建范围，引用的文件路径必须经 Glob/Read 验证
3. **必须包含"历史问题对照"**：查询 memory 中相关历史问题和踩坑记录，标注规避措施
4. 产出：`role-fe/dev-plan.md`（使用模板 `templates/dev-plan.md`）

| 维度 | L1 | L2 | L3 |
|------|-----|-----|-----|
| 步骤粒度 | 1-3 步 | 3-8 步 | 8+ 步，按阶段拆分 |
| 历史问题对照 | 快速扫描 | 必须列出 | 深度关联分析 |
| 测试策略 | 可简化 | 必须包含 | 含性能/兼容性考量 |

---

## 阶段 4：计划评审

**所有级别必须经用户确认才能进入实施。禁止未确认就写代码。**

- **通过** → `plan_approved`，进入阶段 5
- **修改** → 调整后重新呈现
- **退回** → 回到阶段 3

呈现详细度：L1 具体文件和改动点 / L2 步骤合理性 / L3 架构影响+逐项确认。

---

## 阶段 5：实施

1. **门禁检查**：调用 quality-gate skill 确认前置条件
2. **分支创建**：`feature/{ITEM-ID}-{slug}`
3. **TDD 建议**：superpowers 可用时建议使用 TDD 工作流
4. **编码实施**：遵循编码戒律（从 `.feflow/memory/project/coding-doctrine.md` 加载），按 `dev-plan.md` 顺序推进
5. **持续记录**：产出并更新 `implementation-log.md`（使用模板 `templates/implementation-log.md`）

| 维度 | L1 | L2 | L3 |
|------|-----|-----|-----|
| 门禁检查 | 基础 | 完整 | 完整 + 架构合规 |
| TDD | 可选 | 建议 | 强烈建议 |
| 代码审查 | 可省略 | 建议 code-review | 必须 code-review |

---

## 阶段 6：测试验证

1. L1 自行验证；L2/L3 调用 QA agent
2. 运行测试套件（lint / type-check / unit test / e2e）
3. 针对验收标准逐项验证
4. **历史回归检查**：查询 memory 中相关 bug 记录，确认未回归
5. 产出：`role-qa/test-report.md`（使用模板 `templates/test-report.md`）

| 维度 | L1 | L2 | L3 |
|------|-----|-----|-----|
| 测试范围 | lint + 手动 | lint + type-check + unit | 全部 + e2e + 性能 |
| 历史回归 | 快速扫描 | 必须检查 | 深度检查 + 相邻模块 |

---

## 阶段 7：发布

1. 确认测试全部通过
2. 创建 PR（标题：`feat({scope}): {描述} [{ITEM-ID}]`，描述含需求摘要/实施概要/测试结果/影响范围）
3. 产出：`release-note.md`（使用模板 `templates/release-note.md`）

| 维度 | L1 | L2 | L3 |
|------|-----|-----|-----|
| PR | 可直接合并 | 必须 PR | PR + 指定 reviewer |
| 合并方式 | 直接合并 | squash merge | 视情况选择 |

---

## 阶段 8：收尾

调用 memory-update skill 写入项目记忆（模块/接口变更、关键决策、踩坑点），更新 Item 状态为 `completed`，清理临时文件。

L1 简要记录 / L2 完整记录+踩坑点 / L3 完整记录+架构决策归档+最佳实践。

---

## 状态流转

```
requirement_draft → requirement_approved → plan_draft → plan_approved → implementing → testing → releasing → completed
```

任意阶段可退回前置阶段，退回原因记录在 `implementation-log.md`。

## 异常处理

- **用户未响应评审**：L2 提醒一次后等待，L3 必须等待明确确认
- **需求理解偏差**：暂停实施，回到阶段 1
- **测试不通过**：回到阶段 5 修复后重新测试
- **依赖阻塞**：记录至 `implementation-log.md`，通知用户
