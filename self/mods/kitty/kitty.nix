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
        extraConfig = lib.mkMerge [
          (lib.mkIf (config.self.style.enable or false) ''
            include ./kitty-theme.conf
          '')
          (lib.mkAfter ''
            include ./kitty-manual.conf
          '')
        ];
        settings.clear_all_shortcuts = true;
      };

      xdg.configFile = {
        "kitty/kittens".source = ./kittens;
        "kitty/kitty-manual.conf".source = ./kitty-manual.conf;
        "kitty/kitty-theme.conf" = lib.mkIf (config.self.style.enable or false) {
          source =
            self.lib.renderMustache pkgs "kitty-theme.conf"
            config.self.style.palette
            ./kitty-theme.conf.mustache;
        };
      };
    };
  };
}
