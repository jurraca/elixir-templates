{
  description = "(a description of your package goes here)";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
    flake-utils.url = github:numtide/flake-utils;
    rust-overlay.url = github:oxalica/rust-overlay;
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    # build for each default system of flake-utils: ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"]
    flake-utils.lib.eachDefaultSystem (system:
      let
        # After evaluating the nixpkgs set, we'll overlay the rust toolchain
        # provided by the "rust-overlay" flake input and use that.
        overlays = [ (import rust-overlay) ];
        # Declare pkgs for the specific target system we're building for, with the overlay.
        pkgs = import nixpkgs { inherit system overlays; };
        # Declare BEAM version we want to use. If not, defaults to the latest on this channel.
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_27;
        # Declare the Elixir version you want to use. If not, defaults to the latest on this channel.
        elixir = beamPackages.elixir_1_18;
        # Import a development shell we'll declare in `shell.nix`.
        devShell = import ./shell.nix { inherit pkgs beamPackages; };

        # Build the rust package
        my-rust-pkg = pkgs.rustPlatform.buildRustPackage {
            # Fill these out
            pname = "";
            version = "";
            # Where the Rust code lives. For NIFs, this is usually native/my-rust-src
            src = "";
            # A hash that ensures we're getting the right src.
            # Get this hash by running `nix hash path native/my-rust-src`
            # Nix will attempt to verify this when building and tell you the hash it got vs what it expected
            cargoHash = "sha256-M9Uql8ekY/ipraRqdNyUzzbs+j8g0a2DjuLldWP3cWs=";
        };

        my-elixir-app = let
            lib = pkgs.lib;
            # FIXME: import the Mix deps into Nix by running `mix2nix > deps.nix`
            # mixNixDeps = import ./deps.nix { inherit lib beamPackages; };
          in beamPackages.mixRelease {
            pname = "my-elixir-app";
            # Elixir app source path
            src = ./.;
            version = "0.1.0";
            # FIXME: mixNixDeps was specified in the FIXME above. Uncomment the next line.
            # inherit mixNixDeps;

            # Uncomment the next line to add inputs to the build if you need to
            # We specify elixir 1_14 (declared above)
            buildInputs = [ elixir ];

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
                  load_from: {:k256, \"priv/native/my-rust-pkg\"}
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

