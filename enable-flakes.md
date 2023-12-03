## Enabling Flakes


If you don't have flakes enabled on your system:
- and you don't want to have them enabled permanently, add the following flag after every Nix CLI command:
    ```
     --experimental-features 'nix-command flakes'
    ```
- and you want to enable them, add the following to `~/.config/nix/nix.conf` or `/etc/nix/nix.conf`:
    ```
    experimental-features = nix-command flakes
    ```
- and if you use NixOS and you want to enable them, add the following to your system config:
    ```
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    ```