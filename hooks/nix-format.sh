#!/usr/bin/env bash
set -euo pipefail

input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$file_path" == *.nix ]] && [[ -f "$file_path" ]]; then
  nix run nixpkgs#nixfmt-rfc-style -- "$file_path"
fi
