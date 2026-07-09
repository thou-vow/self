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
    options.self.mods.mango = {
      enable = self.lib.mkAutoEnableOption "Mango";
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs'.nix-packages.packages.mango;
        description = "The Mango package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages =
        [cfg.package]
        ++ (with pkgs; [
          brightnessctl
          dash
          flameshot
          fuzzel
          kdePackages.dolphin
          playerctl
          wireplumber
          wl-clipboard
        ])
        ++ (with inputs'.nix-packages.packages; [
          brave
        ]);

      systemd.user.targets.mango-session = {
        Unit = {
          Description = "mango compositor session";
          Documentation = ["man:systemd.special(7)"];
          BindsTo = ["graphical-session.target"];
          Wants = [
            "graphical-session-pre.target"
            "xdg-desktop-autostart.target"
          ];
          After = ["graphical-session-pre.target"];
          Before = "xdg-desktop-autostart.target";
        };
      };

      xdg = {
        configFile = {
          "mango/autostart.sh" = let
            systemdActivationStr = ''
              ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd ${builtins.concatStringsSep " " [
                "DISPLAY"
                "WAYLAND_DISPLAY"
                "XDG_CURRENT_DESKTOP"
                "XDG_SESSION_TYPE"
                "NIXOS_OZONE_WL"
                "XCURSOR_THEME"
                "XCURSOR_SIZE"
              ]}; ${builtins.concatStringsSep " && " [
                "systemctl --user reset-failed"
                "systemctl --user start mango-session.target"
              ]}
            '';
          in {
            text =
              # sh
              ''
                #!${lib.getExe pkgs.dash}
                ${lib.optionalString config.systemd.user.enable systemdActivationStr}
              '';
            executable = true;
          };

          "mango/config.conf".text = lib.mkMerge [
            (lib.mkBefore ''
              exec-once=~/.config/mango/autostart.sh
            '')
            (lib.mkIf (config.self.style.enable or false) ''
              source=./mango-theme.conf
            '')
            (lib.mkIf (config.self.mods.noctalia.enable or false) ''
              bindl=NONE,XF86AudioMicMute,spawn,noctalia msg mic-mute
              bindl=NONE,XF86AudioMute,spawn,noctalia msg volume-mute
              bindl=NONE,XF86AudioLowerVolume,spawn,noctalia msg volume-down
              bindl=NONE,XF86AudioRaiseVolume,spawn,noctalia msg volume-up
              bindl=NONE,XF86AudioNext,spawn,noctalia msg media next
              bindl=NONE,XF86AudioPrev,spawn,noctalia msg media previous
              bindl=NONE,XF86AudioPlay,spawn,noctalia msg media toggle
              bindl=NONE,XF86MonBrightnessDown,spawn,noctalia msg brightness-down 1%
              bindl=NONE,XF86MonBrightnessUp,spawn,noctalia msg brightness-up 1%

              bind=NONE,Print,spawn,noctalia msg screenshot-region

              bind=SUPER,backslash,spawn,noctalia msg panel-toggle control-center
              bind=SUPER+SHIFT,backslash,spawn,noctalia msg settings-toggle
            '')
            (lib.mkAfter ''
              source=./mango-manual.conf
            '')
          ];

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
          extraPortals = with pkgs; [
            kdePackages.xdg-desktop-portal-kde
            xdg-desktop-portal-gtk
            xdg-desktop-portal-wlr
          ];
        };
      };
    };
  };
}
