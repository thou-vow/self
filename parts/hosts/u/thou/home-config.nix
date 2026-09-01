{
  inputs,
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
    imports =
      (with self.homeModules; [
        style

        atuin
        helix
        kitty
        mango
        noctalia
        nushell
        prismlauncher
        starship
        yazi
        zoxide
      ])
      ++ [
        "${inputs.nix-index-database}/home-manager-module.nix"
      ];

    self = {
      base = {inherit (osConfig.self.base) flakePath;};
      mods = {
        helix.package = inputs'.nix-packages.packages.helix-steel-attuned;
        kitty.package = inputs'.nix-packages.packages.kitty-attuned;
        mango.package = inputs'.nix-packages.packages.mango-attuned;
        noctalia.package = inputs'.nix-packages.packages.noctalia-attuned;
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

    gtk = {
      enable = true;
      colorScheme = "dark";
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
          corefonts
          mgba
          nerd-fonts.victor-mono
        ])
        ++ (with pkgs; [
          azahar
          bc
          cemu
          distrobox
          dolphin-emu
          geminicommit
          imagemagick
          krita
          liberation_ttf
          libreoffice
          mangohud
          melonds
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          pcsx2
          poppins
          qbittorrent
          rclone
          ripgrep
          termdown
          vlc
          xdg-utils
          zathura
        ])
        ++ (with inputs'.nix-packages.packages; [
          brave
          discord-rpc-lsp
        ])
        ++ [
          (self.lib.mkShellPackage pkgs "dev-nix" {
            packages =
              [inputs'.nix-packages.packages.nixd-attuned]
              ++ (with pkgs; [
                alejandra
                statix
              ]);
          })
          (self.lib.mkShellPackage pkgs "dev-rust" {
            packages =
              [inputs'.nix-packages.packages.rust-analyzer-attuned]
              ++ (with pkgs; [
                cargo
                clippy
                rustc
                rustfmt
              ]);
          })
          (self.lib.mkShellPackage pkgs "dev-typst" {
            packages = with pkgs; [
              tinymist
              typst
            ];
          })
        ];

      sessionVariables = {
        BROWSER = "brave";
        EDITOR = "hx";
        LAUNCHER = "noctalia msg panel-toggle launcher";
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
      nix-index.package = (import inputs.nix-index-database {inherit pkgs;}).nix-index-with-small-db;
      nix-index-database.comma.enable = true;
    };

    xdg.enable = true;
  };
}
