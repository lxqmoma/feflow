#!/usr/bin/env python3
import json
import sys


def main() -> int:
    blocked_prefixes = [arg for arg in sys.argv[1:] if arg]
    if not blocked_prefixes:
        return 0

    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    if payload.get("tool_name") != "Skill":
        return 0

    tool_input = payload.get("tool_input") or {}
    skill_name = tool_input.get("skill") or ""

    if not any(skill_name.startswith(prefix) for prefix in blocked_prefixes):
        return 0

    decision = {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": "deny",
            "permissionDecisionReason": (
                "While handling /feflow:* commands, keep command ownership inside feflow. "
                "Do not invoke unrelated external persona/workflow skills such as pua:*."
            ),
        }
    }
    sys.stdout.write(json.dumps(decision, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
