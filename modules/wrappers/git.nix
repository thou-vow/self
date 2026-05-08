{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.git = {
    module = lib.mkMerge [
      ({
        config,
        pkgs,
        ...
      }: {
        imports = [self.wrapperModules.eject];

        options = {
          gitconfig = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          settings = lib.mkOption {
            inherit (pkgs.formats.gitIni {}) type;
            default = {};
          };
        };

        config = {
          eject.entries.gitConfig = pkgs.linkFarm "git-config" (
            self.lib.mkLinkFarmOptionalText (config.gitconfig != "") {
              inherit pkgs;
              name = "gitconfig";
              text = config.gitconfig;
            }
          );

          env."GIT_CONFIG_GLOBAL" = "${config.eject.directory}/${baseNameOf config.eject.entries.gitConfig}/gitconfig";

          gitconfig = lib.mkMerge [
            (lib.pipe config.settings [
              lib.generators.toGitINI
              (lib.mkOrder 510)
              (lib.mkIf (config.settings != {}))
            ])
          ];

          package = lib.mkDefault pkgs.git;
        };
      })
    ];
  };
}
