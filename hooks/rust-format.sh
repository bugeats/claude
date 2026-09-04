input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

if [[ "$file_path" == *.rs ]] && [[ -f "$file_path" ]]; then
  # Standalone rustfmt defaults to edition 2015 and rejects `async fn`.
  rustfmt --edition 2024 "$file_path"
fi
