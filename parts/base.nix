{
  inputs,
  lib,
  nixConfig,
  self,
  ...
}: let
  commonOptions = {
    enable = self.lib.mkAutoEnableOption "common settings";
    flakePath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "The absolute path of this flake.";
      default = null;
    };
  };

  flakeInputs = lib.filterAttrs (k: v: lib.isAttrs v && lib.isType "flake" v) inputs;
in {
  flake.homeModules.base = {
    config,
    nixosConfig ? {},
    ...
  }: let
    cfg = config.self.base;
  in {
    options.self.base = commonOptions;

    config = lib.mkIf (cfg.enable && nixosConfig != {}) {
      nix = {
        registry = lib.mkMerge [
          (lib.mapAttrs (_: v: {flake = v;}) flakeInputs)
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
          nix-path = lib.mapAttrsToList (k: v: "${k}=flake:${k}") config.nix.registry;
          trusted-users = ["@wheel"];
        };
      };
    };
  };

  flake.nixosModules.base = {config, ...}: let
    cfg = config.self.base;
  in {
    options.self.base = commonOptions;

    config = lib.mkIf cfg.enable {
      nix = {
        registry = lib.mkMerge [
          (lib.mapAttrs (_: v: {flake = v;}) flakeInputs)
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
          nix-path = lib.mapAttrsToList (k: v: "${k}=flake:${k}") config.nix.registry;
          trusted-users = ["@wheel"];
        };
      };
    };
  };
}
