{
  inputs,
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrapperModules.direnv = {
    config,
    pkgs,
    ...
  }: let
    tomlFmt = pkgs.formats.toml {};
  in {
    imports = [
      self.wrapperModules.writeFiles
    ];

    options = {
      nix-direnv = {
        enable = lib.mkEnableOption "nix-direnv integration";
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.nix-direnv;
        };
      };
      settings = lib.mkOption {
        inherit (tomlFmt) type;
        default = {};
      };
      silent = lib.mkEnableOption "silent mode";
    };

    config = {
      envDefault."DIRENV_CONFIG" =
        self.lib.potentiallyWritableShellInline config.writeFiles.direnvConfig.drv;

      package = lib.mkDefault pkgs.direnv;

      settings.global = lib.mkIf config.silent {
        log_format = "-";
        log_filter = "^$";
      };

      writeFiles.direnvConfig.entries = {
        "direnv.toml".subject.source = tomlFmt.generate "direnv.toml" config.settings;
        "lib/nix-direnv.sh" = lib.mkIf config.nix-direnv.enable {
          subject.source = "${config.nix-direnv.package}/share/nix-direnv/direnvrc";
        };
      };
    };
  };
}
