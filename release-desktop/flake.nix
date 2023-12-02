{
  description = "Packaging a Mix release as a Tauri desktop app.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    utils.url = "github:numtide/flake-utils";
    tauri-files = { url = "./src-tauri"; flake = false;};
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    tauri-files
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlangR25;
      lib = nixpkgs.lib;

      my-elixir-app = beamPackages.mixRelease {
        pname = "";
        src = ./.;
        #mixNixDeps = import ./deps.nix {inherit lib beamPackages;};
        version = "0.0.1";
        mixEnv = "dev";
        buildInputs = [ pkgs.tailwindcss pkgs.esbuild ];

        preConfigure = ''
          # Replace the tailwind and esbuild binaries with ones provided by nixpkgs
          # Optionally, update the versions in config.exs in order to silence a warning about mismatched versions
          # The command will fail if it can't find those versions, so remove those "replace" lines, or
          # update them according to your mix.exs tailwind and esbuild versions
          substituteInPlace config/config.exs \
            --replace "config :tailwind," "config :tailwind, path: \"${pkgs.tailwindcss}/bin/tailwindcss\"," \
            --replace "version: \"3.1.8\"" "version: \"${pkgs.tailwindcss.version}\"" \
            --replace "config :esbuild," "config :esbuild, path: \"${pkgs.esbuild}/bin/esbuild\", " \
            --replace "version: \"0.14.41\"" "version: \"${pkgs.esbuild.version}\""

       '';

        # Deploy assets before creating release
        preInstall = ''
         # https://github.com/phoenixframework/phoenix/issues/2690
          mix do deps.loadpaths --no-deps-check, assets.deploy
        '';

        postInstall = ''
          # Tauri will look for app names + their system triplet, so we must rename the output bin accordingly
          # wrapProgram $out/bin/testproject --set RELEASE_COOKIE="" SECRET_KEY_BASE=$(mix phx.gen.secret)
          mv $out/bin/testproject $out/bin/testproject-x86_64-unknown-linux-gnu
        '';
      };

      desktop = import ./taurize.nix {
        inherit pkgs system;
        appName = my-elixir-app.pname ;
        src = tauri-files;
        binaryPath = my-elixir-app.out + "/bin/" + my-elixir-app.pname;
        host = "localhost";
        port = "4000";
      };
    in rec {
      defaultPackage = desktop;
      devShell = self.devShells.${system}.dev;
      devShells = {
        dev = import ./shell.nix {inherit pkgs;};
      };
    });
}
