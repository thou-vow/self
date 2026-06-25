{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.helix = {
    autoDiscoverModules = "helix";
    autoDiscoverPresets = "helix";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.helix = {pkgs, ...}: {
    cogs = {
      "mattwparas-helix-package".path = pkgs.fetchFromGitHub {
        owner = "mattwparas";
        repo = "helix-config";
        rev = "a101da0852932f10792f098dbb14ea88811985ff";
        hash = "sha256-N4Y78H9HDJernQkdH+24tylfl1bleBZewTB7Fk9LlGg=";
      };
      "self".path = ./cogs;
      "steel-pty".path = pkgs.fetchFromGitHub {
        owner = "mattwparas";
        repo = "steel-pty";
        rev = "4d41b6988107b50777d87e587fba7b6b272f069e";
        hash = "sha256-7teIMyLmfPkNEhTFlzmtKaewwwDrlcgmx06prUqXz1g=";
      };
    };
    extraConfigFiles = {
      "init".path = ./init;
      "manual-init.scm".path = ./manual-init.scm;
    };
    initScm.manual =
      wlib.dag.entryAnywhere
      # scm
      ''
        (require "manual-init.scm")
      '';
  };

  flake.wrapperIntegrationPresets.helix = {config, ...}: {
    helix = lib.mkIf (config.preferences or {} != {}) {
      extraConfigFiles."init-theme.scm".content = let
        theme = import ./_helix-theme.nix config.preferences.style;
      in
        # scm
        ''
          (require (prefix-in hx.cmd. "helix/commands.scm"))
          (require (prefix-in hx.theme. "helix/themes.scm"))
          (hx.theme.register-theme (hx.theme.hashmap->theme "self" ${self.lib.toSteel theme}))
          (hx.cmd.theme "self")
        '';

      initScm.theme =
        wlib.dag.entryAnywhere
        # scm
        ''
          (require "init-theme.scm")
        '';
    };
  };
}
