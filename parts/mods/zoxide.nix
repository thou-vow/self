{
  lib,
  self,
  ...
}: {
  flake.homeModules.zoxide = {
    config,
    options,
    ...
  }: let
    cfg = config.self.mods.zoxide;
  in {
    options.self.mods.zoxide = {
      enable = self.lib.mkAutoEnableOption options.programs.zoxide.enable;
    };

    config = lib.mkIf cfg.enable {
      home.shellAliases = {
        "cd" = "z";
        "ci" = "zi";
      };

      programs.zoxide = {
        inherit (cfg) enable;
      };
    };
  };
}
