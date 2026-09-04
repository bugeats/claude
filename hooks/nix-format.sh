input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$file_path" == *.nix ]] && [[ -f "$file_path" ]]; then
  nixfmt "$file_path"
fi
