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
            runtimeEnv = {
              MINIWI_FONT = "${miniwi-font}";
              FLAKE_SELF = "${self}";
              FLAKE_URI = flakeUri;
            };
            text = builtins.readFile ./bootstrap.sh;
          };
        }
      );
    };
}
