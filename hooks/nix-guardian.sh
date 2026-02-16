#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // empty')

if echo "$command" | grep -qE '^(cargo build|cargo install|cargo run|npm install|npm run|yarn |pnpm |pip install|pip3 install|make($| )|cmake |gcc |g\+\+ |clang )'; then
  jq -n '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "ask",
      permissionDecisionReason: "Nix is the default build tool. Use nix build, nix develop --command <cmd>, or explain why nix is unsuitable."
    }
  }'
  exit 0
fi

exit 0
