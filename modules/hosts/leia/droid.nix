{
  inputs,
  lib,
  self,
  ...
}: {
  flake.nixOnDroidModules.leia = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports =
      [
        (self.lib.mkInstallWrappers {
          method.variant = "nixOnDroid";
          wrappers = {
            inherit
              (self.wrappers)
              atuin
              direnv
              fish
              git
              helix
              ;
          };
        })
      ]
      ++ (with self.nixOnDroidModules; [
        core
        nix
        state
      ]);

    wrappers = {
      git.settings.user = {
        email = "thou.vow.etoile@gmail.com";
        name = "thou-vow";
      };
    };

    environment = {
      etcBackupExtension = "bk";
      packages = with pkgs; [
        nano
      ];
      motd = null;
    };

    nix.package = inputs'.nixpkgs-nod.legacyPackages.nixVersions.latest;

    system.stateVersion = "24.05";

    time.timeZone = "America/Sao_Paulo";

    user.shell = lib.getExe config.wrappers.fish.wrapper;
  };
}
