{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.helix = {
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
      cogs = lib.mkOption {
        type = lib.types.attrsOf (wlib.types.file pkgs);
        default = {};
      };
      extraConfigFiles = lib.mkOption {
        type = lib.types.attrsOf (wlib.types.file pkgs);
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

    config = {
      constructFiles = lib.mkMerge [
        {
          "config/helix.scm" = {
            content = self.lib.convertDagOfStrToLines config.helixScm;
            relPath = "config/helix.scm";
          };
          "config/init.scm" = {
            content = self.lib.convertDagOfStrToLines config.initScm;
            relPath = "config/init.scm";
          };
        }
        (self.lib.filesToConstruct pkgs {parentDir = "cogs";} config.cogs)
        (self.lib.filesToConstruct pkgs {parentDir = "config";} config.extraConfigFiles)
      ];

      envDefault = {
        "HELIX_STEEL_CONFIG" = "${
          self.lib.potentiallyWritableShellInline (placeholder config.outputName)
        }/config";
        "STEEL_SEARCH_PATHS" = "${
          self.lib.potentiallyWritableShellInline (placeholder config.outputName)
        }/cogs";
      };

      package = lib.mkDefault inputs'.nix-packages.packages.helix-steel;
    };
  };
}
