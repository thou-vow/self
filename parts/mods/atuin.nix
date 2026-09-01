{
  lib,
  self,
  ...
}: {
  flake.homeModules.atuin = {
    config,
    ...
  }: let
    cfg = config.self.mods.atuin;
  in {
    options.self.mods.atuin = {
      enable = self.lib.mkAutoEnableOption "Atuin";
    };

    config = lib.mkIf cfg.enable {
      programs.atuin = {
        inherit (cfg) enable;
        daemon.enable = true;
        flags = ["--disable-up-arrow"];
        settings = {
          inline_height = 9;
          prefers_reduced_motion = true;
          show_help = false;
          show_tabs = false;
          workspaces = true;
        };
      };
    };
  };
}
