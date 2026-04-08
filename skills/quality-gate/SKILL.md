---
name: quality-gate
description: 在流程关键节点执行门禁检查
---

# Quality Gate — 流程门禁检查

在 Item 流转的关键节点执行准入检查，确保每个阶段的前置条件已满足。
全部通过返回 PASS，有未通过项则列出条件并阻止推进。

---

## Gate 1: 进入编码前

在开始编码实施之前，必须逐项确认以下条件：

### 检查清单

1. **项目已初始化** — `.feflow/` 目录存在且 `project/init-config.md` 配置完整
2. **Item 已创建** — `.feflow/items/` 下存在当前 Item 文件，包含标题、描述、级别
3. **记忆已加载** — `.feflow/memory/` 已读取，相关历史决策和团队约定已纳入上下文
4. **仓库已扫描** — 已执行 repo-scan，技术栈、目录结构、关键文件已识别
5. **需求已评审（L2+）** — Level 2 及以上的 Item 必须有 `requirement-brief.md`，且验收标准明确
6. **开发计划已评审（L2+）** — Level 2 及以上的 Item 必须有 `dev-plan.md`，且包含历史问题对照
7. **验收标准已明确** — Item 的验收标准为可检验的条目（非模糊描述），至少包含一条

### 执行逻辑

```
for each check in gate_1_checks:
    if check.passes:
        record ✅
    else:
        record ❌ + 未满足原因
if all checks pass:
    return PASS — 可以进入编码
else:
    return BLOCKED — 列出所有未通过项，阻止进入编码阶段
```

---

## Gate 2: 进入发布前

在提交代码或准备发布之前，必须逐项确认以下条件：

### 检查清单

1. **实施记录已更新** — `implementation-log.md` 已记录本次改动的关键决策和实际方案
2. **测试报告已产出（L2+）** — Level 2 及以上的 Item 必须有 `test-report.md`，覆盖验收标准中的每一条
3. **Commit 包含 Item ID** — 所有相关 commit message 中包含 Item 标识（如 `[ITEM-xxx]`）
4. **分支包含 Item ID** — 分支名中包含 Item 标识或可关联到对应 Item
5. **代码变更与计划一致** — 实际改动文件范围与 `dev-plan.md` 中声明的范围基本一致，无重大偏差
6. **构建通过** — 项目可正常构建，无 TypeScript 类型错误、lint 错误

### 执行逻辑

```
for each check in gate_2_checks:
    if check.passes:
        record ✅
    else:
        record ❌ + 未满足原因
if all checks pass:
    return PASS — 可以进入发布
else:
    return BLOCKED — 列出所有未通过项，阻止发布
```

---

## Gate 3: 特殊门禁

针对高风险场景的额外检查，在常规 Gate 之外触发：

### 3.1 Auth/Payment 安全专项检查

当改动涉及认证（auth）、授权（permission）、支付（payment）相关模块时自动触发：

- [ ] 敏感数据是否有泄露风险（token、密钥、用户信息）
- [ ] 权限校验是否在服务端执行（非仅前端）
- [ ] 支付金额、订单状态是否有篡改防护
- [ ] 错误信息是否暴露内部实现细节
- [ ] 日志中是否脱敏处理敏感字段
- [ ] 是否存在越权访问路径

### 3.2 公共组件影响范围评估

当改动涉及公共组件、公共工具函数、公共样式时自动触发：

- [ ] 列出所有使用该组件/函数的页面或模块
- [ ] 评估 Props/API 变更的向后兼容性
- [ ] 确认是否需要同步修改调用方
- [ ] 确认是否影响已有单元测试或 E2E 测试
- [ ] 评估是否需要版本升级或迁移指南

### 3.3 CI/CD 回滚方案

当改动涉及构建配置、部署脚本、环境变量、CI pipeline 时自动触发：

- [ ] 回滚方式已明确（回退版本号/revert commit/配置回滚）
- [ ] 回滚操作已验证可执行
- [ ] 回滚影响范围已评估
- [ ] 是否需要数据迁移回退
- [ ] 监控告警是否已配置

---

## 输出格式

门禁检查结果按以下格式输出：

```
## Gate {N} 检查结果: {PASS / BLOCKED}

✅ 项目已初始化
✅ Item 已创建
❌ 需求已评审（L2+）— 缺少 requirement-brief.md
✅ 仓库已扫描
❌ 验收标准已明确 — 当前验收标准为模糊描述，需改为可检验条目

---
结果: BLOCKED
未通过项: 2
需完成以上 ❌ 项后方可推进
```

当所有项通过时：

```
## Gate {N} 检查结果: PASS

✅ 项目已初始化
✅ Item 已创建
✅ 需求已评审（L2+）
✅ 仓库已扫描
✅ 验收标准已明确

---
结果: PASS
全部通过，可以进入下一阶段
```

---

## 例外规则

以下情况可跳过部分门禁：

### HOTFIX 快速通道

当 Item 类型为 HOTFIX 时：
- **跳过** Gate 1 中的"需求已评审"和"开发计划已评审"
- **保留** 其他所有检查项
- 在输出中标注 `⚡ HOTFIX 模式 — 已跳过 requirement/plan 门禁`

### 用户显式批准

当用户明确表示跳过某项检查时：
- 记录用户的跳过指令和原因
- 在输出中标注 `⚠️ 用户批准跳过: {检查项} — 原因: {用户说明}`
- 将跳过记录写入 Item 的 evidence 中，确保可追溯
- 不可跳过 Gate 3 中的安全专项检查（auth/payment），除非用户二次确认

---

## 调用方式

此 skill 由 orchestrator 在 Item 状态流转时自动调用，也可手动触发：

- 进入编码前：orchestrator 自动执行 Gate 1
- 进入发布前：orchestrator 自动执行 Gate 2
- 涉及特殊模块：orchestrator 根据改动范围自动触发 Gate 3 的对应检查
- 手动检查：用户可随时要求执行任意 Gate
