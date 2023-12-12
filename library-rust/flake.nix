{
  description = "(a description of your package goes here)";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-23.11;
    flake-utils.url = github:numtide/flake-utils;
    rust-overlay.url = github:oxalica/rust-overlay;
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    # build for each default system of flake-utils: ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        # declare pkgs for the specific target system we're building for, with the rust overlay.
        pkgs = import nixpkgs { inherit system overlays; };
        # declare OTP version via `erlang` attribute. If not, defaults to the latest on this channel.
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;
        # declare the Elixir version you want to use. If not, defaults to the latest on this channel.
        elixir = beamPackages.elixir;
        # import a development shell we'll declare in `shell.nix`.
        devShell = import ./shell.nix { inherit pkgs beamPackages; };

        # Build the rust package
        my-rust-pkg = pkgs.rustPlatform.buildRustPackage {
            pname = "my-elixir-app";
            version = "0.0.1";
            # FIXME: Where the Rust code lives. For NIFs, this is usually native/my-rust-src
            src = "";
            # A hash that ensures we're getting the right src.
            # Get this hash by running `nix hash path native/my-rust-src`
            # Nix will attempt to verify this when building and tell you the hash it got vs what it expected
            cargoSha256 = "sha256-M9Uql8ekY/ipraRqdNyUzzbs+j8g0a2DjuLldWP3cWs=";
        };

        my-elixir-app = let
            lib = pkgs.lib;
            # FIXME: import the Mix deps into Nix by running `mix2nix > deps.nix`
            # mixNixDeps = import ./deps.nix { inherit lib beamPackages; };
          in beamPackages.buildMix {
            name = "";
            # Elixir app source path
            src = ./.;
            version = "0.1.0";
            # Add inputs to the build if you need to
            buildInputs = [ elixir ];
            #  FIXME: declare the nix paths of the mix dependencies from the mixNixDeps attr above.
            # beamDeps = builtins.attrValues mixNixDeps;

            # And now, tell Rustler about your Rust binary.
            # Before we configure and build the project,
            # create the priv/native dir, and copy the Rust binary we built above into it.
            # Then, modify the Rustler config to `skip_compilation` and tell it where to load the binary from.
            preConfigure = ''
              mkdir priv && mkdir priv/native
              cp ${my-rust-pkg}/lib/my-rust-pkg.so priv/native/

              substituteInPlace lib/my-elixir-app/native.ex --replace "crate: \"my-rust-pkg\"" """
                  crate: \"my-rust-pkg\",
                  skip_compilation?: true,
                  load_from: {:my-elixir-app, \"priv/native/my-rust-pkg\"}
                  \

              """
            '';
          };
      in
      {
        devShells.default = devShell;
        packages.default = my-elixir-app;
      }
    );
}

