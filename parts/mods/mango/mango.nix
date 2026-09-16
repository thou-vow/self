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
        brightnessctl
        playerctl
        wireplumber
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
            bind = [
              "NONE,Print,spawn,noctalia msg screenshot-annotate"
              "SHIFT,Print,spawn,noctalia msg annotate"
              "CTRL,Print,spawn,noctalia msg screenshot-region"
              "CTRL+SHIFT,Print,spawn,noctalia msg screenshot-fullscreen"
              "SUPER,code:51,spawn,noctalia msg panel-toggle control-center"
              "SUPER+SHIFT,code:51,spawn,noctalia msg settings-toggle"
              "SUPER,V,spawn,noctalia msg panel-toggle clipboard"
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
