config_dir="$HOME/.claude"

ensure_config_dirs() {
  mkdir -p "$config_dir/skills" "$config_dir/hooks" "$config_dir/tools"
}

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

remove_managed_artifacts() {
  # Symlinks into the nix store (skills, statusline, CLAUDE.md)
  for f in "$config_dir/statusline.py" "$HOME/CLAUDE.md" "$config_dir"/skills/*/; do
    f="${f%/}"

    if [ -L "$f" ] && [[ "$(readlink "$f")" == /nix/store/* ]]; then rm "$f"; fi
  done

  # Copied files (settings, tools, hooks) — remove unconditionally
  rm -f "$config_dir/settings.json"
  rm -f "$config_dir"/tools/*.sh
  rm -f "$config_dir"/hooks/*.sh
}

find_cargo_root() {
  local dir="$PWD"

  while [ "$dir" != "/" ]; do
    if [ -f "$dir/Cargo.toml" ]; then
      echo "$dir"
      return 0
    fi

    dir="$(dirname "$dir")"
  done

  return 1
}

install_mcp_servers() {
  local cargo_root

  if cargo_root=$(find_cargo_root); then
    claude mcp add-json rust-analyzer \
      '{"type":"stdio","command":"rust-analyzer-mcp"}' -s user 2>/dev/null || true

    echo "$cargo_root" > "$config_dir/cargo-workspace-root"
  fi
}

# shellcheck disable=SC2329
remove_mcp_servers() {
  claude mcp remove rust-analyzer -s user 2>/dev/null || true
  rm -f "$config_dir/cargo-workspace-root"
}

install_config() {
  # Writable copy — Claude Code writes back to settings.json at runtime
  local settings="$config_dir/settings.json"
  local backup="$config_dir/settings.backup-pre-claude-arcs.json"

  if [ -f "$settings" ] && [ ! -L "$settings" ] && [ ! -f "$backup" ]; then
    mv "$settings" "$backup"
  fi

  install -m 0644 "$FLAKE_SELF/settings.json" "$settings"

  for skill in "$FLAKE_SELF"/skills/*/; do
    ln -sfn "$skill" "$config_dir/skills/$(basename "$skill")"
  done

  ln -sf "$FLAKE_SELF/statusline.py" "$config_dir/statusline.py"

  for tool in "$FLAKE_SELF"/tools/*.sh; do
    install -m 0755 "$tool" "$config_dir/tools/$(basename "$tool")"
  done

  for hook in "$FLAKE_SELF"/hooks/*.sh; do
    install -m 0755 "$hook" "$config_dir/hooks/$(basename "$hook")"
  done

  ln -sf "$FLAKE_SELF/CLAUDE.system.md" "$HOME/CLAUDE.md"
}

# shellcheck disable=SC2329
restore_settings() {
  local settings="$config_dir/settings.json"
  local backup="$config_dir/settings.backup-pre-claude-arcs.json"

  rm -f "$settings"

  if [ -f "$backup" ]; then
    mv "$backup" "$settings"
  fi
}

# shellcheck disable=SC2329
on_exit() {
  printf "\n  Cleaning up after myself ... "
  remove_mcp_servers
  remove_managed_artifacts
  restore_settings
  echo "ok"

  printf "\n  Come back any time:\n\n      nix run %s --refresh\n\n" "$FLAKE_URI"
}

ensure_config_dirs
ensure_identity
show_banner

trap on_exit EXIT
remove_managed_artifacts
install_config
install_mcp_servers

claude "$@" && exit_code=$? || exit_code=$?
exit "$exit_code"
