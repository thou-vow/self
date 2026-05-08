{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.niri = {
    module = lib.mkMerge [
      ({
        config,
        pkgs,
        ...
      }: {
        imports = [self.wrapperModules.eject];

        options = {
          configKdl = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          extraPaths = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {type = lib.types.str;};
                path = lib.mkOption {type = lib.types.path;};
              };
            });
            default = [];
          };
          xwayland-satellite.package = lib.mkOption {type = lib.types.package;};
        };

        config = {
          eject.entries.niriConfig = pkgs.linkFarm "niri-config" (
            self.lib.mkLinkFarmOptionalText (config.configKdl != "") {
              inherit pkgs;
              name = "config.kdl";
              text = config.configKdl;
            }
            ++ config.extraPaths
          );

          drv.installPhase = ''
            runHook preInstall
            ${lib.getExe config.package} validate -c "${config.eject.entries.niriConfig}/config.kdl"
            runHook postInstall
          '';

          env."NIRI_CONFIG" = "${config.eject.directory}/${baseNameOf config.eject.entries.niriConfig}/config.kdl";

          extraPackages = [config.xwayland-satellite.package];

          package = lib.mkDefault pkgs.niri;

          xwayland-satellite.package = lib.mkDefault pkgs.xwayland-satellite;
        };
      })

      ({
        inputs',
        pkgs,
        ...
      }: {
        configKdl = ''
          include "manual-config.kdl"
        '';
        extraPackages =
          (with pkgs; [
            brightnessctl
            dash
            fuzzel
            nautilus
            wireplumber
            wl-clipboard
          ])
          ++ (with inputs'.nix-packages.packages; [
            brave-latest
          ]);
        extraPaths = [
          {
            name = "manual-config.kdl";
            path = ./manual-config.kdl;
          }
        ];
      })
    ];

    nixosUserModule = user:
      lib.mkMerge [
        ({pkgs, ...}: {
          xdg.portal.extraPortals = [pkgs.xdg-desktop-portal-gnome];
        })
      ];
  };
}
