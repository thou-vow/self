{
  lib,
  self,
  ...
}: {
  flake.nixosModules.u = _: {
    hjem.users.thou = lib.mkMerge [
      self.hjemModules.thou-u
    ];
  };

  flake.hjemModules.thou-u = {
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
        extraIntegrationModules = with self.wrapperIntegrationModules; [
          preferences
        ];
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
        style = {
          palette = sub:
            with sub.config; {
              main-cursor = "#f4dbe2";
              other-cursor = "#e8b7c5";

              dark-background = "#060810";
              background = "#121622";
              other-highlight = "#1c2232";
              main-highlight = "#272d41";
              other-selection = "#313950";
              main-selection = "#46516f";
              invisible = "#7683a8";
              comment = "#919dbf";
              dark-foreground = "#aeb8d4";
              foreground = "#ced4e6";

              red = "#f0a396";
              yellow = "#d7b659";
              green = "#75d18b";
              cyan = "#60cbdd";
              blue = "#a4b7f0";
              magenta = "#e39edc";
              bright-red = "#f6c9c1";
              bright-yellow = "#efd387";
              bright-green = "#99ecaa";
              bright-cyan = "#95e4f2";
              bright-blue = "#c8d4f6";
              bright-magenta = "#eec6e9";

              escape = red;
              parameter = yellow;
              class = green;
              constant = cyan;
              function = blue;
              keyword = magenta;
              boolean = bright-red;
              string = bright-yellow;
              number = bright-green;
              variable = bright-cyan;
              namespace = bright-blue;
              operator = bright-blue;
              path = bright-magenta;
            };
        };
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
