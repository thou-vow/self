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
            mangowc
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
      helix.package = inputs'.nix-packages.packages.helix-steel-attuned;
      kitty.package = inputs'.nix-packages.packages.kitty-attuned;
      mangowc.package = inputs'.nix-packages.packages.mangowc-attuned;
      nushell.package = inputs'.nix-packages.packages.nushell-attuned;
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
        geminicommit
        imagemagick
        krita
        mangohud
        melonds
        mgba
        nautilus
        pcsx2
        qbittorrent
        rclone
        ripgrep
        termdown
        vlc
        xdg-utils
        zathura
      ])
      ++ (with inputs'.nix-packages.packages; [
        discord-rpc-lsp
      ])
      ++ [
        (pkgs.buildEnv {
          name = "dev-nix";
          paths =
            [inputs'.nix-packages.packages.nixd-attuned]
            ++ (with pkgs; [
              alejandra
              statix
            ]);
        })
        (pkgs.buildEnv {
          name = "dev-rust";
          paths =
            [inputs'.nix-packages.packages.rust-analyzer-attuned]
            ++ (with pkgs; [
              cargo
              clippy
              rustc
              rustfmt
            ]);
        })
        (pkgs.buildEnv {
          name = "dev-typst";
          paths = with pkgs; [
            tinymist
            typst
          ];
        })
      ];

    user = "thou";
  };
}
