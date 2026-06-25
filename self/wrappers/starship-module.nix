{
  lib,
  self,
  wlib,
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
      wlib.modules.constructFiles
      wlib.modules.makeWrapper
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
      constructFiles = {
        "config/starship.toml" = {
          content = builtins.toJSON config.settings;
          relPath = "config/starship.toml";
          builder = ''${pkgs.remarshal}/bin/json2toml "$1" "$2"'';
        }; 
      };
      
      envDefault."STARSHIP_CONFIG" = "${
        self.lib.potentiallyWritableShellInline (placeholder config.outputName)
      }/config/starship.toml";

      package = lib.mkDefault pkgs.starship;
    };
  };
}
