{
  lib,
  inputs,
  nixConfig,
  self,
  ...
}: let
  baseOptions = {
    enable = self.lib.mkAutoEnableOption "common settings";
    flakePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The absolute path of this flake.";
      default = null;
    };
  };
in {
  flake.homeModules.base = {config, ...}: let
    cfg = config.self.base;
  in {
    options.self.base = baseOptions;

    config.nix = lib.mkIf (cfg.enable && config.nix.package != null) {
      nixPath = lib.mapAttrsToList (k: _: "${k}=flake:${k}") config.nix.registry;

      registry = lib.mkMerge [
        (lib.pipe inputs [
          (lib.filterAttrs (_: value: lib.isType "flake" value))
          (lib.mapAttrs (_: value: {flake = value;}))
        ])
        (lib.mkIf (config.self.base.flakePath != null) {
          self.to = lib.mkOverride 99 {
            type = "git";
            url = "file://${config.self.base.flakePath}";
          };
        })
      ];

      settings = {
        inherit (nixConfig) extra-substituters extra-trusted-public-keys;
        extra-experimental-features = ["flakes" "nix-command"];
        keep-outputs = true;
        trusted-users = ["@wheel"];
      };
    };
  };

  flake.nixosModules.base = {config, ...}: let
    cfg = config.self.base;
  in {
    options.self.base = baseOptions;

    config.nix = lib.mkIf cfg.enable {
      nixPath = lib.mapAttrsToList (k: _: "${k}=flake:${k}") config.nix.registry;

      registry = lib.mkMerge [
        (lib.pipe inputs [
          (lib.filterAttrs (_: value: lib.isType "flake" value))
          (lib.mapAttrs (_: value: {flake = value;}))
        ])
        (lib.mkIf (config.self.base.flakePath != null) {
          self.to = {
            type = "git";
            url = "file://${config.self.base.flakePath}";
          };
        })
      ];

      settings = {
        inherit (nixConfig) extra-substituters extra-trusted-public-keys;
        extra-experimental-features = ["flakes" "nix-command"];
        keep-outputs = true;
        trusted-users = ["@wheel"];
      };
    };
  };
}
