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

    environment = {
      etcBackupExtension = "bk";
      packages = with pkgs; [
        git
        nano
      ];
      motd = null;
    };

    system.stateVersion = "24.05";

    time.timeZone = "America/Sao_Paulo";

    user.shell = lib.getExe config.wrappers.fish.wrapper;
  };
}
