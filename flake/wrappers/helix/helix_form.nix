{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.helix.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

  flake.wrappers.helix.module = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports = [
      self.wrapperModules.writeFiles
    ];

    options = {
      steel = {
        cogs = lib.mkOption {
          type = self.lib.types.files pkgs;
          default = {};
        };
        extraConfigFiles = lib.mkOption {
          type = self.lib.types.files pkgs;
          default = {};
        };
        initScm = lib.mkOption {
          type = wlib.types.dagOf lib.types.str;
          default = {};
        };
        helixScm = lib.mkOption {
          type = wlib.types.dagOf lib.types.str;
          default = {};
        };
      };
    };

    config = {
      envDefault = {
        "HELIX_STEEL_CONFIG" =
          self.lib.disableEntryEscapeFn
          (self.lib.potentiallyWritableShellInline config.writeFiles.helixSteelConfig.drv);
        "STEEL_SEARCH_PATHS" =
          self.lib.disableEntryEscapeFn
          (self.lib.potentiallyWritableShellInline config.writeFiles.helixSteelSearchPaths.drv);
      };

      package = lib.mkDefault inputs'.nix-packages.packages.helix-steel;

      writeFiles = {
        helixSteelConfig.entries = lib.mkMerge [
          {
            "helix.scm".subject.text = self.lib.convertDagOfStrToLines config.steel.helixScm;
            "init.scm".subject.text = self.lib.convertDagOfStrToLines config.steel.initScm;
          }
          config.steel.extraConfigFiles
        ];
        helixSteelSearchPaths.entries = config.steel.cogs;
      };
    };
  };
}
