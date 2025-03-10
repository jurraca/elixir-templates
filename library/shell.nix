{
  pkgs,
  lib
}: let
  # define packages to install
  basePackages = with pkgs; [
    elixir
    hex
    mix2nix
  ];
in
  pkgs.mkShell {
    # Add basePackages + optional system packages per system
    buildInputs = with pkgs;
      basePackages
      ++ lib.optionals stdenv.isLinux [inotify-tools]
      ++ lib.optionals stdenv.isDarwin
      (with darwin.apple_sdk.frameworks; [CoreFoundation CoreServices]);

    # define shell startup command
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
  }
