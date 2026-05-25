config_dir="$HOME/.claude"

ensure_identity() {
  if [ ! -f "$config_dir/identity" ]; then
    local default_name input

    default_name="$(whoami)"
    printf "How should Claude address you? [%s]: " "$default_name"
    read -r input
    echo "${input:-$default_name}" > "$config_dir/identity"
  fi
}

show_banner() {
  local name
  name=$(cat "$config_dir/identity")

  clear

  {
    figlet -f "$MINIWI_FONT" "$name ships clean code"
    echo
    cat "$FLAKE_SELF/diagram.txt"
  } | tte slide

  printf '\n  %s\n\n' "This Claude is equipped with an entropy containment system. Say /school-me for more."
}

# v1 staged hooks/tools/settings into ~/.claude and tore them down on exit —
# racy with concurrent sessions. v2 reads from the immutable plugin path, so
# legacy ~/.claude/ artifacts must go before claude loads or hook paths under
# ~/.claude collide with plugin-scope hooks under $FLAKE_SELF.
looks_like_v1_settings() {
  if [ -L "$1" ]; then return 0; fi
  if [ ! -f "$1" ]; then return 1; fi

  # shellcheck disable=SC2016 # literal sentinel string, not shell expansion
  grep -qF '$HOME/.claude/statusline.py' "$1" 2>/dev/null
}

migrate_from_v1() {
  local settings="$config_dir/settings.json"
  local backup="$config_dir/settings.backup-pre-claude-arcs.json"

  if [ -f "$backup" ]; then
    rm -f "$settings"
    mv "$backup" "$settings"
  elif looks_like_v1_settings "$settings"; then
    rm -f "$settings"
  fi

  for f in "$config_dir/statusline.py" "$HOME/CLAUDE.md" "$config_dir"/skills/*/; do
    f="${f%/}"

    if [ -L "$f" ] && [[ "$(readlink "$f")" == /nix/store/* ]]; then rm "$f"; fi
  done

  rm -f "$config_dir"/hooks/*.sh "$config_dir"/tools/*.sh
  rm -f "$config_dir/cargo-workspace-root"

  claude mcp remove rust-analyzer -s user 2>/dev/null || true
}

mkdir -p "$config_dir"
ensure_identity
show_banner
migrate_from_v1

export CLAUDE_ARCS_ROOT="$FLAKE_SELF"

exec claude \
  --plugin-dir "$FLAKE_SELF" \
  --settings "$FLAKE_SELF/settings.json" \
  --append-system-prompt-file "$FLAKE_SELF/CLAUDE.system.md" \
  "$@"
