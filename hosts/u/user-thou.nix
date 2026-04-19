{...}: {
  flake.nixosModules."hosts.u" = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    custom = {
      core.users.thou = {
        shellAliases = {};
        variables = {};
      };

      wrappers = {
        atuin.users.thou = {
          enable = true;
          daemon.enable = true;
          initFlags = ["--disable-up-arrow"];
        };
        fish.users.thou = {
          enable = true;
          loadSystemEnvironment = true;
          shellAbbrs = config.custom.core.users.thou.shellAliases;
          variables = config.custom.core.users.thou.variables;
        };
        prismlauncher.users.thou.enable = true;
      };
    };

    users.users.thou = {
      uid = 1000;
      isNormalUser = true;
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

      shell = config.custom.build.wrappers.fish.users.thou.outPackage;
    };
  };
}
