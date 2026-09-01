{
  lib,
  self,
  ...
}: {
  flake.homeModules.noctalia = {
    config,
    pkgs,
    ...
  }: let
    cfg = config.self.mods.noctalia;
  in {
    options.self.mods.noctalia = {
      enable = self.lib.mkAutoEnableOption "Noctalia";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.noctalia;
        description = "The Noctalia package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        dash
      ];

      programs.noctalia = lib.mkMerge [
        {
          inherit (cfg) enable package;
          systemd.enable = true;
        }
        (lib.mkIf (config.self.style.enable or false) {
          customPalettes.NoctaliaScheme =
            self.lib.renderMustache pkgs "NoctaliaScheme.json"
            config.self.style.palette
            ./NoctaliaScheme.json.mustache;

          settings.theme = {
            source = "custom";
            custom_palette = "NoctaliaScheme";
          };
        })
      ];

      xdg.configFile = {
        "noctalia/noctalia-manual.toml".source = ./noctalia-manual.toml;
      };
    };
  };
}
