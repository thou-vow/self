{...}: {
  flake.nixosModules."hosts.u" = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    custom.users.thou = {
      core = {
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
          shellAbbrs = config.custom.users.thou.core.shellAliases;
          variables = config.custom.users.thou.core.variables;
        };
        prismlauncher.enable = true;
      };
    };

    users.users.thou = {
      uid = 1000;
      isNormalUser = true;
      description = "thou";
      extraGroups = ["home-manager" "networkmanager" "wheel"];
      password = "123";
      shell = config.custom.users.thou.wrappers.fish.wrapper;
    };
  };
}
