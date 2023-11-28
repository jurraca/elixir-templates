{
  description = "A collection of flake templates for Elixir projects";

  outputs = { self }: {

    templates = {

      shell = {
        path = ./shell;
        description = "A simple flake which exposes a development shell.";
        welcomeText = ''
            You just created a flake.nix template which provides a development shell.
            This shell includes: elixir 1.1x, mix, hex.
            Enter the shell by running `nix develop`.
        '';
      };

      release = {
        path = ./release;
        description = "A Mix release template using `mixRelease`";
        welcomeText = ''
          You just created a flake.nix template which builds a Mix release.
          Run `nix develop` to enter a development shell.
          Run `nix build` to build the release.
        '';
      };

      library = {
        path = ./library;
        description = "A template to compile Mix projects";
        welcomeText = ''
          You just created a flake.nix template which compiles a Mix project.
          It will not provide a runtime in its output.
          If you want to compile an executable (a Mix release), see the #release output of this flake.
          Run `nix develop` to enter a development shell.
          Run `nix build` to build the project.
        '';
      };

      release-rust = {
        path = ./release-rust;
        description = "A template to build Mix releases for Elixir + Rust projects";
        welcomeText = ''
          You just created a flake.nix template for an Elixir + Rust project.
          It includes a rust compiler and a `buildRustPackage` expression template to build the Rust portion of the project.
          Run `nix develop` to enter a development shell.
          Run `nix build` to build the release.
        '';
      };

      library-rust = {
        path = ./library-rust;
        description = "A template to compile Mix projects for Elixir + Rust";
        welcomeText = ''
          You just created a flake.nix template for an Elixir + Rust project.
          It will not provide a runtime in its output.
          If you want to compile an executable (a Mix release), see the #release output of this flake.
          Run `nix develop` to enter a development shell.
          Run `nix build` to build the project.
        '';
      };

      phoenix = {
        path = ./phoenix;
        description = "A Mix release template for the Phoenix web framework using `mixRelease`";
        welcomeText = ''
          You just created a flake.nix template for building a release for a Phoenix project.
          Run `nix develop` to enter a development shell.
          Run `nix build` to build the project.
        '';
      };
    };

    defaultTemplate = self.templates.release;

  };
}