{
  description = "(a description of your package goes here)";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    # build for each default system of flake-utils: ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system ; };
        # declare OTP version via `erlang` attribute. If not, defaults to the latest on this channel.
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_27;
        # declare the Elixir version you want to use. If not, defaults to the latest on this channel.
        elixir = beamPackages.elixir_1_18;
        # import a development shell we'll declare in `shell.nix`.
        devShell = import ./shell.nix { inherit pkgs beamPackages; };

        my-elixir-app = let
            lib = pkgs.lib;
            # FIXME: import the Mix deps into Nix by running `mix2nix > deps.nix`
            # mixNixDeps = import ./deps.nix { inherit lib beamPackages; };
          in beamPackages.buildMix {
            name = "my-elixir-app";
            # Elixir app source path
            src = ./.;
            version = "0.1.0";
            # Add inputs to the build if you need to
            buildInputs = [ elixir ];
            #  FIXME: declare the nix paths of the mix dependencies from the mixNixDeps attr above.
            # beamDeps = builtins.attrValues mixNixDeps;
          };
      in
      {
        devShells.default = devShell;
        packages.default = my-elixir-app;
      }
    );
}

