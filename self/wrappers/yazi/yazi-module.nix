{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.yazi = {
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
      keymap = lib.mkOption {
        inherit (tomlFmt) type;
        default = {};
      };
      settings = lib.mkOption {
        inherit (tomlFmt) type;
        default = {};
      };
    };

    config = {
      constructFiles = {
        "config/yazi.toml" = {
          content = builtins.toJSON config.settings;
          relPath = "config/yazi.toml";
          builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
        };
        "config/keymap.toml" = {
          content = builtins.toJSON config.keymap;
          relPath = "config/keymap.toml";
          builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
        };
      };

      envDefault."YAZI_CONFIG_HOME" = "${
        self.lib.potentiallyWritableShellInline (placeholder config.outputName)
      }/config";

      package = lib.mkDefault pkgs.yazi;
    };
  };
}
