{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.git = {
      pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

      module = {
        config,
        pkgs,
        ...
      }: {
        imports = [self.wrapperModules.writeFiles];

        options = {
          gitconfig = lib.mkOption {
            type = self.lib.dagLinesType;
            default = "";
          };
          settings = lib.mkOption {
            inherit (pkgs.formats.gitIni {}) type;
            default = {};
          };
        };

        config = {
          envDefault."GIT_CONFIG_GLOBAL" = "${config.writeFiles.gitConfig.location}/gitconfig";

          gitconfig = lib.mkMerge [
            (lib.pipe config.settings [
              lib.generators.toGitINI
              (self.lib.mkNamedEntryBetween [] "SETTINGS" ["DEFAULT"])
              (lib.mkIf (config.settings != {}))
            ])
          ];

          package = lib.mkDefault pkgs.git;

          writeFiles.gitConfig = {
            eject.enable = true;
            entries."gitconfig" = lib.mkIf (config.gitconfig != "") {
              subject.text = config.gitconfig;
            };
          };
        };
      };
    };
  }
]
