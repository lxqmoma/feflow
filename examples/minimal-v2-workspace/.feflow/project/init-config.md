---
workspace_shape: single-app
governance_mode: risk-driven
approval_policy: high-risk-only
high_risk_modules:
  - auth
  - payment
ai_restrictions:
  - production secrets
  - irreversible data operations
initialized_at: 2026-04-13T00:00:00+08:00
initialized_by: project-init
---

# init-config

这是一个最小 v2 工作区配置样例。

只保留治理真正需要的字段：

- 工作区形态
- 风险治理偏好
- 高风险区域
- AI 禁区
- 初始化元信息
