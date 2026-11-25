{
  lib,
  self,
  ...
}: {
  flake.homeModules.noctalia = {
    config,
    options,
    pkgs,
    ...
  }: let
    cfg = config.self.mods.noctalia;
  in {
    options.self.mods.noctalia = {
      inherit (options.programs.noctalia) package;
      enable = self.lib.mkAutoEnableOption options.programs.noctalia.enable;
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
