{
  lib,
  self,
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
      self.wrapperModules.writeFiles
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
      envDefault."YAZI_CONFIG_HOME" = self.lib.potentiallyWritableShellInline config.writeFiles.yaziConfig.drv;

      package = lib.mkDefault pkgs.yazi;

      writeFiles.yaziConfig.entries = {
        "yazi.toml".subject.source = tomlFmt.generate "yazi.toml" config.settings;
        "keymap.toml".subject.source = tomlFmt.generate "keymap.toml" config.keymap;
      };
    };
  };
}
