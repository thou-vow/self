{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.niri = {
      pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

      module = {
        config,
        pkgs,
        ...
      }: {
        imports = [self.wrapperModules.writeFiles];

        options = {
          configKdl = lib.mkOption {
            type = self.lib.dagLinesType;
            default = "";
          };
          extraConfigFiles = lib.mkOption {
            type = self.lib.filesType pkgs;
            default = {};
          };
          xwayland-satellite.package = lib.mkOption {
            type = lib.types.package;
            default = pkgs.xwayland-satellite;
          };
        };

        config = {
          drv.installPhase = lib.mkIf (config.configKdl != "") ''
            runHook preInstall
            ${lib.getExe config.package} validate -c "${config.writeFiles.niriConfig.drv}/config.kdl"
            runHook postInstall
          '';

          envDefault."NIRI_CONFIG" = "${config.writeFiles.niriConfig.location}/config.kdl";

          extraPackages = [config.xwayland-satellite.package];

          filesToPatch = ["share/systemd/user/niri.service"];

          package = lib.mkDefault pkgs.niri;

          writeFiles.niriConfig = {
            eject.enable = true;
            entries = lib.mkMerge [
              {
                "config.kdl" = lib.mkIf (config.configKdl != "") {
                  subject.text = config.configKdl;
                };
              }
              config.extraConfigFiles
            ];
          };
        };
      };

      nixosUserModule = user: {
        config,
        pkgs,
        ...
      }: let
        namespace = ["wrappers" "users" user];
        cfg = lib.attrByPath (namespace ++ ["niri"]) {} config;
      in {
        xdg.portal = {
          enable = true;
          configPackages = [cfg.wrapper];
          extraPortals = [pkgs.xdg-desktop-portal-gnome];
        };
      };
    };
  }

  {
    flake.wrappers.niri = {
      module = {
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
        extraConfigFiles = {
          "manual-config.kdl".subject.source = ./manual-config.kdl;
        };
      };
    };
  }
]
