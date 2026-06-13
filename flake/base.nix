{
  lib,
  inputs,
  nixConfig,
  withSystem,
  ...
}: {
  flake.hjemModules.base = {system, ...}: {
  };

  flake.nixOnDroidModules.base = {
    config,
    system,
    ...
  }: {
    nix = {
      extraOptions = ''
        extra-experimental-features = ${toString ["flakes" "nix-command"]}
        extra-substituters = ${toString nixConfig.extra-substituters}
        extra-trusted-public-keys = ${toString nixConfig.extra-trusted-public-keys}
        keep-derivations = true
        keep-outputs = true
      '';

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
  };

  flake.wrapperModules.base = {system, ...}: {
    escapingFunction = str: str;
  };
}
