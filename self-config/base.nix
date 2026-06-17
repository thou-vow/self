{
  lib,
  inputs,
  nixConfig,
  ...
}: {
  flake.hjemModules.base = _: {
  };

  flake.nixOnDroidModules.base = {config, ...}: {
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

  flake.nixosModules.base = {config, ...}: {
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

  flake.wrapperIntegrationModules.base = _: {
  };

  flake.wrapperModules.base = _: {
    escapingFunction = str: str;
  };
}
