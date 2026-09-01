{
  lib,
  self,
  ...
}: {
  flake.homeModules.mango = {
    config,
    inputs',
    pkgs,
    ...
  }: let
    cfg = config.self.mods.mango;
  in {
    imports = [
      (import "${inputs'.nixpkgs.legacyPackages.mango.src}/nix/hm-modules.nix" null)
    ];

    options.self.mods.mango = {
      enable = self.lib.mkAutoEnableOption "Mango";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.mango;
        description = "The Mango package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        dash
        wl-clipboard
      ];

      wayland.windowManager.mango = {
        inherit (cfg) enable package;
        autostart_sh = "\n";
        extraConfig = lib.mkMerge [
          (lib.mkIf (config.self.style.enable or false) ''
            source=./mango-theme.conf
          '')
          (lib.mkAfter ''
            source=./mango-manual.conf
          '')
        ];
        settings = lib.mkMerge [
          (lib.mkIf (config.self.mods.noctalia.enable or false) {
            bindl = [
              "NONE,XF86AudioMicMute,spawn,noctalia msg mic-mute"
              "NONE,XF86AudioMute,spawn,noctalia msg volume-mute"
              "NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down"
              "NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up"
              "NONE,XF86AudioNext,spawn,noctalia msg media next"
              "NONE,XF86AudioPrev,spawn,noctalia msg media previous"
              "NONE,XF86AudioPlay,spawn,noctalia msg media toggle"
              "NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down 1%"
              "NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up 1%"
            ];

            bind = [
              "NONE,Print,spawn,noctalia msg screenshot-region"
              "SUPER,backslash,spawn,noctalia msg panel-toggle control-center"
              "SUPER+SHIFT,backslash,spawn,noctalia msg settings-toggle"
            ];
          })
        ];
        systemd = {
          enable = true;
          xdgAutostart = true;
        };
      };

      xdg = {
        configFile = {
          "mango/mango-manual.conf".source = ./mango-manual.conf;
          "mango/mango-theme.conf" = lib.mkIf (config.self.style.enable or false) {
            source =
              self.lib.renderMustache pkgs "mango-theme.conf"
              config.self.style.palette
              ./mango-theme.conf.mustache;
          };
        };

        portal = {
          enable = true;
          config.mango = {
            "default" = ["gtk" "kde"];
            "org.freedesktop.impl.portal.FileChooser" = "kde";
            "org.freedesktop.impl.portal.Inhibit" = "none";
            "org.freedesktop.impl.portal.ScreenCast" = "wlr";
            "org.freedesktop.impl.portal.Screenshot" = "wlr";
          };
          extraPortals =
            (with pkgs; [
              kdePackages.xdg-desktop-portal-kde
            ])
            ++ (with pkgs; [
              xdg-desktop-portal-gtk
              xdg-desktop-portal-wlr
            ]);
        };
      };
    };
  };
}
