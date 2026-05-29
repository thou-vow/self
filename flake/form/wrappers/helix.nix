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
        "HELIX_STEEL_CONFIG" = config.writeFiles.helixSteelConfig.location;
        "STEEL_SEARCH_PATHS" = config.writeFiles.helixSteelSearchPaths.location;
      };

      package = lib.mkDefault inputs'.nix-packages.packages.helix-steel;

      writeFiles = {
        helixSteelConfig.entries = lib.mkMerge [
          {
            "helix.scm" = lib.mkIf (config.steel.helixScm != {}) {
              subject.text = self.lib.convertDagOfStrToLines config.steel.helixScm;
            };
            "init.scm" = lib.mkIf (config.steel.initScm != {}) {
              subject.text = self.lib.convertDagOfStrToLines config.steel.initScm;
            };
          }
          config.steel.extraConfigFiles
        ];
        helixSteelSearchPaths.entries = config.steel.cogs;
      };
    };
  };
}
