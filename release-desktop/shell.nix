{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [
    cargo
    rustc
    cargo-tauri
    pkg-config
    libsoup
    librsvg
    cairo
    gtk3
    webkitgtk

    elixir
    esbuild
    sqlite # or postgresql
    inotify-tools

    mix2nix
  ];
}
