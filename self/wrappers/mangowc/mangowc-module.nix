{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.mangowc = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.constructFiles
      wlib.modules.makeWrapper
    ];

    options = {
      configConf = lib.mkOption {
        type = wlib.types.dagOf lib.types.str;
        default = {};
      };
      environmentVariables = lib.mkOption {
        type = self.lib.types.environmentVariables;
        default = {};
      };
      extraConfigFiles = lib.mkOption {
        type = lib.types.attrsOf (wlib.types.file pkgs);
        default = {};
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf self.lib.types.mangowcValue;
        default = {};
      };
    };

    config = {
      configConf = {
        environmentVariables = lib.pipe config.environmentVariables [
          (lib.generators.toKeyValue {
            mkKeyValue = k: v: "env=${k},${toString v}";
          })
          wlib.dag.entryAnywhere
        ];

        settings = lib.pipe config.settings [
          self.lib.toMangowcAssignments
          wlib.dag.entryAnywhere
        ];
      };

      constructFiles = lib.mkMerge [
        {
          "config/config.conf" = {
            content = self.lib.convertDagOfStrToLines config.configConf;
            relPath = "config/config.conf";
          };
        }
        (self.lib.filesToConstruct pkgs {parentDir = "config";} config.extraConfigFiles)
      ];

      flags = {
        "-c" = "${
          self.lib.potentiallyWritableShellInline (placeholder config.outputName)
        }/config/config.conf";
      };

      package = lib.mkDefault inputs'.nix-packages.packages.mangowc;
    };
  };

  flake.wrapperIntegrationModules.mangowc = {config, ...}: {
    mangowc.environmentVariables =
      lib.mkIf (config.preferences or {} != {})
      config.preferences.environmentVariables;
  };
}
