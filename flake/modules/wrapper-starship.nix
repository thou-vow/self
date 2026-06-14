{
  lib,
  self,
  ...
}: {
  flake.wrapperModules.starship = {
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
      presets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
      };
      settings = lib.mkOption {
        inherit (tomlFmt) type;
        default = {};
      };
    };

    config = {
      envDefault."STARSHIP_CONFIG" =
        "${self.lib.potentiallyWritableShellInline config.writeFiles.starshipConfig.drv}/starship.toml";

      package = lib.mkDefault pkgs.starship;

      writeFiles.starshipConfig.entries = {
        "starship.toml".subject.source = tomlFmt.generate "starship.toml" config.settings;
      };
    };
  };
}
