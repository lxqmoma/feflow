[中文](./README.md)

# feflow

Frontend development collaboration engine -- an AI coding assistant plugin that provides end-to-end development workflow management for frontend projects.

Currently supports [Claude Code](https://docs.anthropic.com/en/docs/claude-code).

## Highlights

- **Full lifecycle coverage** -- Requirements, design, development, testing, release: 10 task flows out of the box
- **Multi-role collaboration** -- 7 professional roles (PM/Designer/FE/Backend/QA/Reviewer/Researcher), dispatched on demand by the orchestrator
- **Project memory** -- 5-layer memory system (permanent/module/mid-term/event/short-term), persisted across sessions
- **Repository awareness** -- 4-layer scanning to auto-detect tech stack, directory structure, and key configurations
- **Evidence-driven** -- Test results, review records, and build artifacts serve as completion proof; no self-declarations
- **Auto stack detection** -- Detects project tech stack and auto-installs corresponding skills
- **Legacy support** -- Dedicated legacy overlay mode for tackling legacy codebases methodically
- **Backfill mechanism** -- Supports retroactive evidence and context supplementation; no forced linear process

## Quick Start

### Installation

```bash
claude install-plugin https://github.com/lxqmoma/feflow
```

### Initialization

Run in your project root:

```bash
/init
```

This creates a `.feflow/` directory in your project for storing work items, memory, and configuration.

### Usage

```bash
# Create a task and start workflow
/task Implement user login page

# View current work items
/task list

# Scan repository status
/scan

# View project memory
/memory
```

## Core Concepts

| Concept | Description |
|---------|-------------|
| **Item** | The smallest unit of development activity, with unique ID, state, context, and deliverables |
| **Flow** | State transition path for an Item, defining phases, entry conditions, and checkpoints |
| **Memory** | Project-level persistent context, storing decisions, conventions, and lessons across sessions |
| **Evidence** | Objective proof of completion quality (test results, review records, etc.) |
| **Gate** | Phase entry/exit checks ensuring process quality control |
| **Role** | Professional role agent, dispatched by the orchestrator based on task type |

## Plugin Structure

```
feflow/
├── skills/            # 21 skill definitions
│   ├── orchestrator/      # Task orchestration & dispatch
│   ├── flow-feature/      # Feature development flow
│   ├── flow-bugfix/       # Bug fix flow
│   ├── flow-hotfix/       # Hotfix flow
│   ├── flow-modification/ # Feature modification flow
│   ├── flow-ui-optimize/  # UI optimization flow
│   ├── flow-design/       # Design task flow
│   ├── flow-change-request/ # Change request flow
│   ├── flow-cicd/         # CI/CD flow
│   ├── flow-refactor/     # Refactoring flow
│   ├── flow-test-task/    # Test task flow
│   ├── flow-legacy/       # Legacy overlay mode
│   ├── repo-scan/         # Repository scanning
│   ├── stack-detect/      # Tech stack detection
│   ├── topology-detect/   # Topology detection
│   ├── memory-load/       # Memory loading
│   ├── memory-update/     # Memory updating
│   ├── project-init/      # Project initialization
│   ├── quality-gate/      # Quality gate
│   ├── evidence-ledger/   # Evidence ledger
│   └── backfill/          # Evidence backfill
├── agents/            # 7 role agents
│   ├── pm.md              # Product / Requirements
│   ├── designer.md        # UI/UX Design
│   ├── fe.md              # Frontend Implementation
│   ├── backend.md         # Backend Collaboration
│   ├── qa.md              # Testing / QA
│   ├── reviewer.md        # Architecture Guardian
│   └── researcher.md      # Deep Research
├── commands/          # 4 commands
│   ├── init.md            # /init -- Initialize workspace
│   ├── task.md            # /task -- Create/view work items
│   ├── scan.md            # /scan -- Scan repository
│   └── memory.md          # /memory -- Manage memory
├── templates/         # 12 document templates
├── hooks/             # Lifecycle hooks
├── package.json
├── CLAUDE.md
└── LICENSE
```

## Commands

| Command | Description | Usage |
|---------|-------------|-------|
| `/init` | Initialize feflow workspace | `/init` |
| `/task` | Create work item or view list | `/task Implement login page` or `/task list` |
| `/scan` | Scan repository status | `/scan` |
| `/memory` | View/manage project memory | `/memory` or `/memory add` |

## Flow Types

| Flow | Use Case | Skill |
|------|----------|-------|
| Feature | New feature development | `flow-feature` |
| Modification | Existing feature changes | `flow-modification` |
| Bugfix | Bug fixes | `flow-bugfix` |
| Hotfix | Urgent production fixes | `flow-hotfix` |
| UI Optimize | UI/interaction improvements | `flow-ui-optimize` |
| Design | Design-related tasks | `flow-design` |
| Change Request | Change requests | `flow-change-request` |
| CI/CD | Build and deployment tasks | `flow-cicd` |
| Refactor | Code refactoring | `flow-refactor` |
| Test Task | Testing tasks | `flow-test-task` |
| Legacy (overlay) | Legacy codebase work, stackable on any flow | `flow-legacy` |

## Roles

| Role | Responsibility | When Dispatched |
|------|----------------|-----------------|
| **PM** | Requirements analysis, documentation, ambiguity detection, acceptance criteria | Requirements phase |
| **Designer** | UI visual design, UX interaction design | UI/DESIGN tasks, L3 tasks |
| **FE** | Technical design, code change planning, module impact analysis, implementation | Development phase |
| **Backend** | API integration, interface protocols, data structure adjustments | Cross-stack collaboration tasks |
| **QA** | Test scope, regression checklist, edge cases, cross-platform verification | Testing phase |
| **Reviewer** | Architecture guardian, invariant checks, preventing historical mistake recurrence | Code review, L3 tasks |
| **Researcher** | Deep code reading, reference research, competitive analysis, commit history | On demand |

## Relationship with Superpowers

feflow is a domain plugin within the [Superpowers](https://github.com/jasonm/superpowers) ecosystem. They serve complementary purposes:

| Dimension | Superpowers | feflow |
|-----------|-------------|--------|
| Positioning | General development workflow | Development collaboration engine |
| Capabilities | Brainstorming, planning, TDD, code review | Item/Flow/Memory/Evidence management |
| Use Cases | General development tasks | Requirements management, release planning, deployment coordination |

Integration: feflow hooks inject domain logic at key points in Superpowers workflows. Skills and agents from both systems can call each other.

## Methodology

**Core principle: Get it right** -- Complete every development activity correctly, completely, and traceably.

Six design tenets:

1. **Stay flexible** -- Tiered processes (L1/L2/L3), no one-size-fits-all
2. **Stay controlled** -- Trackable, verifiable, recoverable
3. **Stay remembered** -- Externalized project memory, persistent across sessions
4. **Stay handoff-ready** -- AI output that humans can pick up
5. **Stay pragmatic** -- Legacy and messy codebases are first-class citizens
6. **Stay provable** -- Evidence-driven, auditable

## Roadmap

### V3 Plans

- [x] Multi-Item dependency and parallel orchestration
- [x] Memory auto-decay and archival strategies
- [x] Custom flow templates (user-defined Flows)
- [x] Dashboard: Item status panoramic view
- [x] Evidence chain visualization

### Multi-Platform Support

- [x] Cursor adapter
- [x] Windsurf adapter
- [x] Other AI coding assistant adapters (generic AGENTS.md)

## Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feat/your-feature`
3. Commit changes: `git commit -m "feat: your change description"`
4. Push the branch: `git push origin feat/your-feature`
5. Open a Pull Request

Commit format: `type(scope): description`. Types: feat / fix / refactor / docs / test / chore.

## License

[MIT](./LICENSE)
