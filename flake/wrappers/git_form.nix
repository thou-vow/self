{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.git.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

  flake.wrappers.git.module = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.wrapperModules.writeFiles
      wlib.modules.symlinkScript
    ];

    options = {
      gitconfig = lib.mkOption {
        type = wlib.types.dagOf lib.types.str;
        default = {};
      };
      settings = lib.mkOption {
        inherit (pkgs.formats.gitIni {}) type;
        default = {};
      };
    };

    config = {
      envDefault."GIT_CONFIG_GLOBAL" =
        self.lib.disableEntryEscapeFn
        "${self.lib.potentiallyWritableShellInline config.writeFiles.gitConfig.drv}/gitconfig";

      gitconfig = {
        settings = lib.pipe config.settings [
          lib.generators.toGitINI
          wlib.dag.entryAnywhere
        ];
      };

      package = lib.mkDefault pkgs.git;

      writeFiles.gitConfig.entries = {
        "gitconfig".subject.text = self.lib.convertDagOfStrToLines config.gitconfig;
      };
    };
  };
}
