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

  rg -q '## Execution Proof|do not claim files were created unless file tools actually created or confirmed them' "CLAUDE.md" || {
    echo "CLAUDE is missing execution-proof guidance" >&2
    exit 1
  }

  test -f "runtime/frontend-harness.md" || {
    echo "frontend runtime harness is missing" >&2
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

  rg -q '当前这一回合|同一回合' "commands/init.md" "skills/project-init/SKILL.md" "CLAUDE.md" || {
    echo "init flow is missing same-turn execution semantics" >&2
    exit 1
  }

  rg -q '只有一回合完成机会|single-shot|slash command 很容易在第一条助手消息后直接结束' "commands/init.md" "skills/project-init/SKILL.md" "CLAUDE.md" || {
    echo "init flow is missing single-shot slash-command semantics" >&2
    exit 1
  }

  rg -q '再发一次 `/feflow:init`|再次发送 `/init` 或 `/feflow:init`' "commands/init.md" "skills/project-init/SKILL.md" "DOGFOOD-GOLDEN-FIRST-REPLIES.md" || {
    echo "init flow is missing anti-repeat-command guidance" >&2
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

  rg -q 'pua / superpowers|claims files were created, checked, or validated without any tool-backed evidence' "V2-ACCEPTANCE-SUITE.md" "hooks/session-start/detect.sh" || {
    echo "acceptance/session hook are missing anti-theater execution-proof guidance" >&2
    exit 1
  }

  rg -q 'frontend-harness.md|FEFLOW_FRONTEND_HARNESS|hookSpecificOutput' "hooks/session-start/detect.sh" || {
    echo "session-start hook is missing frontend harness injection" >&2
    exit 1
  }

  rg -q 'superpowers.*base execution discipline|default visible owner: FE|one visible owner' "runtime/frontend-harness.md" "V2-DESIGN-SPEC.md" "README.md" "skills/orchestrator/SKILL.md" || {
    echo "layered superpowers-first architecture is not fully encoded" >&2
    exit 1
  }

  rg -q 'do not echo `superpowers:using-superpowers`|Visibility Override' "runtime/frontend-harness.md" || {
    echo "frontend harness is missing internal-skill visibility override" >&2
    exit 1
  }

  rg -q 'If the session exposes tools such as|do not claim file tools are unavailable' "runtime/frontend-harness.md" "commands/init.md" "commands/task.md" || {
    echo "tool-availability truth-source guidance is missing" >&2
    exit 1
  }

  hook_output="$(CLAUDE_PLUGIN_ROOT=1 ./hooks/session-start/detect.sh)"
  printf '%s' "$hook_output" | rg -q 'hookSpecificOutput|additionalContext' || {
    echo "session-start hook did not emit Claude Code context payload" >&2
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

  grep -qE '## Execution Proof|do not claim files were created unless file tools actually created or confirmed them' "CLAUDE.md" || {
    echo "CLAUDE is missing execution-proof guidance" >&2
    exit 1
  }

  test -f "runtime/frontend-harness.md" || {
    echo "frontend runtime harness is missing" >&2
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

  grep -qE '当前这一回合|同一回合' "commands/init.md" "skills/project-init/SKILL.md" "CLAUDE.md" || {
    echo "init flow is missing same-turn execution semantics" >&2
    exit 1
  }

  grep -qE '只有一回合完成机会|single-shot|slash command 很容易在第一条助手消息后直接结束' "commands/init.md" "skills/project-init/SKILL.md" "CLAUDE.md" || {
    echo "init flow is missing single-shot slash-command semantics" >&2
    exit 1
  }

  grep -qE '再发一次 `/feflow:init`|再次发送 `/init` 或 `/feflow:init`' "commands/init.md" "skills/project-init/SKILL.md" "DOGFOOD-GOLDEN-FIRST-REPLIES.md" || {
    echo "init flow is missing anti-repeat-command guidance" >&2
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

  grep -qE 'pua / superpowers|claims files were created, checked, or validated without any tool-backed evidence' "V2-ACCEPTANCE-SUITE.md" "hooks/session-start/detect.sh" || {
    echo "acceptance/session hook are missing anti-theater execution-proof guidance" >&2
    exit 1
  }

  grep -qE 'frontend-harness.md|FEFLOW_FRONTEND_HARNESS|hookSpecificOutput' "hooks/session-start/detect.sh" || {
    echo "session-start hook is missing frontend harness injection" >&2
    exit 1
  }

  grep -qE 'superpowers.*base execution discipline|default visible owner: FE|one visible owner' "runtime/frontend-harness.md" "V2-DESIGN-SPEC.md" "README.md" "skills/orchestrator/SKILL.md" || {
    echo "layered superpowers-first architecture is not fully encoded" >&2
    exit 1
  }

  grep -qE 'do not echo `superpowers:using-superpowers`|Visibility Override' "runtime/frontend-harness.md" || {
    echo "frontend harness is missing internal-skill visibility override" >&2
    exit 1
  }

  grep -qE 'If the session exposes tools such as|do not claim file tools are unavailable' "runtime/frontend-harness.md" "commands/init.md" "commands/task.md" || {
    echo "tool-availability truth-source guidance is missing" >&2
    exit 1
  }

  hook_output="$(CLAUDE_PLUGIN_ROOT=1 ./hooks/session-start/detect.sh)"
  printf '%s' "$hook_output" | grep -qE 'hookSpecificOutput|additionalContext' || {
    echo "session-start hook did not emit Claude Code context payload" >&2
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
