#!/usr/bin/env python3
from __future__ import annotations

import json
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

from feflow_hook_context import detect_feflow_command  # noqa: E402


BLOCKED_SKILL_PREFIXES = ("pua", "pua:")
BLOCKED_READ_PATH_FRAGMENTS = (
    "/pua-skills/pua/",
    "/plugins/cache/pua-skills/",
    "/plugins/marketplaces/pua-skills/",
)
PRETOOL_EVENT = "PreToolUse"
PAGE_ORIENTED_SUFFIXES = (".pdf",)


def deny(message: str) -> int:
    response = {
        "hookSpecificOutput": {
            "hookEventName": PRETOOL_EVENT,
            "permissionDecision": "deny",
            "permissionDecisionReason": message,
        },
        "systemMessage": message,
    }
    sys.stdout.write(json.dumps(response, ensure_ascii=False))
    return 0


def allow_with_updated_input(updated_input: dict[str, object], message: str) -> int:
    response = {
        "hookSpecificOutput": {
            "hookEventName": PRETOOL_EVENT,
            "permissionDecision": "allow",
            "permissionDecisionReason": message,
            "updatedInput": updated_input,
        },
        "systemMessage": message,
    }
    sys.stdout.write(json.dumps(response, ensure_ascii=False))
    return 0


def handle_skill(tool_input: dict[str, object]) -> int:
    skill_name = str(tool_input.get("skill") or "")
    if not any(skill_name == prefix or skill_name.startswith(prefix) for prefix in BLOCKED_SKILL_PREFIXES):
        return 0

    return deny(
        "While handling `/feflow:*`, keep command ownership inside feflow. "
        "Do not invoke unrelated external persona/workflow skills such as `pua:*`."
    )


def handle_read(tool_input: dict[str, object]) -> int:
    file_path = str(tool_input.get("file_path") or "")
    if any(fragment in file_path for fragment in BLOCKED_READ_PATH_FRAGMENTS):
        return deny(
            "While handling `/feflow:*`, do not read PUA persona materials. "
            "Stay inside feflow and inspect the repo or target files directly."
        )

    pages = tool_input.get("pages")
    if "pages" not in tool_input:
        return 0

    if isinstance(pages, str) and not pages.strip():
        updated_input = dict(tool_input)
        updated_input.pop("pages", None)
        return allow_with_updated_input(
            updated_input,
            "Removed an empty `pages` argument from `Read`. "
            "Use `pages` only for page-oriented documents such as PDFs.",
        )

    normalized_path = file_path.lower()
    if normalized_path and not normalized_path.endswith(PAGE_ORIENTED_SUFFIXES):
        updated_input = dict(tool_input)
        updated_input.pop("pages", None)
        return allow_with_updated_input(
            updated_input,
            "Removed `pages` from `Read` for a normal source/text file. "
            "Use `pages` only for page-oriented documents such as PDFs.",
        )

    return 0


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    active_command = detect_feflow_command(payload)
    if not active_command:
        return 0

    tool_name = payload.get("tool_name")
    tool_input = payload.get("tool_input")
    if not isinstance(tool_input, dict):
        return 0

    if tool_name == "Skill":
        return handle_skill(tool_input)
    if tool_name == "Read":
        return handle_read(tool_input)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
