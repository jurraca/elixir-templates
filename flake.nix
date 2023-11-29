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

          Remember to add any Nix file to your source tree via `git add`.

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

          The output package is a Mix release.\
          Remember to add any Nix file to your source tree via `git add`.

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
          Remember to add any Nix file to your source tree via `git add`.

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
          It includes boilerplate to build a Rust package and configure NIFs via Rustler.\
          Remember to add any Nix file to your source tree via `git add`.

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

          The output package is a Mix release.\
          Remember to add any Nix file to your source tree via `git add`.

          ## Usage
            - Run `nix develop` to enter a development shell
            - Run `nix build` to build the release
        '';
      };
    };

    defaultTemplate = self.templates.release;

  };
}