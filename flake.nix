{
  description = "Claude Code configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    claude-code-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      claude-code-overlay,
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      eachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      packages = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          claude-code = claude-code-overlay.packages.${system}.claude;
          flakeUri = "github:bugeats/claude";
          miniwi-font = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/xero/figlet-fonts/main/miniwi.flf";
            hash = "sha256-t9cGfmVdIEbU5sldhMOGMYxh4mFCWLGBfaCtvvZw/dk=";
          };
        in
        {
          default = pkgs.writeShellApplication {
            name = "claude-bootstrap";
            runtimeInputs = [
              claude-code
              pkgs.jq
              pkgs.gnugrep
              pkgs.coreutils
              pkgs.git
              pkgs.ripgrep
              pkgs.python3
              pkgs.figlet
              pkgs.terminaltexteffects
            ];
            text = ''
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
                  echo "''${input:-$default_name}" > "$config_dir/identity"
                fi
              }

              show_banner() {
                local name
                name=$(cat "$config_dir/identity")
                clear
                figlet -f "${miniwi-font}" "$name ships clean code" | tte slide
                printf '\n  %s\n\n' "This Claude has superpowers. Say /school-me to learn more."
              }

              remove_managed_symlinks() {
                for f in "$config_dir/settings.json" "$config_dir/statusline.py" "$HOME/CLAUDE.md" \
                         "$config_dir"/skills/*/ "$config_dir"/hooks/*.sh; do
                  f="''${f%/}"
                  if [ -L "$f" ] && [[ "$(readlink "$f")" == /nix/store/* ]]; then rm "$f"; fi
                done
              }

              install_config() {
                ln -sf "${self}/settings.json" "$config_dir/settings.json"
                for skill in "${self}"/skills/*/; do
                  ln -sfn "$skill" "$config_dir/skills/$(basename "$skill")"
                done
                ln -sf "${self}/statusline.py" "$config_dir/statusline.py"
                for hook in "${self}"/hooks/*.sh; do
                  ln -sf "$hook" "$config_dir/hooks/$(basename "$hook")"
                done
                ln -sf "${self}/CLAUDE.system.md" "$HOME/CLAUDE.md"
              }

              # shellcheck disable=SC2329
              on_exit() {
                printf "\n  Cleaning up after myself ... "
                remove_managed_symlinks
                echo "ok"
                printf "\n  Come back any time:\n\n      nix run ${flakeUri} --refresh\n\n"
              }

              ensure_config_dirs
              ensure_identity
              show_banner
              trap on_exit EXIT
              remove_managed_symlinks
              install_config

              claude "$@" && exit_code=$? || exit_code=$?
              exit "$exit_code"
            '';
          };
        }
      );
    };
}
