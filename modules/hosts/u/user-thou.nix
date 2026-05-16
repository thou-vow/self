{installWrappers, self, ...}: {
  flake.nixosModules.u = {
    config,
    inputs',
    pkgs,
    system,
    ...
  }: {
    imports =
      [
        (installWrappers system {
          method.nixosUser.user = "thou";
          wrappers = {
            inherit
              (self.wrappers)
              atuin
              direnv
              git
              helix
              kitty
              niri
              nushell
              prismlauncher
              ;
          };
        })
      ]
      ++ map (m: m "thou")
      (with self.nixosUserModules; [prefs]);

    wrappers.users.thou = {
      atuin.daemon.systemd.enable = true;
      nushell = {
        environmentVariables = config.ext.users.thou.prefs.environmentVariables;
        shellAliases = config.ext.users.thou.prefs.shellAliases;
      };
      git.settings.user = {
        email = "thou.vow.etoile@gmail.com";
        name = "thou-vow";
      };
    };

    ext.users.thou = {
      prefs = {
        environmentVariables = {};
        shellAliases = {};
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
          geminicommit
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
      shell = config.wrappers.users.thou.nushell.wrapper;
    };
  };
}
