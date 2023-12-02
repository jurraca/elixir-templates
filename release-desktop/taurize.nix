{
  pkgs,
  system,
  src,
  binaryPath,
  appName,
  host,
  port
}: let
  devURL = "http://${host}:${port}";
  writeTextFile = pkgs.writeTextFile;
  # The main Rust entrypoint script
  main-rs = import ./main-rs.nix {inherit writeTextFile appName host port;};
  # The Tauri conf file
  conf-file = import ./tauri-conf.nix { inherit writeTextFile appName binaryPath devURL; };

in pkgs.rustPlatform.buildRustPackage rec {
  pname = "${appName}";
  version = "0.1";

  inherit src;
  cargoLock.lockFile = ./src-tauri/Cargo.lock;
  cargoHash = "sha256-LLPz78T6D9IaCWim7y7zgTTcVQRz8XO9s+H5qDqeWko=";

  buildInputs = with pkgs; [
    cargo-tauri
    rustc
    libsoup
    librsvg
    cairo
    gtk3
    webkitgtk
    pkg-config
  ];

    nativeBuildInputs = with pkgs; [ pkg-config ];

    doCheck = false;

    preConfigure = ''
        # Copy the tauri conf generated above
        cp ${conf-file} tauri.conf.json

        # Copy the updated main.rs generated above
        cp ${main-rs} src/main.rs
        # not sure why this has to be like this
        cp build.rs src/build.rs

        substituteInPlace Cargo.toml \
          --replace 'name = "app"' 'name = "${appName}-desktop"' \
          --replace 'default-run = "app"' 'default-run = "${appName}-desktop"'

        substituteInPlace Cargo.lock \
          --replace 'name = "app"' 'name = "${appName}-desktop"'
    '';
}
