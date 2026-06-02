{
  lib,
  inputs,
  nixConfig,
  withSystem,
  ...
}: let
  commonModuleArgs = system: {
    inherit
      (withSystem system (args: args))
      inputs'
      self'
      ;
  };
in {
  flake.hjemModules.base = {system, ...}: {
    _module.args = commonModuleArgs system;
  };

  flake.nixOnDroidModules.base = {
    config,
    system,
    ...
  }: {
    _module.args = commonModuleArgs system;

    nix = {
      extraOptions = let
        inherit (nixConfig) extra-substituters extra-trusted-public-keys;
      in
        lib.mkMerge [
          ''
            extra-experimental-features = flakes nix-command
            extra-substituters = ${toString extra-substituters}
            extra-trusted-public-keys = ${toString extra-trusted-public-keys}
            keep-derivations = true
            keep-outputs = true
          ''
        ];

      nixPath = lib.mapAttrsToList (k: _: "${k}=flake:${k}") config.nix.registry;

      registry = lib.pipe inputs [
        (lib.filterAttrs (_: value: lib.isType "flake" value))
        (lib.mapAttrs (_: value: {flake = value;}))
      ];
    };
  };

  flake.nixosModules.base = {
    config,
    system,
    ...
  }: {
    _module.args = commonModuleArgs system;

    nix = {
      nixPath = lib.mapAttrsToList (k: _: "${k}=flake:${k}") config.nix.registry;

      registry = lib.pipe inputs [
        (lib.filterAttrs (_: value: lib.isType "flake" value))
        (lib.mapAttrs (_: value: {flake = value;}))
      ];

      settings = {
        inherit (nixConfig) extra-substituters extra-trusted-public-keys;
        extra-experimental-features = ["flakes" "nix-command"];
        keep-derivations = true;
        keep-outputs = true;
        trusted-users = ["@wheel"];
      };
    };
  };

  flake.wrapperIntegrationModules.base = {system, ...}: {
    _module.args = commonModuleArgs system;
  };

  flake.wrapperModules.base = {system, ...}: {
    _module.args = commonModuleArgs system;
  };
}
