{
  lib,
  self,
  ...
}: {
  flake.wrappers.niri = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports = [self.wrapperModules.core];

    core.eject.entries.niriConfig = let
      configKdl = pkgs.writeTextFile {
        name = "config.kdl";
        text = config.configKdl;
      };
    in
      pkgs.linkFarm "niri-config" ([
          {
            inherit (configKdl) name;
            path = configKdl;
          }
        ]
        ++ config.extraPaths);

    drv.installPhase = ''
      runHook preInstall
      ${lib.getExe config.package} validate -c "${config.core.eject.entries.niriConfig}/config.kdl"
      runHook postInstall
    '';

    env."NIRI_CONFIG" = "${config.core.eject.directory}/${baseNameOf config.core.eject.entries.niriConfig}/config.kdl";

    filesToPatch = ["share/systemd/user/niri.service"];

    package = lib.mkDefault inputs'.niri-flake.packages.xwayland-satellite-unstable;
  };

  perSystem = {pkgs, ...}: {
    packages.niri = self.wrappers.niri.wrap {
      inherit pkgs;
      configKdl = ''
        include "manual-config.kdl"
      '';
      extraPaths = [
        {
          name = "manual-config.kdl";
          path = ./manual-config.kdl;
        }
      ];
    };
  };

  flake.nixosModules."wrappers.niri" = {
    config,
    self',
    pkgs,
    ...
  }: let
    perUser = f:
      config.custom.wrappers.niri.users
      |> lib.mapAttrsToList f
      |> lib.mkMerge;
  in {
    custom.build.wrappers.niri.users = perUser (name: cfg:
      lib.mkIf cfg.enable {
        ${name}.outPackage = let
          package = self'.packages.niri;
        in
          package.wrap {
            inherit (cfg) package;
            configKdl = lib.mkMerge [package.configuration.configKdl cfg.configKdl];
            extraPaths = lib.mkMerge [package.configuration.helixScm cfg.extraPaths];
            xwayland-satellite = {inherit (cfg.xwayland-satellite) package;};
          };
      });

    users.users = perUser (name: cfg:
      lib.mkIf cfg.enable {
        ${name}.packages =
          (with pkgs; [
            xdg-desktop-portal-gnome
            xdg-utils
          ])
          ++ [
            config.custom.build.wrappers.niri.users.${name}.outPackage
          ];
      });
  };
}
