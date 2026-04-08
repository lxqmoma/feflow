#!/usr/bin/env bash
# feflow 会话启动检测脚本
# 检测当前项目的 feflow 初始化状态，输出 JSON 格式的 additionalContext

set -euo pipefail

PROJECT_DIR="${PWD}"
FEFLOW_DIR="${PROJECT_DIR}/.feflow"
INIT_CONFIG="${FEFLOW_DIR}/init-config.md"

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
  message="feflow 已初始化，配置完整"
elif [ "${feflow_initialized}" = true ] && [ "${init_config_exists}" = false ]; then
  status="partial"
  message="feflow 目录存在但缺少 init-config.md，请运行初始化补全配置"
else
  status="uninitialized"
  message="当前项目未初始化 feflow，可通过 /feflow-init 开始"
fi

# 输出 JSON 格式的 additionalContext
cat <<EOF
{
  "additionalContext": {
    "feflow": {
      "status": "${status}",
      "message": "${message}",
      "projectDir": "${PROJECT_DIR}",
      "feflowDir": "${FEFLOW_DIR}",
      "feflowInitialized": ${feflow_initialized},
      "initConfigExists": ${init_config_exists}
    }
  }
}
EOF
