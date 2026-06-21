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
    steel = {
      cogs = {
        "mattwparas-helix-package".subject.source = pkgs.fetchFromGitHub {
          owner = "mattwparas";
          repo = "helix-config";
          rev = "a101da0852932f10792f098dbb14ea88811985ff";
          hash = "sha256-N4Y78H9HDJernQkdH+24tylfl1bleBZewTB7Fk9LlGg=";
        };
        "self".subject.source = ./cogs;
        "steel-pty".subject.source = pkgs.fetchFromGitHub {
          owner = "mattwparas";
          repo = "steel-pty";
          rev = "4d41b6988107b50777d87e587fba7b6b272f069e";
          hash = "sha256-7teIMyLmfPkNEhTFlzmtKaewwwDrlcgmx06prUqXz1g=";
        };
      };
      extraConfigFiles = {
        "init".subject.source = ./init;
        "manual-init.scm".subject.source = ./manual-init.scm;
      };
      initScm.manual =
        wlib.dag.entryAnywhere
        # scm
        ''
          (require "manual-init.scm")
        '';
    };
  };

  flake.wrapperIntegrationPresets.helix = {config, ...}: {
    helix.steel = lib.mkIf (config.preferences or {} != {}) {
      extraConfigFiles."init-theme.scm".subject.text = let
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
