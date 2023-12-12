{
  description = "A flake template for Phoenix 1.7 projects.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
  # build for each default system of flake-utils: ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
    utils.lib.eachDefaultSystem (
      system: let
        # Declare pkgs for the specific target system we're building for.
        pkgs = import nixpkgs {inherit system;};
        # Declare BEAM version we want to use. If not, defaults to the latest on this channel.
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;
        # Declare the Elixir version you want to use. If not, defaults to the latest on this channel.
        elixir = beamPackages.elixir;
        # Import a development shell we'll declare in `shell.nix`.
        devShell = import ./shell.nix {inherit pkgs beamPackages;};

        my-phx-app = let
          lib = pkgs.lib;
          # FIXME: Import the Mix deps into Nix by running
          # mix2nix > nix/deps.nix
          # mixNixDeps = import ./deps.nix {inherit lib beamPackages;};
        in
          beamPackages.mixRelease {
            pname = "my-phx-app";
            # Elixir app source path
            src = ./testproj;
            version = "0.1.0";
            # FIXME: mixNixDeps was specified in the FIXME above. Uncomment the next line.
            # inherit mixNixDeps;

            # Add inputs to a release build. We need elixir (it's implied but you can specify a version here)
            # add esbuild and tailwindcss
            buildInputs = [ elixir pkgs.esbuild pkgs.tailwindcss ];

            # Explicitly declare tailwind and esbuild binary paths (don't let Mix fetch them)
            preConfigure = ''
              substituteInPlace config/config.exs \
                --replace "config :tailwind," "config :tailwind, path: \"${pkgs.tailwindcss}/bin/tailwindcss\","\
                --replace "config :esbuild," "config :esbuild, path: \"${pkgs.esbuild}/bin/esbuild\", "

            '';

            # Deploy assets before creating release
            preInstall = ''
             # https://github.com/phoenixframework/phoenix/issues/2690
              mix do deps.loadpaths --no-deps-check, assets.deploy
            '';
          };
      in {
        defaultPackage = my-phx-app;

        devShell = self.devShells.${system}.dev;
        devShells = {
          dev = import ./shell.nix {
            inherit pkgs beamPackages;
            dbName = "db_dev";
            mixEnv = "dev";
          };
          test = import ./shell.nix {
            inherit pkgs beamPackages;
            dbName = "db_test";
            mixEnv = "test";
          };
          prod = import ./shell.nix {
            inherit pkgs beamPackages;
            dbName = "db_prod";
            mixEnv = "prod";
          };
        };
        apps.my-phx-project = utils.lib.mkApp {drv = my-phx-app;};
      }
    );
}
