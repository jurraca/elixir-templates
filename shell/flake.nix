{
  description = "An Elixir development shell.";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    # Build for each default system of flake-utils: ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"].
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Declare pkgs for the specific target system we're building for, with the rust overlay.
        pkgs = import nixpkgs { inherit system; };
        # Declare BEAM version we want to use. If not, defaults to the latest on this channel.
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_27;
        # Optional build inputs depending on system.
        opts =
         with pkgs; lib.optional stdenv.isLinux inotify-tools ++
          lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
            CoreServices
            Foundation
          ]);

        buildInputs =
          let
            inherit beamPackages;
            elixir = beamPackages.elixir_1_16;
            hex = beamPackages.hex;
            mix2nix = pkgs.mix2nix;
          in
          [
            elixir
            hex
            mix2nix
          ] ++ opts;

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
      in
      # output attributes
      {
        devShells.default = pkgs.mkShell {
          inherit
            buildInputs
            shellHook;
        };
      }
    );
}

