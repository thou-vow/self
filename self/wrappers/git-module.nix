{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.git = {
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
      gitconfig = lib.mkOption {
        type = wlib.types.dagOf lib.types.str;
        default = {};
      };
      settings = lib.mkOption {
        inherit (pkgs.formats.gitIni {listsAsDuplicateKeys = true;}) type;
        default = {};
      };
    };

    config = {
      constructFiles = {
        "config/gitconfig" = {
          content = self.lib.convertDagOfStrToLines config.gitconfig;
          relPath = "config/gitconfig";
        };
      };

      envDefault."GIT_CONFIG_GLOBAL" = "${
        self.lib.potentiallyWritableShellInline (placeholder config.outputName)
      }/config/gitconfig";

      gitconfig = {
        settings = lib.pipe config.settings [
          lib.generators.toGitINI
          wlib.dag.entryAnywhere
        ];
      };

      package = lib.mkDefault pkgs.git;
    };
  };
}
