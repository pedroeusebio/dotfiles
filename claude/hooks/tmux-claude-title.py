#!/usr/bin/env python3
"""Names the tmux window holding a Claude Code session after what it is doing.

Driven by Claude Code hooks (hook JSON on stdin):

  prompt -> UserPromptSubmit  (detaches and retries ~30s: the session title
                               is written a few seconds after the 1st prompt)
  stop   -> Stop              (catches a PR created during the turn)
  start  -> SessionStart      (reset, then name it if resuming a session)
  end    -> SessionEnd        (give the window back to tmux automatic-rename)

Name, by priority:
  CR:<n>   code review of PR n (prompt asks for a review + PR number, or the
           session title says review + number)
  PR:<n>   the session created PR n (`gh pr create` output), or the session
           title mentions PR n
  <title>  Claude Code's own session title (`ai-title` in the transcript),
           cut to MAX_LEN characters
A window you renamed by hand is left alone: the last name set here is kept in
the window option @claude_title, and a different current name means you own it.
Always exits 0 so a hook can never block a turn.
"""
import json
import os
import re
import subprocess
import sys
import time

MAX_LEN = 20
POLL_SECONDS = 30
POLL_EVERY = 2

PANE = os.environ.get("TMUX_PANE")

REVIEW_RE = re.compile(r"code[- ]?review|/review\b|\breview\b|revis(?:ar|ão|ao|e)\b", re.I)
PR_NUM_RES = [
    re.compile(r"github\.com/[^/\s]+/[^/\s]+/pull/(\d+)"),
    re.compile(r"<command-args>\s*#?(\d{3,6})\b"),
    re.compile(r"^\s*/\S+\s+#?(\d{3,6})\b"),
    re.compile(r"\bPR\s*[:#]?\s*(\d{3,6})\b", re.I),
    re.compile(r"\bpull request\s*#?(\d{3,6})\b", re.I),
    re.compile(r"(?<![\w&])#(\d{3,6})\b"),
]
PULL_URL_RE = re.compile(r"github\.com/[^/\s\"]+/[^/\s\"]+/pull/(\d+)")
# `gh pr create` as the command itself (possibly after `cd x &&`), not quoted text
GH_PR_CREATE_RE = re.compile(r"(?:^|[;&|(]\s*)\s*gh\s+pr\s+create\b", re.M)


def tmux(*args):
    try:
        return subprocess.run(
            ["tmux", *args], capture_output=True, text=True, timeout=3
        ).stdout.strip()
    except Exception:
        return ""


def pr_number(text):
    for rx in PR_NUM_RES:
        m = rx.search(text)
        if m:
            return m.group(1)
    return None


def read_transcript(path):
    """Returns (last ai-title, first user prompts, PR number created by gh)."""
    title, prompts, created = None, [], None
    pr_create_ids = set()
    if not path or not os.path.exists(path):
        return title, prompts, created
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            for line in fh:
                if '"ai-title"' not in line and '"user"' not in line and "gh pr create" not in line:
                    continue
                try:
                    e = json.loads(line)
                except ValueError:
                    continue
                kind = e.get("type")
                if kind == "ai-title" and e.get("aiTitle"):
                    title = e["aiTitle"]
                elif kind == "assistant":
                    for c in (e.get("message") or {}).get("content") or []:
                        if (
                            isinstance(c, dict)
                            and c.get("type") == "tool_use"
                            and GH_PR_CREATE_RE.search(str((c.get("input") or {}).get("command", "")))
                        ):
                            pr_create_ids.add(c.get("id"))
                elif kind == "user":
                    content = (e.get("message") or {}).get("content")
                    if isinstance(content, str):
                        if not e.get("isMeta") and len(prompts) < 3:
                            prompts.append(content)
                    elif isinstance(content, list):
                        for c in content:
                            if (
                                isinstance(c, dict)
                                and c.get("type") == "tool_result"
                                and c.get("tool_use_id") in pr_create_ids
                            ):
                                m = PULL_URL_RE.findall(json.dumps(c.get("content")))
                                if m:
                                    created = m[-1]
    except OSError:
        pass
    return title, prompts, created


def compute_name(hook):
    title, prompts, created = read_transcript(hook.get("transcript_path"))
    if hook.get("prompt"):
        prompts = [hook["prompt"], *prompts]

    for p in prompts:
        if REVIEW_RE.search(p):
            n = pr_number(p)
            if n:
                return f"CR:{n}"
    if title and REVIEW_RE.search(title) and pr_number(title):
        return f"CR:{pr_number(title)}"
    if created:
        return f"PR:{created}"
    if title and pr_number(title):
        return f"PR:{pr_number(title)}"
    if title:
        title = " ".join(title.split())
        return title if len(title) <= MAX_LEN else title[:MAX_LEN].rstrip() + "…"
    return None


def apply(name):
    if not name:
        return
    current = tmux("display-message", "-p", "-t", PANE, "#{window_name}")
    owned = tmux("show-options", "-wqv", "-t", PANE, "@claude_title")
    auto = tmux("show-options", "-wqv", "-t", PANE, "automatic-rename")
    if auto == "off" and current != owned:
        return  # renamed by hand
    if current != name:
        tmux("rename-window", "-t", PANE, name)
    tmux("set-option", "-w", "-t", PANE, "@claude_title", name)


def reset():
    owned = tmux("show-options", "-wqv", "-t", PANE, "@claude_title")
    if not owned:
        return
    current = tmux("display-message", "-p", "-t", PANE, "#{window_name}")
    tmux("set-option", "-w", "-u", "-t", PANE, "@claude_title")
    if current == owned:
        tmux("set-option", "-w", "-t", PANE, "automatic-rename", "on")


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    try:
        hook = json.load(sys.stdin)
    except ValueError:
        hook = {}
    if not os.environ.get("TMUX") or not PANE:
        return

    if mode == "end":
        reset()
    elif mode == "start":
        reset()
        apply(compute_name(hook))
    elif mode == "stop":
        apply(compute_name(hook))
    elif mode == "prompt":
        # Detach so the hook returns at once, then retry while the title appears.
        if os.fork():
            return
        os.setsid()
        devnull = os.open(os.devnull, os.O_RDWR)
        for fd in (0, 1, 2):
            os.dup2(devnull, fd)
        deadline = time.time() + POLL_SECONDS
        while True:
            apply(compute_name(hook))
            if time.time() >= deadline:
                break
            time.sleep(POLL_EVERY)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        pass
    sys.exit(0)
