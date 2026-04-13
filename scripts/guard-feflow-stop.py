#!/usr/bin/env python3
import json
import re
import sys


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

    if sum(token in message for token in AUDIT_TOKENS) >= 2:
        return True

    first_line = first_non_empty_line(message)
    if re.match(r"^(我先|I(?:'ll| will)\b)", first_line):
        return True

    return False


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    if payload.get("stop_hook_active"):
        return 0

    message = payload.get("last_assistant_message") or ""
    if not should_block(message):
        return 0

    mode = sys.argv[1] if len(sys.argv) > 1 else "/feflow:*"
    response = {
        "decision": "block",
        "reason": (
            f"For /feflow:{mode}, the user-visible output must stay operator-style: "
            "start with the concrete result, do not include `★ Insight`, "
            "and do not use the numbered audit template. Rewrite it as one short result paragraph "
            "plus at most one short next-step line."
        ),
    }
    sys.stdout.write(json.dumps(response, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
