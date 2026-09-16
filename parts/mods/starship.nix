{
  lib,
  self,
  ...
}: {
  flake.homeModules.starship = {config, ...}: let
    cfg = config.self.mods.starship;
  in {
    options.self.mods.starship = {
      enable = self.lib.mkAutoEnableOption "Starship";
    };

    config = lib.mkIf cfg.enable {
      programs.starship = {
        inherit (cfg) enable;
      };
    };
  };
}
