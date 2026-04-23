{...}: {
  flake.nixosModules."hosts.u" = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    users.users.thou = {
      uid = 1000;
      isNormalUser = true;
      custom = {
        core = {
          shellAliases = {};
          variables = {};
        };
        wrappers = {
          helix.enable = true;
          atuin = {
            enable = true;
            daemon.enable = true;
            initFlags = ["--disable-up-arrow"];
          };
          fish = {
            enable = true;
            loadSystemEnvironment = true;
            shellAbbrs = config.users.users.thou.custom.core.shellAliases;
            variables = config.users.users.thou.custom.core.variables;
          };
          prismlauncher.enable = true;
        };
      };
      description = "thou";
      extraGroups = ["home-manager" "networkmanager" "wheel"];
      packages =
        (with pkgs; [
          azahar
          bc
          cemu
          distrobox
          dolphin-emu
          gcc
          imagemagick
          krita
          libreoffice
          mame
          mangohud
          melonds
          mgba
          pcsx2
          protonplus
          qbittorrent
          rclone
          ripgrep
          typst
          vlc
          xdg-utils
          yazi
          zathura
        ])
        ++ [
          inputs'.nix-packages.legacyPackages.discord-rpc-lsp
        ];
      password = "123";

      shell = config.users.users.thou.custom.wrappers.fish.wrapper;
    };
  };
}
