{
  lib,
  self,
  ...
}: {
  flake.nixosModules.nh = {
    config,
    options,
    ...
  }: let
    cfg = config.self.mods.nh;
  in {
    options.self.mods.nh = {
      enable = self.lib.mkAutoEnableOption options.programs.nh.enable;
    };

    config = lib.mkIf cfg.enable {
      environment.sessionVariables = {
        NH_SHOW_ACTIVATION_LOGS = "1";
      };

      programs.nh = {
        inherit (cfg) enable;
        flake =
          lib.mkIf (config.self.base.enable or false)
          config.self.base.flakePath;
      };
    };
  };
}
