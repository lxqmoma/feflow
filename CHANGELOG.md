# Changelog

## [0.2.0] - 2026-04-13

### Changed

- 明确 `feflow` 的层级定位：建立在 `superpowers` 之上的前端专业化治理层，而不是并行竞争的通用流程引擎
- SessionStart hook 改为注入 `frontend-harness` 运行时契约，而不是只注入状态描述
- `orchestrator` 明确采用 “一个可见 owner + 多个隐藏专业视角” 的前端团队模型

### Added

- `runtime/frontend-harness.md` 作为前端专业层的启动契约
- 分层架构说明：Host tools / Superpowers / feflow

### Fixed

- 减少与 `superpowers` 的控制面冲突
- 抑制把专业视角误用成显式流程 handoff 的倾向

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
