{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.niri = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.constructFiles
      wlib.modules.makeWrapper
      wlib.modules.symlinkScript
    ];

    options = {
      configKdl = lib.mkOption {
        type = wlib.types.dagOf lib.types.str;
        default = {};
      };
      extraConfigFiles = lib.mkOption {
        type = lib.types.attrsOf (wlib.types.file pkgs);
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

      constructFiles = lib.mkMerge [
        {
          "config/config.kdl" = {
            content = self.lib.convertDagOfStrToLines config.configKdl;
            relPath = "config/config.kdl";
          };
        }
        (self.lib.filesToConstruct pkgs {parentDir = "config";} config.extraConfigFiles)
      ];

      drv.installPhase = ''
        runHook preInstall
        ${lib.getExe config.package} validate -c "${config.constructFiles."config/config.kdl".path}"
        runHook postInstall
      '';

      envDefault."NIRI_CONFIG" = "${
        self.lib.potentiallyWritableShellInline (placeholder config.outputName)
      }/config/config.kdl";

      filesToPatch = ["share/systemd/user/niri.service"];

      package = lib.mkDefault pkgs.niri;

      runtimePkgs = [
        config.xwayland-satellite.package
      ];
    };
  };

  flake.wrapperIntegrationModules.niri = {config, ...}: {
    niri.settings = {
      environment = lib.mkIf (config.preferences or {} != {}) config.preferences.environmentVariables;
    };
  };
}
