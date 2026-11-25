{
  lib,
  self,
  ...
}: {
  flake.homeModules.starship = {
    config,
    options,
    ...
  }: let
    cfg = config.self.mods.starship;
  in {
    options.self.mods.starship = {
      enable = self.lib.mkAutoEnableOption options.programs.starship.enable;
    };

    config = lib.mkIf cfg.enable {
      programs.starship = {
        inherit (cfg) enable;
      };
    };
  };
}
