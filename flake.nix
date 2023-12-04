{
  description = "A collection of flake templates for Elixir projects";

  outputs = { self }: {

    templates = {

      shell = {
        path = ./shell;
        description = "A simple flake which exposes a development shell.";
        welcomeText = ''
          ## Success!
          You just imported a flake template for an Elixir development shell.

          The shell includes the latest stable versions available from nixpkgs of `elixir`, `hex`, and the `mix2nix` utility.\
          It also sets env vars and local hex and mix folders to keep your development environment explicit and organized.\
          See the `flake.nix` file for details.

          Remember to add any file needed to build the project via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
        '';
      };

      release = {
        path = ./release;
        description = "A template to build Mix releases.";
        welcomeText = ''
          ## Success!
          You just imported a flake template for an Elixir project built with Mix.

          The output package is a Mix release.

          Remember to add any file needed to build the project via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
            - Run `nix build` to build the project
        '';
      };

      library = {
        path = ./library;
        description = "A template to compile Mix projects.";
        welcomeText = ''
          ## Success!
          You just imported a flake template for an Elixir project built with Mix.

          It will *not* provide a runtime with its outputs, only compile the project.\
          If you want to compile an executable (a Mix release), see the `#release` attribute of this flake.

          Remember to add any file needed to build the project via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
            - Run `nix build` to build the project
        '';
      };

      release-rust = {
        path = ./release-rust;
        description = "A template to build Mix releases for Elixir + Rust projects.";
        welcomeText = ''
          ## Success!
          You just imported a flake template for an Elixir + Rust project.

          The output package is a Mix release.\
          It includes boilerplate to build a Rust package and configure NIFs via Rustler.

          Remember to add any file needed to build the project via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
            - Run `nix build` to build the project
        '';
      };

      library-rust = {
        path = ./library-rust;
        description = "A template to compile Mix projects for Elixir + Rust projects.";
        welcomeText = ''
          ## Success!
          You just imported a flake template for an Elixir + Rust project.

          It will *not* provide a runtime with its outputs, only compile the project.\
          If you want to compile an executable (a Mix release), see the `#release-rust` attribute of this flake.
          Remember to add any Nix file to your source tree via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
            - Run `nix build` to build the project
        '';
      };

      phoenix = {
        path = ./phoenix;
        description = "A template to build Mix releases for Phoenix applications.";
        welcomeText = ''
          ## Success!
          You just imported a flake template for a Phoenix project.

          The output package is a Mix release.

          Remember to add any file needed to build the project via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
            - Run `nix build` to build the release
        '';
      };

      release-desktop = {
        path = ./release-desktop;
        description = "A template to build desktop applications from Phoenix applications with Tauri.";
        welcomeText = ''
          ## Success!
          You just imported a flake template for building a desktop version of a Phoenix app. \
          The output package is a desktop binary built via Tauri.

          There are a few configuration steps you'll need to complete before building: \
          - make sure you have a `mix.lock` file. If not, run `mix deps.get` \
          - `git add flake* nix src-tauri` \
          - open `flake.nix`, address the FIXMEs, namely: \
            - update the `appName` var to your Mix app name \
            - Enter a dev shell by running `nix develop` \
            - run `mix2nix > deps.nix` ; `git add deps.nix` \
          - Update the `MyApp.Endpoint` config in `config.exs` by adding `server: true`

          Run the build with `nix build` (add `-L` to see the logs).\
          This will take a while the first time, but less on subsequent runs.
          The result binary/ies will be under the `result/bin` in the main source path.

          Before running the binary, your environment must have a few values for a release to run:\
          `RELEASE_COOKIE`, `SECRET_KEY_BASE`, `PHX_HOST`, and, if you're using a database, `DATABASE_URL`.
          You can add these to an env file and source it before running the binary. You could also add these to the `shellHook` attribute in `shell.nix` and then run `nix develop`.
          See the Phoenix release [documentation](https://hexdocs.pm/phoenix/releases.html) for more.

          Remember to add any file needed to build the project via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
            - Run `nix build` to build the desktop binary
        '';
      };
    };

    defaultTemplate = self.templates.release;

  };
}