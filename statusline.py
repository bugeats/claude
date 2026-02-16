#!/usr/bin/env python3
import json
import sys

data = json.load(sys.stdin)

model = data.get("model", {}).get("display_name", "?")

ctx = data.get("context_window", {})
pct = int(ctx.get("used_percentage", 0))
filled = pct // 10
bar = "\u2593" * filled + "\u2591" * (10 - filled)
in_tok = ctx.get("total_input_tokens", 0)
out_tok = ctx.get("total_output_tokens", 0)

cost = data.get("cost", {})
dollars = cost.get("total_cost_usd", 0) or 0
duration_ms = cost.get("total_duration_ms", 0) or 0
added = cost.get("total_lines_added", 0) or 0
removed = cost.get("total_lines_removed", 0) or 0


def fmt_tokens(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def fmt_duration(ms):
    s = int(ms // 1000)
    m, s = divmod(s, 60)
    h, m = divmod(m, 60)
    if h:
        return f"{h}h{m:02d}m"
    return f"{m}m{s:02d}s"


parts = [
    f"{model} {bar} {pct}% (▲{fmt_tokens(in_tok)} ▼{fmt_tokens(out_tok)})",
    f"${dollars:.2f}",
    fmt_duration(duration_ms),
    f"+{added}-{removed}",
]

print("  ".join(parts))
