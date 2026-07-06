{
  lib,
  self,
  ...
}: {
  flake.nixosModules.u = _: {
    home-manager.users.thou = self.homeModules."thou@u";
  };

  flake.homeModules."thou@u" = {
    config,
    inputs',
    osConfig,
    pkgs,
    ...
  }: {
    imports = with self.homeModules; [
      style

      atuin
      helix
      kitty
      mango
      nushell
      prismlauncher
      starship
      yazi
      zoxide
    ];

    self = {
      base = {inherit (osConfig.self.base) flakePath;};
      mods = {
        helix.package = inputs'.nix-packages.packages.helix-steel-attuned;
        kitty.package = inputs'.nix-packages.packages.kitty-attuned;
        mango.package = inputs'.nix-packages.packages.mango-attuned;
        nushell.package = inputs'.nix-packages.packages.nushell-attuned;
      };
    };

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        emoji = ["Noto Color Emoji"];
        monospace = ["VictorMono Nerd Font Mono"];
        sansSerif = ["Noto Sans"];
        serif = ["Noto Serif"];
      };
    };

    home = {
      file = let
        protonPackages = with inputs'.nix-packages.packages; {
          "DW-Proton" = dwproton.steamcompattool;
          "Proton-CachyOS-v3" = proton-cachyos-v3.steamcompattool;
          "Proton-GE" = proton-ge.steamcompattool;
        };
      in
        lib.mkMerge (lib.mapAttrsToList (name: value: {
            ".local/share/Steam/compatibilitytools.d/${name}".source = "${value}";
          })
          protonPackages
          ++ [
            {
              ".profile" = {
                text = ''. "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"'';
                executable = true;
              };
            }
          ]);

      packages =
        (with pkgs; [
          azahar
          bc
          cemu
          corefonts
          distrobox
          dolphin-emu
          geminicommit
          imagemagick
          krita
          mangohud
          melonds
          mgba
          nerd-fonts.victor-mono
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
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

      sessionVariables = {
        BROWSER = "brave";
        EDITOR = "hx";
        SHELL = "nu";
        TERMINAL = "kitty -1";

        PERSIST_HOME = osConfig.environment.sessionVariables.PERSIST + config.home.homeDirectory;
      };

      stateVersion = osConfig.system.stateVersion;
    };

    programs = {
      direnv = {
        enable = true;
        nix-direnv.enable = true;
        silent = true;
      };
      git = {
        enable = true;
        settings.user = {
          name = "thou-vow";
          email = "thou.vow.etoile@gmail.com";
        };
      };
    };

    xdg.enable = true;
  };
}
