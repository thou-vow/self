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
    self',
    ...
  }: {
    imports =
      (with self.homeModules; [
        dev
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
      dev = {
        nix.packages = with pkgs; [
          alejandra
          statix
        ];
        python.packages = with pkgs; [
          basedpyright
          python3
          ruff
          uv
        ];
        rust.packages = with pkgs; [
          cargo
          clang
          clippy
          rustc
          rustfmt
          rustup
        ];
        typst.packages = with pkgs; [
          tinymist
          typst
        ];
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
          # "DW-Proton" = dwproton.steamcompattool;
          # "Proton-CachyOS-v3" = proton-cachyos-v3.steamcompattool;
          "Proton-GE" = proton-ge.steamcompattool;
          "Proton-Wineland-v3" = proton-wineland-v3.steamcompattool;
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
        [
          self'.packages.faugus-launcher
        ]
        ++ (with pkgs; [
          azahar
          bc
          cemu
          distrobox
          dolphin-emu
          geminicommit
          gpu-screen-recorder-gtk
          imagemagick
          kdePackages.kdenlive
          krita
          liberation_ttf
          libreoffice
          mangohud
          melonds
          mgba
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts-color-emoji
          pcsx2
          poppins
          python314Packages.huggingface-hub
          qbittorrent
          rclone
          ripgrep
          termdown
          vlc
          xdg-utils
          zathura

          corefonts
          discord
          nerd-fonts.victor-mono
          vscode
        ])
        ++ (with inputs'.nix-packages.packages; [
          brave
          discord-rpc-lsp
        ]);

      sessionPath = [
        "$HOME/.local/bin"
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
