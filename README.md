## Elixir Templates for Nix

A set of Nix flake templates for Elixir projects.

These flakes provide a development shell and a build recipe for Mix projects under their various guises: a Mix release, a Mix project that compiles a Rust NIF, a Phoenix project, or even a desktop release of a Phoenix project.

The goal is to give developers a standard template for managing their Mix projects with Nix, and reduce the cost of maintaining build instructions for every platform for your projects.

**Status**: Beta. Only tested on `x86_64-linux`. Shells probably work for all architectures.

## Requirements

You'll need [Nix](https://nixos.org/download.html), and you'll need to have flakes [enabled](./enable-flakes.md). You can read more about flakes [here](https://zero-to-nix.com/concepts/flakes).

## Usage

This repo's flake exposes several templates. For example, to import the `shell` template, run:
```bash
nix flake init -t github:jurraca/elixir-templates#shell
```

This will import the `flake.nix` template located at `shell/flake.nix` to your current path, i.e. create `flake.nix`, `flake.lock`, and `shell.nix` files.

You can specify which template to import with the `#` at the end of the template repo location, as shown above. That's the syntax to resolve output attribute paths of a flake in Nix.

To see what templates are available, run:
```
nix flake show github:jurraca/elixir-templates
```

If you're unsure what outputs are available after you import the flake, you can run:
```bash
nix flake show .
```

#### Configuration

Once you've added a flake to your project, you'll want to configure a few things. The `flake.nix` has FIXMEs which you should address before the package can be built. The main one involves turning your Mix deps into Nix deps via the following commands:
```
# Enter a dev shell
nix develop
# nixify the deps
mix2nix > deps.nix
# make git aware of the new file
git add deps.nix
```

The rest is probably optional:
- replace-all the placeholder app name (`my-elixir-app`, `my-rust-pkg`)
- update the `version` attribute to your app version
- if attempting to build a Rust package, you'll need to fetch the cargo hash and update it
- specify the Erlang/OTP version or Elixir version you want to use (if not the nixos 23.11 defaults: OTP `25.3.2.7` and Elixir `1.15.7`)

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

Feel free to create an issue for questions or comments. PRs welcome!
