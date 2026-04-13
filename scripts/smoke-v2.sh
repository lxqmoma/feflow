#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

required_files=(
  "README.md"
  "README.en.md"
  "V2-ACCEPTANCE-SUITE.md"
  "DOGFOOD-ROUND-1-BASELINE.md"
  "DOGFOOD-ROUND-1-WORKSHEET.md"
  "DOGFOOD-GOLDEN-FIRST-REPLIES.md"
  "commands/assist.md"
  "commands/incident.md"
  "commands/init.md"
  "commands/memory.md"
  "commands/task.md"
  "commands/scan.md"
  "hooks/session-start/detect.sh"
  "skills/orchestrator/SKILL.md"
  "skills/quality-gate/SKILL.md"
  "examples/minimal-v2-workspace/README.md"
  "agents/backend.md"
  "agents/designer.md"
  "agents/fe.md"
  "agents/pm.md"
  "agents/qa.md"
  "agents/researcher.md"
  "agents/reviewer.md"
)

for file in "${required_files[@]}"; do
  if [[ ! -e "$file" ]]; then
    echo "missing required file: $file" >&2
    exit 1
  fi
done

if [[ ! -x "hooks/session-start/detect.sh" ]]; then
  echo "hook is not executable: hooks/session-start/detect.sh" >&2
  exit 1
fi

bash -n "hooks/session-start/detect.sh"

search_paths=(
  "README.md"
  "README.en.md"
  "CLAUDE.md"
  "agents"
  "adapters"
  "commands"
  "hooks"
  "skills"
  "templates"
)

banned_regex='已完成任务分类并生成 Item|feflow 已初始化|memory-load 已执行|项目已完成 feflow 初始化|未确认不可实施|所有级别必须经用户确认|4 个命令|4 commands|21 个技能|21 skills'

if command -v rg >/dev/null 2>&1; then
  if rg -n "$banned_regex" "${search_paths[@]}"; then
    echo "found banned legacy phrase(s)" >&2
    exit 1
  fi

else
  if grep -RInE "$banned_regex" "${search_paths[@]}"; then
    echo "found banned legacy phrase(s)" >&2
    exit 1
  fi
fi

if command -v rg >/dev/null 2>&1; then
  rg -q 'minimal|partial|full' "skills/evidence-chain/SKILL.md" || {
    echo "evidence-chain is missing risk-level evidence language" >&2
    exit 1
  }

  rg -q 'pause_on|expose_to_user' "skills/custom-flow/SKILL.md" || {
    echo "custom-flow is missing v2 execution-slice controls" >&2
    exit 1
  }

  rg -q '## First Reply Contract' "CLAUDE.md" || {
    echo "CLAUDE is missing first reply contract" >&2
    exit 1
  }

  rg -q 'chat commands.*shell commands' "CLAUDE.md" || {
    echo "CLAUDE is missing chat-command semantics" >&2
    exit 1
  }

  rg -q '## Harness Engineering|behave like a \*\*harness\*\*|behave like a harness' "CLAUDE.md" || {
    echo "CLAUDE is missing Harness Engineering guidance" >&2
    exit 1
  }

  rg -q 'First Reply Contract' "adapters/generic/AGENTS.md" || {
    echo "generic adapter is missing first reply contract" >&2
    exit 1
  }

  rg -q '首轮回复契约' "adapters/cursor/rules.md" "adapters/windsurf/rules.md" || {
    echo "host adapters are missing first reply contract guidance" >&2
    exit 1
  }

  rg -q 'Scenario `A0`|Scenario `G0`|Scenario `D1`|Scenario `D3`|Scenario `I4`' "DOGFOOD-ROUND-1-WORKSHEET.md" || {
    echo "dogfood worksheet is missing core scenarios" >&2
    exit 1
  }

  rg -q 'A0|G0|D1|D3|I4' "DOGFOOD-ROUND-1-BASELINE.md" || {
    echo "dogfood baseline is missing scenario coverage" >&2
    exit 1
  }

  rg -q 'Scenario `A0`|Scenario `G0`|Scenario `D1`|Scenario `D3`|Scenario `I4`' "DOGFOOD-GOLDEN-FIRST-REPLIES.md" || {
    echo "golden first replies are missing core scenarios" >&2
    exit 1
  }

  rg -q '首轮回复契约' "commands/assist.md" "commands/task.md" "commands/incident.md" "commands/scan.md" "commands/init.md" "commands/memory.md" || {
    echo "commands are missing first reply contract guidance" >&2
    exit 1
  }

  rg -q '聊天命令，不是 shell 命令' "commands/init.md" "commands/memory.md" "commands/scan.md" || {
    echo "core commands are missing chat-command semantics" >&2
    exit 1
  }

  rg -q '默认\*\*不需要\*\*用户再确认一次' "commands/init.md" || {
    echo "init command is missing zero-confirmation semantics" >&2
    exit 1
  }

  rg -q '不应再被拆成“是否允许我初始化”的二次确认|初始化后的补充校准永远不阻塞最小工作区落地' "skills/project-init/SKILL.md" || {
    echo "project-init skill is missing harness-style execution guidance" >&2
    exit 1
  }

  rg -q 'Scenario `A0`|Scenario `G0`|Scenario `D1`|Scenario `D3`|Scenario `I4`' "V2-ACCEPTANCE-SUITE.md" || {
    echo "acceptance suite is missing core scenarios" >&2
    exit 1
  }

  if rg -n '按阶段检查预期产出|完整度: 5/8|5/8 \\(62\\.5%\\)' "skills/evidence-chain/SKILL.md"; then
    echo "evidence-chain still contains rigid legacy completeness language" >&2
    exit 1
  fi

  if rg -n '是否需要用户确认才推进|阶段字段' "skills/custom-flow/SKILL.md"; then
    echo "custom-flow still contains stage-broadcast legacy language" >&2
    exit 1
  fi
else
  grep -qE 'minimal|partial|full' "skills/evidence-chain/SKILL.md" || {
    echo "evidence-chain is missing risk-level evidence language" >&2
    exit 1
  }

  grep -qE 'pause_on|expose_to_user' "skills/custom-flow/SKILL.md" || {
    echo "custom-flow is missing v2 execution-slice controls" >&2
    exit 1
  }

  grep -q '## First Reply Contract' "CLAUDE.md" || {
    echo "CLAUDE is missing first reply contract" >&2
    exit 1
  }

  grep -qE 'chat commands.*shell commands' "CLAUDE.md" || {
    echo "CLAUDE is missing chat-command semantics" >&2
    exit 1
  }

  grep -qE '## Harness Engineering|behave like a \*\*harness\*\*|behave like a harness' "CLAUDE.md" || {
    echo "CLAUDE is missing Harness Engineering guidance" >&2
    exit 1
  }

  grep -q 'First Reply Contract' "adapters/generic/AGENTS.md" || {
    echo "generic adapter is missing first reply contract" >&2
    exit 1
  }

  grep -q '首轮回复契约' "adapters/cursor/rules.md" "adapters/windsurf/rules.md" || {
    echo "host adapters are missing first reply contract guidance" >&2
    exit 1
  }

  grep -qE 'Scenario `A0`|Scenario `G0`|Scenario `D1`|Scenario `D3`|Scenario `I4`' "DOGFOOD-ROUND-1-WORKSHEET.md" || {
    echo "dogfood worksheet is missing core scenarios" >&2
    exit 1
  }

  grep -qE 'A0|G0|D1|D3|I4' "DOGFOOD-ROUND-1-BASELINE.md" || {
    echo "dogfood baseline is missing scenario coverage" >&2
    exit 1
  }

  grep -qE 'Scenario `A0`|Scenario `G0`|Scenario `D1`|Scenario `D3`|Scenario `I4`' "DOGFOOD-GOLDEN-FIRST-REPLIES.md" || {
    echo "golden first replies are missing core scenarios" >&2
    exit 1
  }

  grep -q '首轮回复契约' "commands/assist.md" "commands/task.md" "commands/incident.md" "commands/scan.md" "commands/init.md" "commands/memory.md" || {
    echo "commands are missing first reply contract guidance" >&2
    exit 1
  }

  grep -q '聊天命令，不是 shell 命令' "commands/init.md" "commands/memory.md" "commands/scan.md" || {
    echo "core commands are missing chat-command semantics" >&2
    exit 1
  }

  grep -qF '默认**不需要**用户再确认一次' "commands/init.md" || {
    echo "init command is missing zero-confirmation semantics" >&2
    exit 1
  }

  grep -qE '不应再被拆成“是否允许我初始化”的二次确认|初始化后的补充校准永远不阻塞最小工作区落地' "skills/project-init/SKILL.md" || {
    echo "project-init skill is missing harness-style execution guidance" >&2
    exit 1
  }

  grep -qE 'Scenario `A0`|Scenario `G0`|Scenario `D1`|Scenario `D3`|Scenario `I4`' "V2-ACCEPTANCE-SUITE.md" || {
    echo "acceptance suite is missing core scenarios" >&2
    exit 1
  }

  if grep -nE '按阶段检查预期产出|完整度: 5/8|5/8 \(62\.5%\)' "skills/evidence-chain/SKILL.md"; then
    echo "evidence-chain still contains rigid legacy completeness language" >&2
    exit 1
  fi

  if grep -nE '是否需要用户确认才推进|阶段字段' "skills/custom-flow/SKILL.md"; then
    echo "custom-flow still contains stage-broadcast legacy language" >&2
    exit 1
  fi
fi

echo "smoke-v2: OK"
