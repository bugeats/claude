#!/usr/bin/env python3
import json
import subprocess
import sys

data = json.load(sys.stdin)

model = data.get("model", {}).get("display_name", "?")
project_dir = data.get("workspace", {}).get("project_dir", "")

context_window = data.get("context_window", {})
percentage = int(context_window.get("used_percentage", 0) or 0)
filled = percentage // 10
progress_bar = "\u2593" * filled + "\u2591" * (10 - filled)
tok_input_count = context_window.get("total_input_tokens", 0)
tok_output_count = context_window.get("total_output_tokens", 0)

cost = data.get("cost", {})
dollars = cost.get("total_cost_usd", 0) or 0
duration_ms = cost.get("total_duration_ms", 0) or 0
added = cost.get("total_lines_added", 0) or 0
removed = cost.get("total_lines_removed", 0) or 0


def git_query(cwd, args):
    if not cwd:
        return None

    try:
        result = subprocess.run(
            ["git"] + args,
            cwd=cwd,
            capture_output=True,
            text=True,
            timeout=2,
        )
    except (subprocess.TimeoutExpired, FileNotFoundError):
        return None

    if result.returncode != 0:
        return None

    return result.stdout.strip()


def count_checkpoints(cwd):
    output = git_query(cwd, ["log", "-50", "--format=%s"])

    if output is None:
        return 0

    count = 0
    for subject in output.splitlines():
        if subject.startswith("CHECKPOINT:"):
            count += 1
        else:
            break

    return count


def current_branch(cwd):
    return git_query(cwd, ["rev-parse", "--abbrev-ref", "HEAD"])


def format_tokens(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def format_duration(ms):
    s = int(ms // 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    if h:
        return f"{h}h{m:02d}m"
    return f"{m}m{s:02d}s"


RESET = "\033[0m"
DIM = "\033[2m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
PURPLE = "\033[38;2;179;136;255m"  # #B388FF — Claude brand accent

checkpoints = count_checkpoints(project_dir)
branch = current_branch(project_dir)

arc_label = f"{PURPLE}Arcs ⌁{checkpoints}{RESET} {DIM}|{RESET} {model}"

if branch:
    arc_label += f" {DIM}on{RESET} {branch}"

if percentage >= 90:
    pct_color = RED
elif percentage >= 70:
    pct_color = YELLOW
else:
    pct_color = GREEN

sep = f" {DIM}|{RESET} "

parts = [
    arc_label,
    f"{progress_bar} {pct_color}{percentage}%{RESET} {DIM}▲{RESET}{format_tokens(tok_input_count)} {DIM}▼{RESET}{format_tokens(tok_output_count)}",
    f"${dollars:.2f}",
    format_duration(duration_ms),
    f"{GREEN}+{added}{RESET}{RED}-{removed}{RESET}",
]

print(sep.join(parts))
