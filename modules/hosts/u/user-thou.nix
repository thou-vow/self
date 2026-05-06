{self, ...}: {
  flake.nixosModules.u = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports =
      [
        (self.lib.mkInstallWrappers {
          method = {
            variant = "nixosUser";
            user = "thou";
          };
          wrappers = {
            inherit
              (self.wrappers)
              atuin
              direnv
              fish
              helix
              kitty
              niri
              prismlauncher
              ;
          };
        })
      ]
      ++ map (m: m "thou")
      (with self.nixosUserModules; [prefs]);

    wrappers.users.thou = {
      atuin.daemon.enable = true;
      fish = {
        shellAbbrs = config.ext.users.thou.prefs.shellAliases;
        variables = config.ext.users.thou.prefs.variables;
      };
    };

    ext.users.thou = {
      prefs = {
        shellAliases = {};
        variables = {};
      };
    };

    users.users.thou = {
      uid = 1000;
      isNormalUser = true;
      description = "thou";
      extraGroups = ["networkmanager" "wheel"];
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
          inputs'.nix-packages.packages.discord-rpc-lsp
        ];
      password = "123";
      shell = config.wrappers.users.thou.fish.wrapper;
    };
  };
}
