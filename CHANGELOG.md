# Changelog

## [0.1.0] - 2026-04-08

### Added

- **总控层**: orchestrator 任务编排与调度
- **初始化层**: project-init / repo-scan / stack-detect / topology-detect
- **流程层**: 10 种任务流程（feature / modification / bugfix / hotfix / ui-optimize / design / change-request / cicd / refactor / test-task）+ legacy 叠加模式
- **记忆层**: memory-load / memory-update / memory-decay
- **质量层**: quality-gate / evidence-ledger / evidence-chain / backfill
- **编排层**: item-orchestration（多 Item 依赖）/ custom-flow（自定义流程）/ dashboard（仪表盘）
- **角色**: 7 个 agent（PM / Designer / FE / Backend / QA / Reviewer / Researcher）
- **命令**: /feflow:init / /feflow:task / /feflow:scan / /feflow:memory
- **模板**: 12 个文档模板
- **适配器**: Cursor / Windsurf / 通用 AGENTS.md
- **基础设施**: SessionStart hook / marketplace 配置 / MIT LICENSE
