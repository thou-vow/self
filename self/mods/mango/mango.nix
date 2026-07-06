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
          waybar
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

          "mango/config.conf".text = ''
            exec-once=./autostart.sh

            source=./manual-config.conf
          '';

          "mango/manual-config.conf".source = ./manual-config.conf;
        };

        portal = {
          enable = true;
          config.mango-portals = {
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
