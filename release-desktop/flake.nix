{
  description = "Packaging a Mix release as a Tauri desktop app.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
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
      beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang_27;
      lib = nixpkgs.lib;

      # FIXME: put Mix app name
      appName = "";

      my-elixir-app = beamPackages.mixRelease {
        pname = appName;
        src = ./.;
        # FIXME: before building, you must create a deps.nix by running `mix2nix > deps.nix`
        # then `git add deps.nix`
        # mixNixDeps = import ./deps.nix {inherit lib beamPackages;};
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
          mv $out/bin/${appName} $out/bin/${appName}-x86_64-unknown-linux-gnu
        '';
      };

      desktop = import ./nix/taurize.nix {
        inherit pkgs system appName;
        src = tauri-files;
        binaryPath = my-elixir-app.out + "/bin/" + my-elixir-app.pname;
        host = "localhost";
        port = "4000";
      };
    in rec {
      packages.default = desktop;
      devShells.default = self.devShells.${system}.dev;
      devShells = {
        dev = import ./nix/shell.nix {inherit pkgs;};
      };
    });
}
