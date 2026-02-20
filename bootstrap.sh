config_dir="$HOME/.claude"

ensure_config_dirs() {
  mkdir -p "$config_dir/skills" "$config_dir/hooks"
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

remove_managed_symlinks() {
  for f in "$config_dir/settings.json" "$config_dir/statusline.py" "$HOME/CLAUDE.md" \
           "$config_dir"/skills/*/ "$config_dir"/hooks/*.sh; do
    f="${f%/}"
    if [ -L "$f" ] && [[ "$(readlink "$f")" == /nix/store/* ]]; then rm "$f"; fi
  done
}

install_config() {
  ln -sf "$FLAKE_SELF/settings.json" "$config_dir/settings.json"
  for skill in "$FLAKE_SELF"/skills/*/; do
    ln -sfn "$skill" "$config_dir/skills/$(basename "$skill")"
  done
  ln -sf "$FLAKE_SELF/statusline.py" "$config_dir/statusline.py"
  for hook in "$FLAKE_SELF"/hooks/*.sh; do
    ln -sf "$hook" "$config_dir/hooks/$(basename "$hook")"
  done
  ln -sf "$FLAKE_SELF/CLAUDE.system.md" "$HOME/CLAUDE.md"
}

# shellcheck disable=SC2329
on_exit() {
  printf "\n  Cleaning up after myself ... "
  remove_managed_symlinks
  echo "ok"
  printf "\n  Come back any time:\n\n      nix run %s --refresh\n\n" "$FLAKE_URI"
}

ensure_config_dirs
ensure_identity
show_banner
trap on_exit EXIT
remove_managed_symlinks
install_config

claude "$@" && exit_code=$? || exit_code=$?
exit "$exit_code"
