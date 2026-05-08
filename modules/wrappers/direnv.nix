{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.direnv = {
    module = lib.mkMerge [
      ({
        config,
        pkgs,
        ...
      }: let
        tomlFmt = pkgs.formats.toml {};
      in {
        imports = [self.wrapperModules.eject];

        options = {
          nix-direnv.enable = lib.mkEnableOption "nix-direnv integration";
          settings = lib.mkOption {
            inherit (tomlFmt) type;
            default = {};
          };
          silent = lib.mkEnableOption "silent mode";
        };

        config = {
          eject.entries.direnvConfig = pkgs.linkFarm "direnv-config" (
            lib.optionals (config.settings != {}) [
              {
                name = "direnv.toml";
                path = tomlFmt.generate "direnv.toml" config.settings;
              }
            ]
            ++ lib.optionals config.nix-direnv.enable [
              {
                name = "lib/nix-direnv.sh";
                path = "${pkgs.nix-direnv}/share/nix-direnv/direnvrc";
              }
            ]
          );

          env."DIRENV_CONFIG" = "${config.eject.directory}/${baseNameOf config.eject.entries.direnvConfig}";

          package = lib.mkDefault pkgs.direnv;

          settings.global = lib.mkIf config.silent {
            log_format = "-";
            log_filter = "^$";
          };
        };
      })

      {
        nix-direnv.enable = true;
        silent = true;
      }
    ];
  };
}
