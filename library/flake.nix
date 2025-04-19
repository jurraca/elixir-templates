{
  description = "(a description of your package goes here)";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-24.11;
  };

  outputs = { self, nixpkgs }: let
    overlay = prev: final: rec {
      # https://github.com/erlang/otp/security/advisories/GHSA-37cp-fgq5-7wc2
      erlang = prev.beam.interpreters.erlang_27.override {
        version = "27.3.3";
        sha256 = "sha256-OTCCfVeJADxKlmgk8rRE3uzY8Y9qYwY/ubiopWG/0ao=";
      };
      beamPackages = prev.beam.packagesWith erlang;
      elixir = beamPackages.elixir_1_18;
      hex = beamPackages.hex;
      final.mix2nix = prev.mix2nix.overrideAttrs {
        nativeBuildInputs = [ final.elixir ];
        buildInputs = [ final.erlang ];
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
        overlays = [overlay];
      };
    in {
    packages = forAllSystems(system: let
      pkgs = nixpkgsFor system;
      # FIXME: import the Mix deps into Nix by running `mix2nix > deps.nix` from a dev shell
      mixNixDeps = import ./deps.nix {
        lib = pkgs.lib;
        beamPackages = pkgs.beamPackages;
      };
      in rec {
        default = pkgs.beamPackages.buildMix {
            name = "my-elixir-lib";
            # Elixir lib source path
            src = ./.;
            version = "0.1.0";
            beamDeps = builtins.attrValues mixNixDeps;
	    # Add inputs to the build if you need to
            buildInputs = [ pkgs.elixir ];
	    buildPhase = ''
              runHook preBuild
              export HEX_HOME=".nix-hex";
              export MIX_HOME=".nix-mix";
              mix compile --no-deps-check
              runHook postBuild
	    '';
          };
      });

    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor system;
    in {
      default = pkgs.callPackage ./shell.nix {};
    });
  };
}

