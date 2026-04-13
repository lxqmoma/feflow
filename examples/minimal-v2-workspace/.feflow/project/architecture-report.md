---
generated_by: repo-scan
generated_at: 2026-04-13T00:05:00+08:00
---

# architecture-report

## 主入口

- `src/main.ts`
- `src/router/index.ts`
- `src/stores/search.ts`

## 关键目录

- `src/pages/` — 页面入口
- `src/components/` — 共享组件
- `src/stores/` — 页面级和全局状态

## 风险提示

- 搜索页同时依赖 router query 与 store 状态
- 搜索交互有历史兼容逻辑，修改时要保留旧行为
