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
      ++ (with self.nixOnDroidModules; [core]);

    environment = {
      etcBackupExtension = "bk";
      packages = with pkgs; [
        git
        nano
      ];
      motd = null;
    };

    nix = {
      extraOptions = ''
        extra-experimental-features = flakes nix-command
      '';

      nixPath =
        lib.mapAttrsToList (k: _: "${k}=flake:${k}") config.nix.registry;

      package = inputs'.nixpkgs-nod.legacyPackages.nixVersions.nix_2_31;

      registry =
        lib.mapAttrs (_: value: {flake = value;})
        (lib.filterAttrs (_: value: lib.isType "flake" value) inputs)
        // {
          nixpkgs-master.to = {
            type = "github";
            owner = "nixos";
            repo = "nixpkgs";
          };
        };
    };

    system.stateVersion = "24.05";

    time.timeZone = "America/Sao_Paulo";

    user.shell = lib.getExe config.custom.wrappers.fish.wrapper;
  };
}
