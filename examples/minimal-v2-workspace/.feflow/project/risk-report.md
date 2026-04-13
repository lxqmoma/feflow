---
generated_by: repo-scan
generated_at: 2026-04-13T00:05:00+08:00
---

# risk-report

- `src/stores/search.ts` 为中风险区域：状态与页面交互双向耦合
- `src/router/index.ts` 为高风险区域：会影响页面导航和 query 同步
- 搜索页存在历史回归点：空关键词和 query 覆盖行为
