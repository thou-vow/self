{
  lib,
  self,
  withSystem,
  wlib,
  ...
}:
lib.mkMerge [
  {
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
        envDefault."GIT_CONFIG_GLOBAL" = "${config.writeFiles.gitConfig.location}/gitconfig";

        gitconfig = {
          settings = lib.pipe config.settings [
            lib.generators.toGitINI
            wlib.dag.entryAnywhere
            (lib.mkIf (config.settings != {}))
          ];
        };

        package = lib.mkDefault pkgs.git;

        writeFiles.gitConfig = {
          eject.enable = true;
          entries."gitconfig" = lib.mkIf (config.gitconfig != "") {
            subject.text = self.lib.convertDagOfStrToLines config.gitconfig;
          };
        };
      };
    };
  }
]
