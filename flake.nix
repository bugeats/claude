{
  description = "Claude Code configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
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
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.writeShellScriptBin "claude-bootstrap" ''
            set -euo pipefail

            config_dir="$HOME/.claude"
            mkdir -p "$config_dir/skills" "$config_dir/hooks"

            ln -sf "${self}/settings.json" "$config_dir/settings.json"
            ln -sfn "${self}/skills/negentropy" "$config_dir/skills/negentropy"
            ln -sfn "${self}/skills/checkpoint" "$config_dir/skills/checkpoint"
            ln -sfn "${self}/skills/nix-build" "$config_dir/skills/nix-build"
            ln -sf "${self}/hooks/nix-format.sh" "$config_dir/hooks/nix-format.sh"
            ln -sf "${self}/hooks/nix-guardian.sh" "$config_dir/hooks/nix-guardian.sh"
            ln -sf "${self}/CLAUDE.system.md" "$HOME/CLAUDE.md"

            exec claude "$@"
          '';
        }
      );
    };
}
