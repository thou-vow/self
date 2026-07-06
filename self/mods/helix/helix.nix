{
  lib,
  self,
  ...
}: {
  flake.homeModules.helix = {
    config,
    inputs',
    pkgs,
    ...
  }: let
    cfg = config.self.mods.helix;
  in {
    options.self.mods.helix = {
      enable = self.lib.mkAutoEnableOption "Helix";
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs'.nix-packages.packages.helix-steel;
        description = "The Helix package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      home.sessionSearchVariables = {
        STEEL_SEARCH_PATHS = [
          "${pkgs.linkFarm "helix-cogs" [
            {
              name = "mattwparas-helix-package";
              path = pkgs.fetchFromGitHub {
                owner = "mattwparas";
                repo = "helix-config";
                rev = "a101da0852932f10792f098dbb14ea88811985ff";
                hash = "sha256-N4Y78H9HDJernQkdH+24tylfl1bleBZewTB7Fk9LlGg=";
              };
            }
            {
              name = "self";
              path = ./cogs;
            }
            {
              name = "steel-pty";
              path = pkgs.fetchFromGitHub {
                owner = "mattwparas";
                repo = "steel-pty";
                rev = "4d41b6988107b50777d87e587fba7b6b272f069e";
                hash = "sha256-7teIMyLmfPkNEhTFlzmtKaewwwDrlcgmx06prUqXz1g=";
              };
            }
          ]}"
        ];
      };

      programs.helix = lib.mkMerge [
        {inherit (cfg) enable package;}
        (lib.mkIf (config.self.style.enable or false) {
          settings.theme = "self";
          themes.self = import ./_helix-theme.nix config.self.style;
        })
      ];

      xdg.configFile = {
        "helix/init".source = ./init;
        "helix/init.scm".text =
          # scm
          ''
            (require "manual-init.scm")
          '';
        "helix/manual-init.scm".source = ./manual-init.scm;
      };
    };
  };
}
