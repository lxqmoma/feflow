#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Any


COMMAND_RE = re.compile(r"/feflow:[a-z0-9-]+", re.IGNORECASE)


def extract_feflow_command(text: str | None) -> str | None:
    if not text:
        return None
    match = COMMAND_RE.search(text)
    if not match:
        return None
    return match.group(0).lower()


def detect_feflow_command(payload: dict[str, Any]) -> str | None:
    command = extract_feflow_command(payload.get("user_prompt"))
    if command:
        return command

    transcript_path = payload.get("transcript_path")
    if not transcript_path:
        return None

    path = Path(str(transcript_path))
    if not path.is_file():
        return None

    last_command: str | None = None
    try:
        with path.open("r", encoding="utf-8") as handle:
            for raw_line in handle:
                line = raw_line.strip()
                if not line:
                    continue

                command = extract_feflow_command(line)
                if command:
                    last_command = command
                    continue

                try:
                    record = json.loads(line)
                except Exception:
                    continue

                message = record.get("message")
                if isinstance(message, dict):
                    content = message.get("content")
                    if isinstance(content, str):
                        command = extract_feflow_command(content)
                        if command:
                            last_command = command

                last_prompt = record.get("lastPrompt")
                if isinstance(last_prompt, str):
                    command = extract_feflow_command(last_prompt)
                    if command:
                        last_command = command

                queue_content = record.get("content")
                if isinstance(queue_content, str):
                    command = extract_feflow_command(queue_content)
                    if command:
                        last_command = command
    except Exception:
        return None

    return last_command


def feflow_mode(payload: dict[str, Any]) -> str | None:
    command = detect_feflow_command(payload)
    if not command:
        return None
    return command.split(":", 1)[1]
