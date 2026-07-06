{
  lib,
  self,
  ...
}: {
  flake.homeModules.yazi = {config, ...}: let
    cfg = config.self.mods.yazi;
  in {
    options.self.mods.yazi = {
      enable = self.lib.mkAutoEnableOption "Yazi";
    };

    config = lib.mkIf cfg.enable {
      programs.yazi = {
        inherit (cfg) enable;
      };
    };
  };
}
