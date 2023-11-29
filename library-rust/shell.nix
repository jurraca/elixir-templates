{ pkgs, beamPackages }:

with pkgs; let

  opts =
    lib.optional stdenv.isLinux inotify-tools ++
    lib.optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      CoreServices
      Foundation
    ]);

  buildInputs =
    let
      inherit beamPackages;
      elixir = beamPackages.elixir;
      elixir_ls = beamPackages.elixir-ls.override { inherit elixir; };
      hex = beamPackages.hex;
    in
    [
      elixir
      elixir_ls
      mix2nix
      hex
      rust-bin.stable.latest.minimal
      cargo
      cargo-watch
    ] ++ opts;

  shellHook = ''
    # Set up `mix` to save dependencies to the local directory
    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH

    # Beam-specific
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"
  '';

in
mkShell {
  inherit
    buildInputs
    shellHook;
}
