{
  writeTextFile,
  appName,
  binaryPath,
  devURL
}: let
  tauri-conf-json = builtins.fromJSON (builtins.readFile ./../src-tauri/tauri.conf.json);
  bundle = tauri-conf-json.tauri.bundle // {"externalBin" = ["${binaryPath}"];} // {"identifier" = "dev.testproject.desktop";};
  allowlist =
    tauri-conf-json.tauri.allowlist
    // {
      "shell" = {
        "sidecar" = true;
        "scope" = [
          {
            "name" = "${appName}-desktop";
            "sidecar" = true;
            "args" = ["start"];
          }
        ];
      };
    };
  build =
    tauri-conf-json.build
    // {
      "devPath" = "${devURL}";
      "distDir" = "${devURL}";
    };
  tauri-attr =
    tauri-conf-json.tauri
    // {
      "bundle" = bundle;
      "allowlist" = allowlist;
    };
  conf-str = builtins.toJSON (tauri-conf-json
    // {
      "tauri" = tauri-attr;
      "build" = build;
    });
in
  writeTextFile {
    name = "tauri-conf-json";
    text = conf-str;
  }
