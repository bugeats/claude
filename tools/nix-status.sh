# Show active nix build processes and sandbox directories.

show_nix_commands() {
  local found=false

  while IFS= read -r line; do
    if [ "$found" = false ]; then
      echo "Active nix commands:"
      found=true
    fi

    local pid elapsed args
    pid=$(awk '{print $1}' <<< "$line")
    elapsed=$(awk '{print $2}' <<< "$line")
    args=$(cut -d' ' -f3- <<< "$line")

    printf '  %s (pid %s, %s)\n' "$args" "$pid" "$elapsed"
  done < <(
    pgrep -a -f '\bnix (build|develop|run|shell|flake)\b' \
      | grep -v -e "nix-status" -e "shell-snapshots" \
      | while IFS= read -r pline; do
          local match_pid match_elapsed
          match_pid=$(awk '{print $1}' <<< "$pline")
          match_elapsed=$(ps -o etime= -p "$match_pid" 2>/dev/null || echo "?")
          echo "$match_pid $match_elapsed $(cut -d' ' -f2- <<< "$pline")"
        done \
      || true
  )

  if [ "$found" = false ]; then
    echo "No active nix commands."
  fi
}

show_sandbox_builds() {
  local dirs
  dirs=$(find /tmp -maxdepth 1 -name 'nix-build-*' -type d 2>/dev/null || true)

  if [ -z "$dirs" ]; then
    return
  fi

  echo ""
  echo "Sandbox build directories:"

  while IFS= read -r dir; do
    local name
    name=$(basename "$dir")
    name="${name#nix-build-}"

    local age now minutes_ago
    age=$(stat --format='%Y' "$dir" 2>/dev/null || echo "0")
    now=$(date +%s)
    minutes_ago=$(( (now - age) / 60 ))

    if [ "$minutes_ago" -gt 0 ]; then
      printf '  %s (~%sm ago)\n' "$name" "$minutes_ago"
    else
      printf '  %s (<1m ago)\n' "$name"
    fi
  done <<< "$dirs"
}

show_daemon_builders() {
  local daemon_pid
  daemon_pid=$(pgrep -x nix-daemon 2>/dev/null | head -1 || true)

  if [ -z "$daemon_pid" ]; then
    return
  fi

  local children
  children=$(pgrep -P "$daemon_pid" 2>/dev/null || true)

  if [ -z "$children" ]; then
    return
  fi

  printf '\nDaemon worker processes: %s active\n' "$(wc -l <<< "$children")"
}

show_nix_commands
show_sandbox_builds
show_daemon_builders
