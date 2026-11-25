{
  lib,
  self,
  ...
}: {
  flake.homeModules.yazi = {
    config,
    options,
    ...
  }: let
    cfg = config.self.mods.yazi;
  in {
    options.self.mods.yazi = {
      enable = self.lib.mkAutoEnableOption options.programs.yazi.enable;
    };

    config = lib.mkIf cfg.enable {
      programs.yazi = {
        inherit (cfg) enable;
      };
    };
  };
}
