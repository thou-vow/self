{
  lib,
  self,
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
      wlib.modules.constructFiles
      wlib.modules.makeWrapper
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
      constructFiles = {
        "config/direnv.toml" = {
          content = builtins.toJSON config.settings;
          relPath = "config/direnv.toml";
          builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
        };
        "config/lib/nix-direnv.sh" = lib.mkIf config.nix-direnv.enable {
          relPath = "config/lib/nix-direnv.sh";
          builder = ''${pkgs.coreutils}/bin/cp "${config.nix-direnv.package}/share/nix-direnv/direnvrc" "$2"'';
        };
      };

      envDefault."DIRENV_CONFIG" = "${
        self.lib.potentiallyWritableShellInline (placeholder config.outputName)
      }/config";

      package = lib.mkDefault pkgs.direnv;

      settings.global = lib.mkIf config.silent {
        log_format = "-";
        log_filter = "^$";
      };
    };
  };
}
