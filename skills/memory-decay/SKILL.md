---
name: memory-decay
description: 记忆自动衰减与归档策略。定期评估记忆有效性，自动降级或归档过时记忆，保持记忆库精简可靠。
---

# memory-decay: 记忆自动衰减与归档

## 触发条件

- `project-init` 时执行一次全量检查
- 用户执行 `/feflow:memory decay` 手动触发

## 前置条件

`.feflow/memory/` 目录存在，且包含至少一个记忆文件。

## 衰减规则

基于 `last_verified_at` 字段（缺失时回退到 `created_at`）判定衰减阶段：

| 阶段 | 条件 | 处理 |
|------|------|------|
| `active` | 6 个月内验证过 | 正常状态，无需处理 |
| `stale` | 超过 6 个月未验证 | 标记为 `stale`，仍参与检索，但排序权重降低 |
| `needs_review` | 超过 12 个月未验证 | 自动降级，输出待审清单 |
| 自动归档 | `needs_review` 超过 30 天无人处理 | 移入归档目录 |

执行时扫描 `.feflow/memory/modules/`、`patterns/`、`incidents/` 下所有 `.md` 文件的 frontmatter。

## 归档机制

1. 归档的记忆移入 `.feflow/memory/archived/`，按原目录结构保留子目录
2. 归档文件的 frontmatter 追加 `archived_at`（ISO 8601）和 `archived_reason`
3. 归档后的记忆不再被 `memory-load` 检索，但保留可查
4. 归档目录的文件不参与衰减扫描

## 重新激活

归档的记忆可被手动重新激活：

1. 将文件从 `.feflow/memory/archived/` 移回原目录
2. 更新 `status` 为 `active`
3. 更新 `last_verified_at` 为当前时间
4. 移除 `archived_at` 和 `archived_reason` 字段

## 冲突检测

当新记忆（由 `memory-update` 写入）与已有记忆存在矛盾时：

1. 对比同 `scope` 下的记忆条目，检查结论是否相反或互斥
2. 矛盾的旧记忆标记为 `superseded`，frontmatter 追加 `superseded_by: {新 memory_id}`
3. `superseded` 状态的记忆不参与 `memory-load` 检索

## 健康度报告

统计记忆库各状态分布，输出健康度评估：

```
## 记忆库健康度报告

| 状态 | 数量 | 占比 |
|------|------|------|
| active | 23 | 57% |
| stale | 8 | 20% |
| needs_review | 5 | 13% |
| archived | 4 | 10% |

健康度: 良好（active 占比 > 50%）
待处理: 5 条 needs_review 记忆需人工确认

待审清单:
- [MEM-A003] auth 模块 token 刷新策略 — stale 190 天
- [MEM-B007] 支付回调幂等处理 — needs_review 35 天
```

健康度等级：优秀（active > 70%）/ 良好（> 50%）/ 需关注（> 30%）/ 告警（<= 30%）

## 执行约束

1. 衰减操作仅修改 frontmatter 的 `status` 相关字段，不改动记忆正文
2. 每次归档前输出待归档清单，由用户确认后执行（`project-init` 时自动确认）
3. `invariants.md` 和 `coding-doctrine.md` 不参与衰减，始终保持 active
4. 批量操作上限 20 条/次，超出时分批处理

## 与其他 skill 的关系

- **上游**：project-init 在会话启动时调用
- **协作**：memory-update 写入新记忆时触发冲突检测
- **下游**：memory-load 根据 status 筛选可用记忆
