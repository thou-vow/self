{
  lib,
  self,
  ...
}: {
  flake.nixosPresets."!u" = _: {
    hjem.users.thou = lib.mkMerge [
      self.hjemPresets."!thou@u"
    ];
  };

  flake.hjemPresets."!thou@u" = {
    config,
    inputs',
    osConfig,
    pkgs,
    specialisation,
    ...
  }: {
    imports = [
      (self.lib.installWrappers {
        method.hjem = true;
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
            starship
            ;
        };
        extraWrapperIntegrations =
          (with self.wrapperIntegrationModules; [
            preferences
          ])
          ++ (with self.wrapperIntegrationPresets; [
            preferencesTheme
          ]);
      })
    ];

    wrappers = {
      atuin.daemon.systemd.enable = true;
      git.settings.user = {
        email = "thou.vow.etoile@gmail.com";
        name = "thou-vow";
      };
      niri.package =
        lib.mkIf (specialisation == "attuned")
        inputs'.nix-packages.packages.niri-attuned;
      preferences = {
        apps = {
          browser = "brave";
          editor = "hx";
          shell = "nu";
          terminal = "kitty -1";
        };
        environmentVariables = {
          PERSIST_HOME = osConfig.environment.variables.PERSIST + config.directory;
        };
        shellAliases = {};
      };
    };

    directory = "/home/${config.user}";

    files = let
      protonPackages = with inputs'.nix-packages.packages; {
        "DW-Proton" = dwproton.steamcompattool;
        "Proton-CachyOS" = proton-cachyos.steamcompattool;
        "Proton-CachyOS-v3" = proton-cachyos-v3.steamcompattool;
        "Proton-GE" = proton-ge.steamcompattool;
      };
    in
      lib.mkMerge (lib.mapAttrsToList (name: value: {
          ".local/share/Steam/compatibilitytools.d/${name}".source = "${value}";
        })
        protonPackages);

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
        nautilus
        pcsx2
        qbittorrent
        rclone
        ripgrep
        termdown
        typst
        umu-launcher
        vlc
        winetricks
        xdg-utils
        yazi
        zathura
      ])
      ++ (with inputs'.nix-packages.packages; [
        discord-rpc-lsp
      ]);

    user = "thou";
  };
}
