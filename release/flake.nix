{
  description = "(a description of your package goes here)";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.05;
    flake-utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, flake-utils }:
    # build for each default system of flake-utils: ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Declare pkgs for the specific target system we're building for.
        pkgs = import nixpkgs { inherit system ; };
        # Declare BEAM version we want to use. If not, defaults to the latest on this channel.
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_27;
        # Declare the Elixir version you want to use. If not, defaults to the latest on this channel.
        elixir = beamPackages.elixir_1_16;
        # Import a development shell we'll declare in `shell.nix`.
        devShell = import ./shell.nix { inherit pkgs beamPackages; };

        my-elixir-app = let
            lib = pkgs.lib;
            # FIXME: Import the Mix deps into Nix by running
            # mix2nix > nix/deps.nix
            # mixNixDeps = import ./deps.nix {inherit lib beamPackages;};
          in beamPackages.mixRelease {
            pname = "my-elixir-app";
            # Elixir app source path
            src = ./.;
            version = "0.1.0";

            # FIXME: mixNixDeps was specified in the FIXME above. Uncomment the next line.
            # inherit mixNixDeps;

            # Add other inputs to the build if you need to
            buildInputs = [ elixir ];
          };
      in
      {
        devShells.default = devShell;
        packages.default = my-elixir-app;
      }
    );
}

