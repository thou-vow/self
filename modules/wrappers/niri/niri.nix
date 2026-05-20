{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.niri.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

    flake.wrappers.niri.module = {
      config,
      inputs',
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

        filesToPatch = ["share/systemd/user/niri.service"];

        package = lib.mkDefault inputs'.nix-packages.packages.niri-pr;

        runtimePkgs = [config.xwayland-satellite.package];

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

    flake.wrappers.niri.nixosUserModule = user: {
      pkgs,
      ...
    }: {
      xdg.portal = {
        enable = true;
        configPackages = [config.wrappers.users.${user}.niri.wrapper];
        extraPortals = with pkgs; [xdg-desktop-portal-gnome];
      };
    };
  }

  {
    flake.wrappers.niri.module = {
      inputs',
      pkgs,
      ...
    }: {
      configKdl = ''
        include "manual-config.kdl"
      '';
      extraConfigFiles = {
        "manual-config.kdl".subject.source = ./manual-config.kdl;
      };
      runtimePkgs =
        (with pkgs; [
          brightnessctl
          dash
          kdePackages.dolphin
          fuzzel
          wireplumber
          wl-clipboard
        ])
        ++ (with inputs'.nix-packages.packages; [
          brave-latest
        ]);
    };
  }
]
