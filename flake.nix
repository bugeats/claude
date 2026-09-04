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
      formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);

      packages = eachSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ rust-overlay.overlays.default ];
          };
          lib = pkgs.lib;
          rust-toolchain = pkgs.rust-bin.stable.latest.default.override {
            extensions = [
              "rust-analyzer"
              "rust-src"
            ];
          };
          claude-code = claude-code-overlay.packages.${system}.claude;
          outputStyle =
            name: description: bodies:
            pkgs.writeText "${name}.md" ''
              ---
              name: ${name}
              description: ${description}
              keep-coding-instructions: true
              ---

              ${lib.concatMapStringsSep "\n" builtins.readFile bodies}
            '';
          manual =
            outputStyle "manual"
              "The Compression Principle and working contract; arcs run only when you invoke them"
              [
                ./prompts/containment.md
              ];
          auto =
            outputStyle "auto"
              "The manual style plus the arc workflow: automatic checkpoint and negentropy triggers"
              [
                ./prompts/containment.md
                ./prompts/arcs.md
              ];
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
          # rust-analyzer-mcp locates rust-analyzer via PATH; pin it to the toolchain.
          rust-analyzer-mcp-wrapped = pkgs.writeShellApplication {
            name = "rust-analyzer-mcp";
            runtimeInputs = [ rust-toolchain ];
            text = ''exec ${rust-analyzer-mcp}/bin/rust-analyzer-mcp "$@"'';
          };
          # Generated rather than checked in: a source-tree .mcp.json would be
          # loaded as a project-scope server in every session developing this repo.
          mcpConfig = pkgs.writeText ".mcp.json" (
            builtins.toJSON {
              mcpServers.rust-analyzer = {
                type = "stdio";
                command = "${rust-analyzer-mcp-wrapped}/bin/rust-analyzer-mcp";
              };
            }
          );
          # Scripts are installed under their source names so hooks.json and
          # skills reference them unchanged. `nix` itself is left to the host so
          # the client matches the daemon.
          scripts = {
            hooks = {
              nix-format = [
                pkgs.jq
                pkgs.nixfmt
              ];
              nix-guardian = [
                pkgs.jq
                pkgs.gnugrep
              ];
              rust-format = [
                pkgs.jq
                rust-toolchain
              ];
            };
            tools = {
              checkpoint-range = [
                pkgs.git
                pkgs.gawk
                pkgs.gnugrep
              ];
              nix-status = [
                pkgs.procps
                pkgs.gawk
                pkgs.findutils
              ];
            };
          };
          installScripts = lib.concatStrings (
            lib.flatten (
              lib.mapAttrsToList (
                dir:
                lib.mapAttrsToList (
                  name: runtimeInputs:
                  let
                    app = pkgs.writeShellApplication {
                      inherit name runtimeInputs;
                      text = builtins.readFile (./. + "/${dir}/${name}.sh");
                    };
                  in
                  "cp ${app}/bin/${name} $out/${dir}/${name}.sh\n"
                )
              ) scripts
            )
          );
          # Output styles are generated so the containment prose lives once in
          # prompts/ while shipping complete in both styles. Every path the
          # plugin needs is pinned here so the launcher exports no environment.
          plugin = pkgs.runCommand "arcs-plugin" { nativeBuildInputs = [ pkgs.python3 ]; } ''
            mkdir -p $out/hooks $out/tools $out/output-styles
            cd ${self}
            cp -r .claude-plugin skills style statusline.py settings.json $out/
            cp hooks/hooks.json $out/hooks/
            cp ${mcpConfig} $out/.mcp.json
            cp ${manual} $out/output-styles/manual.md
            cp ${auto} $out/output-styles/auto.md
            ${installScripts}
            chmod -R u+w $out
            substituteInPlace $out/settings.json --subst-var out
            patchShebangs $out/statusline.py
          '';
        in
        {
          inherit plugin;

          # The launcher pins the claude binary and supplies the model's shell
          # toolset. Plugin-internal tooling (hooks, tools, MCP, statusline) is
          # already path-pinned inside the plugin derivation.
          default = pkgs.writeShellApplication {
            name = "claude-arcs";
            runtimeInputs = [
              claude-code
              pkgs.coreutils
              pkgs.gh
              pkgs.git
              pkgs.gnugrep
              pkgs.jq
              pkgs.ripgrep
              rust-toolchain
            ];
            text = ''exec claude --plugin-dir ${plugin} --settings ${plugin}/settings.json "$@"'';
          };
        }
      );
    };
}
