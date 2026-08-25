#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$file_path" == *.rs ]] && [[ -f "$file_path" ]]; then
  rustfmt --edition 2024 "$file_path"
fi
