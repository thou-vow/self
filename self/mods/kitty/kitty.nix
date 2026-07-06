{
  lib,
  self,
  ...
}: {
  flake.homeModules.kitty = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.self.mods.kitty;
  in {
    options.self.mods.kitty = {
      enable = self.lib.mkAutoEnableOption "Kitty";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.kitty;
        description = "The Kitty package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      programs.kitty = {
        inherit (cfg) enable package;
        extraConfig = lib.mkAfter ''
          include ./manual-kitty.conf
        '';
        settings = lib.mkMerge [
          (lib.mkIf (config.self.style.enable or false)
            (import ./_kitty-theme.nix config.self.style))
          {clear_all_shortcuts = true;}
        ];
      };

      xdg.configFile = {
        "kitty/kittens".source = ./kittens;
        "kitty/manual-kitty.conf".source = ./manual-kitty.conf;
      };
    };
  };
}
