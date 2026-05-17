{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake = {
    nixOnDroidConfigurations.leia =
      self.lib.nixOnDroidConfiguration
      (withSystem "aarch64-linux" ({pkgs-nod, ...}: pkgs-nod)) {
        modules = [self.nixOnDroidModules.leia];
      };

    nixOnDroidModules.leia = {
      config,
      inputs',
      pkgs,
      system,
      ...
    }: {
      imports =
        [
          (self.lib.installWrappers system {
            method.nixOnDroid = true;
            wrappers = {
              inherit
                (self.wrappers)
                atuin
                direnv
                git
                helix
                nushell
                ;
            };
          })
        ]
        ++ (with self.nixOnDroidModules; [
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

      user.shell = lib.getExe config.wrappers.nushell.wrapper;
    };
  };
}
