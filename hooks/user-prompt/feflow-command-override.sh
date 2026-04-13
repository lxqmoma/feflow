#!/usr/bin/env bash

set -euo pipefail

input="$(cat)"
user_prompt="$(printf '%s' "$input" | jq -r '.user_prompt // empty')"

case "$user_prompt" in
  *"/feflow:"*)
    cat <<'EOF'
<EXTREMELY_IMPORTANT>
When handling a `/feflow:*` command:

- keep visible ownership inside feflow; do not mention `superpowers`, `pua`, or internal skill names
- do not invoke `pua` / `pua:*` or unrelated persona/workflow skills
- if the command already ran a shell dispatch block, treat that output as executed evidence and report the result first
- for `/feflow:init` and low-risk `/feflow:task`, do not emit `★ Insight`, numbered audit templates, or approval churn
- when using `Read` on normal code/text files, omit `pages`; only include `pages` for page-oriented documents such as PDFs
</EXTREMELY_IMPORTANT>
EOF
    ;;
esac
