{
  lib,
  self,
  ...
}: {
  flake.homeModules.zoxide = {config, ...}: let
    cfg = config.self.mods.zoxide;
  in {
    options.self.mods.zoxide = {
      enable = self.lib.mkAutoEnableOption "zoxide";
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
