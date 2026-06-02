{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.niri.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

  flake.wrappers.niri.module = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports = [
      self.wrapperModules.writeFiles
      wlib.modules.symlinkScript
    ];

    options = {
      configKdl = lib.mkOption {
        type = wlib.types.dagOf lib.types.str;
        default = {};
      };
      extraConfigFiles = lib.mkOption {
        type = self.lib.types.files pkgs;
        default = {};
      };
      settings = lib.mkOption {
        type = wlib.types.attrsRecursive;
        default = {};
      };
      xwayland-satellite.package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.xwayland-satellite;
      };
    };

    config = {
      configKdl = {
        settings = lib.pipe config.settings [
          wlib.toKdl
          wlib.dag.entryAnywhere
        ];
      };

      drv.installPhase = ''
        runHook preInstall
        ${lib.getExe config.package} validate -c "${config.writeFiles.niriConfig.drv}/config.kdl"
        runHook postInstall
      '';

      envDefault."NIRI_CONFIG" =
        self.lib.disableEntryEscapeFn
        "${self.lib.potentiallyWritableShellInline config.writeFiles.niriConfig.drv}/config.kdl";

      filesToPatch = ["share/systemd/user/niri.service"];

      package = lib.mkDefault inputs'.nix-packages.packages.niri-pr;

      runtimePkgs = [
        config.xwayland-satellite.package
      ];

      writeFiles.niriConfig.entries = lib.mkMerge [
        {
          "config.kdl".subject.text = self.lib.convertDagOfStrToLines config.configKdl;
        }
        config.extraConfigFiles
      ];
    };
  };

  flake.wrappers.niri.integrationModule = {config, ...}: {
    niri = {
      settings = {
        environment = lib.mkIf (config.preferences or {} != {}) config.preferences.environmentVariables;
      };
    };
  };
}
