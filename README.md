## README

A set of Nix flake templates for Elixir projects.

## Usage

Importing a template with `nix flake init -t` is part the Nix flake CLI, so you must have flakes [enabled](./enable-flakes.md).

This repo's flake exposes several templates. For example, to import the `shell` template, run:
```bash
nix flake init -t github:jurraca/elixir-templates#shell
```

This will import the `flake.nix` template located at `shell/flake.nix` to your current path. You can specify which one to import with the `#` at the end of the template repo location, as shown above. That's the syntax to resolve output attribute paths of a flake in Nix.

To see what templates are available, run:
```
nix flake show github:jurraca/elixir-templates
```

If you're unsure what outputs are available after you import the flake, you can run:
```bash
nix flake show .
```

Feel free to create an issue for questions or comments. PRs welcome!

## Motivation

The motivation for this project came out of seeing more projects use Elixir with Rust (for example, using NIFs via Rustler). I think this pattern will continue, and, if it's likely that we'll live in a mixed Elixir/Rust world, a few questions came up:
- how to build such projects?
- how to provide the best way for devs to get started on such a project, so they don't spend hours installing toolchains?
- how to make these builds transparent and introspect-able without extending Mix?

and some observations:
- Mix is _really_ good, and shouldn't have to be extended to work with Cargo. From a design perspective, adding functionality like this to Mix may end up over-burdening a great tool. Besides, writing custom build scripts for each project also puts more burden on the maintainer to support various platforms, and less time working on the codebase itself.
- We have to go a level of abstraction above. Are there build tools that can handle (or coordinate) both build tools, Mix and Cargo?
- Docker's usually the go-to solution, but it's overkill for developer environments. I shouldn't have to ship a whole image to recreate a multi-language dev env (or release binaries for that matter).

As one possible solution, Nix provides:
- declarative development environments
- declarative build recipes for Mix releases and libraries, with or without Rust
- a tool already used by some projects doing Rust + Elixir
- a functional-friendly language to compose and modify packages
- one-command setup (`nix develop`, `nix build`). "just works".

Hence these templates.
