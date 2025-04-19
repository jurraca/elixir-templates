{
  description = "An Elixir development shell.";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;

  outputs = {
    self,
    nixpkgs,
  }: let
    overlay = prev: final: rec {
      erlang = prev.beam.interpreters.erlang_27.override {
        version = "27.3.3";
        sha256 = "sha256-OTCCfVeJADxKlmgk8rRE3uzY8Y9qYwY/ubiopWG/0ao=";
      };
      beamPackages = prev.beam.packagesWith erlang;
      elixir = beamPackages.elixir_1_18;
      hex = beamPackages.hex;
      final.mix2nix = prev.mix2nix.overrideAttrs {
        nativeBuildInputs = [final.elixir];
        buildInputs = [final.erlang];
      };
    };

    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    nixpkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [overlay];
      };
  in {
    devShells = forAllSystems (
      system: let
        pkgs = nixpkgsFor system;
      in {
        default = let
          opts = with pkgs;
            lib.optional stdenv.isLinux inotify-tools
            ++ lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
              CoreServices
              Foundation
            ]);
        in
          pkgs.mkShell {
            packages = with pkgs; [elixir hex mix2nix] ++ opts;
            shellHook = ''
              # Set up `mix` to save dependencies to the local directory
              mkdir -p .nix-mix
              mkdir -p .nix-hex
              export MIX_HOME=$PWD/.nix-mix
              export HEX_HOME=$PWD/.nix-hex
              export PATH=$MIX_HOME/bin:$PATH
              export PATH=$HEX_HOME/bin:$PATH

              # BEAM-specific
              export LANG=en_US.UTF-8
              export ERL_AFLAGS="-kernel shell_history enabled"
            '';
          };
      }
    );
  };
}
