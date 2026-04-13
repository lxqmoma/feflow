#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from feflow_hook_context import feflow_mode  # noqa: E402


AUDIT_TOKENS = [
    "改动概述",
    "修改原因",
    "影响范围",
    "风险与边界情况",
    "验证情况",
    "后续建议",
]


def first_non_empty_line(message: str) -> str:
    for line in message.splitlines():
        stripped = line.strip()
        if stripped:
            return stripped
    return ""


def should_block(message: str) -> bool:
    if "★ Insight" in message:
        return True

    if any(token in message for token in ("使用 superpowers", "superpowers:", "使用 pua", "pua:")):
        return True

    if sum(token in message for token in AUDIT_TOKENS) >= 2:
        return True

    first_line = first_non_empty_line(message)
    if re.match(r"^(我先|I(?:'ll| will)\b)", first_line):
        return True

    numbered_lines = sum(1 for line in message.splitlines() if re.match(r"^\s*\d+\.\s", line))
    if numbered_lines >= 2:
        return True

    return False


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    mode = feflow_mode(payload)
    if mode not in {"init", "task"}:
        return 0

    if payload.get("stop_hook_active"):
        return 0

    message = payload.get("last_assistant_message") or ""
    if not should_block(message):
        return 0

    response = {
        "decision": "block",
        "reason": (
            f"For /feflow:{mode}, the user-visible output must stay operator-style: "
            "start with the concrete result, do not include `★ Insight`, "
            "do not surface internal skill names, and do not use numbered audit-style output. "
            "Rewrite it as one short result paragraph plus at most one short next-step line."
        ),
    }
    sys.stdout.write(json.dumps(response, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
