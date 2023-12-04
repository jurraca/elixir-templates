## Building a desktop release with Tauri

The `#release-desktop` template gives you boilerplate to build a desktop application from a Phoenix application with [Tauri](https://tauri.app/). I owe this method to Filipe Cabaco's [blog post](https://filipecabaco.com/post/2023-08-29_liveview_desktop_applications) and associated [ex_tauri](https://github.com/filipecabaco/ex_tauri/) Elixir library, which does this from a Mix build script.

From a Phoenix project directory, run `nix flake init -t github:jurraca/elixir-templates#release-desktop`.

There's some setup required (read the welcome [text](https://github.com/jurraca/elixir-templates/blob/8237e2fd490cfdb26a13de353f521b291cf73806/flake.nix#L117)). This template will add the following files and directories to your local project directory:
- `flake.nix` & `flake.lock`
- a `nix/` directory to hold Nix expressions to build the Tauri project, as well as `shell.nix`
- a `src-tauri` directory containing the Tauri cargo project, tailored slightly to our requirements. Usually, you would create this via running `cargo-tauri init` (see Tauri [docs](https://tauri.app/v1/api/cli#init)). We just provide the necessary files upfront for ease of use, as an input to the flake.

After running `nix build` successfully, the output desktop binary will be under `result/bin/myapp-desktop` in the project directory.

TODO:
- test on different targets
- handle RustlerPrecompiled deps
