#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import tempfile
from hashlib import sha1
from pathlib import Path
from typing import Any


COMMAND_RE = re.compile(r"/feflow:[a-z0-9-]+", re.IGNORECASE)
STATE_DIR = Path(tempfile.gettempdir()) / "feflow-hook-state"


def extract_feflow_command(text: str | None) -> str | None:
    if not text:
        return None
    match = COMMAND_RE.search(text)
    if not match:
        return None
    return match.group(0).lower()


def state_path_for(payload: dict[str, Any]) -> Path | None:
    session_id = payload.get("session_id")
    transcript_path = payload.get("transcript_path")
    raw_key = str(session_id or transcript_path or "").strip()
    if not raw_key:
        return None

    digest = sha1(raw_key.encode("utf-8")).hexdigest()
    return STATE_DIR / f"{digest}.json"


def remember_feflow_command(payload: dict[str, Any], command: str | None) -> None:
    if not command:
        return

    state_path = state_path_for(payload)
    if state_path is None:
        return

    try:
        state_path.parent.mkdir(parents=True, exist_ok=True)
        state_path.write_text(
            json.dumps({"command": command}, ensure_ascii=False),
            encoding="utf-8",
        )
    except Exception:
        return


def read_remembered_feflow_command(payload: dict[str, Any]) -> str | None:
    state_path = state_path_for(payload)
    if state_path is None or not state_path.is_file():
        return None

    try:
        data = json.loads(state_path.read_text(encoding="utf-8"))
    except Exception:
        return None

    command = extract_feflow_command(data.get("command"))
    if not command:
        return None
    return command


def detect_feflow_command(payload: dict[str, Any]) -> str | None:
    for key in ("user_prompt", "prompt"):
        command = extract_feflow_command(payload.get(key))
        if command:
            remember_feflow_command(payload, command)
            return command

    remembered_command = read_remembered_feflow_command(payload)
    if remembered_command:
        return remembered_command

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
        return remembered_command

    if last_command:
        remember_feflow_command(payload, last_command)
    return last_command


def feflow_mode(payload: dict[str, Any]) -> str | None:
    command = detect_feflow_command(payload)
    if not command:
        return None
    return command.split(":", 1)[1]
