{
  description = "Claude Code configuration";

  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1";
    claude-code-overlay.url = "github:ryoppippi/claude-code-overlay";
    claude-code-overlay.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      claude-code-overlay,
      rust-overlay,
    }:
    let
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
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
            overlays = [ rust-overlay.overlays.default ];
          };
          rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-analyzer"
              "rust-src"
            ];
          };
          claude-code = claude-code-overlay.packages.${system}.claude;
          flakeUri = "github:bugeats/claude";
          miniwi-font = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/xero/figlet-fonts/main/miniwi.flf";
            hash = "sha256-t9cGfmVdIEbU5sldhMOGMYxh4mFCWLGBfaCtvvZw/dk=";
          };
          rust-analyzer-mcp = pkgs.rustPlatform.buildRustPackage rec {
            pname = "rust-analyzer-mcp";
            version = "0.2.0";

            src = pkgs.fetchFromGitHub {
              owner = "zeenix";
              repo = "rust-analyzer-mcp";
              rev = "v${version}";
              hash = "sha256-brnzVDPBB3sfM+5wDw74WGqN5ahtuV4OvaGhnQfDqM0=";
            };

            cargoHash = "sha256-7t4bjyCcbxFAO/29re7cjoW1ACieeEaM4+QT5QAwc34=";
            cargoBuildFlags = [
              "--package"
              "rust-analyzer-mcp"
            ];
            # upstream tests require a live rust-analyzer + project fixtures
            doCheck = false;
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
              rust-toolchain
              rust-analyzer-mcp
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
