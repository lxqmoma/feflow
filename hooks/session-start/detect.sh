#!/usr/bin/env bash
# feflow 会话启动检测脚本
# 检测当前项目的 feflow 初始化状态，输出 JSON 格式的 additionalContext

set -euo pipefail

PROJECT_DIR="${PWD}"
FEFLOW_DIR="${PROJECT_DIR}/.feflow"
INIT_CONFIG="${FEFLOW_DIR}/project/init-config.md"

# 检测 .feflow/ 目录
if [ -d "${FEFLOW_DIR}" ]; then
  feflow_initialized=true
else
  feflow_initialized=false
fi

# 检测 init-config.md
if [ -f "${INIT_CONFIG}" ]; then
  init_config_exists=true
else
  init_config_exists=false
fi

# 确定整体状态
if [ "${feflow_initialized}" = true ] && [ "${init_config_exists}" = true ]; then
  status="ready"
  context="本项目已启用 feflow 前端研发协作引擎。当用户描述研发任务（开发功能、修复bug、UI优化、重构等）时，必须优先使用 feflow:orchestrator skill 处理，不要使用 superpowers:brainstorming 或其他通用工作流。feflow:orchestrator 会负责任务识别、分级、记忆加载、角色分派和流程推进。只有 feflow 流程中的编码实施阶段才可选调用 superpowers 的 TDD/debugging/code-review 能力。"
elif [ "${feflow_initialized}" = true ] && [ "${init_config_exists}" = false ]; then
  status="partial"
  context="检测到 .feflow 目录但未完成初始化。建议运行 /feflow:init 补全配置。"
else
  status="uninitialized"
  context="当前项目未使用 feflow。如需启用前端研发协作引擎，运行 /feflow:init 初始化。"
fi

# 输出 additionalContext 字符串格式
echo "{\"additionalContext\": \"[feflow:${status}] ${context}\"}"
