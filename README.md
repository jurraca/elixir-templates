## README

A set of Nix flake templates for Elixir projects.

The motivation for this project came out of seeing more projects use Elixir with Rust (i.e. using NIFs via Rustler). I think this pattern will continue, and if it's likely that we'll live in a mixed Elixir/Rust world, a few questions came up:
- how to build such projects?
- how to provide the best way for devs to get started on such a project, so they don't spend hours installing toolchains?
- how to make these builds transparent and introspect-able without extending Mix?

and some observations:
- Mix is _really_ good, and shouldn't have to be extended to work with Cargo. From a design perspective, adding functionality like this to Mix may end up over-burdening a great tool. Declaring custom build scripts for each project also puts more burden on the maintainer to support various platforms, and less time working on the codebase itself.
- We have to go a level of abstraction above. Are there build tools that can handle (or coordinate) both build tools (Mix and Cargo), of which there is really one: Nix.
- Docker's usually the go-to solution, but it's overkill for developer environments. I shouldn't have to ship a whole image to recreate a multi-language dev env (or release binaries for that matter).

As a solution, Nix gives us:
- declarative development environments
- declarative build recipes for Mix releases and libraries, with or without Rust
- Nix handles building the Rust package in isolation, and provides the binary to the `mix release` step
- Nix is already used by some projects doing Rust + Elixir
- pinned versions and checksums gives us security and repeatability
- user could modify templates without too much trouble
- "just works", one-command developer onboarding (`nix develop`, `nix build`)

Hence these templates.

## Usage

Importing a template with `nix flake init -t` is part the Nix flake CLI, so you must have flakes [enabled](./enable-flakes.md).

This repo's flake exposes several templates. For example, to import the `shell` template, run:
```bash
nix flake init -t github:jurraca/elixir-templates#shell
```

This will import the `flake.nix` template located at `shell/flake.nix` to your current path. You can specify which one to import with the `#` at the end of the template repo location, as shown above. That's how we resolve paths to output attributes of a flake in Nix.

To see what templates are available, run:
```
nix flake show github:jurraca/elixir-templates
```

If you're unsure what outputs are available after you import the flake, you can run:
```bash
nix flake show .
```

Feel free to create an issue for questions or comments. PRs welcome!