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
            ];
            text = ''
              config_dir="$HOME/.claude"
              mkdir -p "$config_dir/skills" "$config_dir/hooks"

              ln -sf "${self}/settings.json" "$config_dir/settings.json"
              for skill in "${self}"/skills/*/; do
                ln -sfn "$skill" "$config_dir/skills/$(basename "$skill")"
              done
              ln -sf "${self}/statusline.py" "$config_dir/statusline.py"
              for hook in "${self}"/hooks/*.sh; do
                ln -sf "$hook" "$config_dir/hooks/$(basename "$hook")"
              done
              ln -sf "${self}/CLAUDE.system.md" "$HOME/CLAUDE.md"

              exec claude "$@"
            '';
          };
        }
      );
    };
}
