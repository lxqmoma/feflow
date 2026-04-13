#!/usr/bin/env bash
# feflow session startup detection
# Reports governance capability availability without forcing all tasks into workflow orchestration.

set -euo pipefail

PROJECT_DIR="${PWD}"
FEFLOW_DIR="${PROJECT_DIR}/.feflow"
INIT_CONFIG="${FEFLOW_DIR}/project/init-config.md"

if [ -d "${FEFLOW_DIR}" ]; then
  feflow_initialized=true
else
  feflow_initialized=false
fi

if [ -f "${INIT_CONFIG}" ]; then
  init_config_exists=true
else
  init_config_exists=false
fi

if [ "${feflow_initialized}" = true ] && [ "${init_config_exists}" = true ]; then
  status="ready"
  context="本项目已启用 feflow 治理能力。默认先按普通助手方式处理只读分析和低风险任务，不要把所有研发请求都直接升级为流程化交付。只有在真实代码交付、高风险改动、跨会话跟踪或事故处理场景下，才抬升到 feflow 的 Delivery/Incident 治理模式。对用户隐藏内部的 skill、hook、gate、role 等术语，也不要以“使用 pua / superpowers / 某某 skill”作为开场白。对有界本地任务，先执行再汇报；没有 Bash / Read / Write / Edit 等工具证据时，不要声称已完成、已落盘、已验证。若用户发 `/feflow:init`，在可写宿主里应同回合创建或修复最小工作区，然后再给结果。"
elif [ "${feflow_initialized}" = true ] && [ "${init_config_exists}" = false ]; then
  status="partial"
  context="检测到 .feflow 目录但未完成治理初始化。你仍可直接执行仓库阅读、代码解释和低风险协助；如需完整的记忆、证据和交付治理能力，可直接执行 `/feflow:init` 补全配置。不要把这类动作包装成额外确认流，也不要先口头宣称完成再补证据。"
else
  status="uninitialized"
  context="当前项目未启用 feflow 治理目录。你仍可直接执行仓库扫描、阅读、解释和低风险任务；只有在用户明确需要前端交付治理能力时，再建议运行 /feflow:init。若用户已经发出 `/feflow:init`，就把它当成执行请求：直接用可用工具创建最小工作区，而不是继续解释流程、切换人设、或要求用户重复命令。"
fi

echo "{\"additionalContext\": \"[feflow:${status}] ${context}\"}"
