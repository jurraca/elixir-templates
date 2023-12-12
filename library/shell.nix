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
      hex = beamPackages.hex;
    in
    [
      elixir
      mix2nix
      hex
      rebar3
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
