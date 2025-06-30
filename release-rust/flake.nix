{
  description = "(a description of your package goes here)";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-25.05;
    rust-overlay.url = github:oxalica/rust-overlay;
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
  }: let
    overlay = prev: final: rec {
      beamPackages = prev.beam.packagesWith prev.beam.interpreters.erlang_27;
      elixir = beamPackages.elixir_1_18;
      erlang = prev.erlang_27;
      hex = beamPackages.hex;
      final.mix2nix = prev.mix2nix.overrideAttrs {
        nativeBuildInputs = [final.elixir];
        buildInputs = [final.erlang];
      };
    };

    forAllSystems = nixpkgs.lib.genAttrs [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];

    nixpkgsFor = system:
      import nixpkgs {
        inherit system;
        overlays = [overlay (import rust-overlay)];
      };
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor system;
      # FIXME: import the Mix deps into Nix by running `mix2nix > deps.nix` from a dev shell
      #mixNixDeps = import ./deps.nix {
      #  lib = pkgs.lib;
      #  beamPackages = pkgs.beamPackages;
      #};

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
    in rec {
      default = pkgs.beamPackages.mixRelease {
        pname = "my-elixir-lib";
        # Elixir lib source path
        src = ./.;
        version = "0.1.0";

        # FIXME: once you've addressed the fixme comment above,
        # uncomment the following line to include mixNixDeps
        # inherit mixNixDeps;

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

        # Add inputs to the build if you need to
        buildInputs = [pkgs.elixir];
      };
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor system;
    in {
      default = pkgs.callPackage ./shell.nix {};
    });
  };
}
