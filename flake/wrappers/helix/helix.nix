{
  inputs,
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.helix = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.helix;
  };

  flake.wrapperModules.helix = {
    config,
    pkgs,
    ...
  }: {
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
}
