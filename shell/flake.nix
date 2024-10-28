{
  description = "An Elixir development shell.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    overlays = [
      (final: prev: let
        beamPkgs = final.beam.packagesWith final.beam.interpreters.erlang_27;
      in rec {
        elixir = beamPkgs.elixir_1_16;
        hex = beamPkgs.hex;
      })
    ];

    forAllSystems = function:
      nixpkgs.lib.genAttrs supportedSystems
      (system:
        function {
          pkgs = import nixpkgs {inherit overlays system;};
        });
  in {
    devShells = forAllSystems (
      {pkgs}: {
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
