{
  inputs,
  lib,
  ...
}: {
  options = {
    flake = {
      hjemModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      lib = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.lazyAttrsOf lib.types.raw;
          options = {
            types = lib.mkOption {
              type = lib.types.attrsOf lib.types.raw;
              default = {};
            };
          };
        };
        default = {};
      };

      nixOnDroidConfigurations = lib.mkOption {
        type = with lib.types; lazyAttrsOf raw;
        default = {};
      };

      nixOnDroidModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrapperIntegrationModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrapperModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrappers = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.submodule {
          options = {
            hjemModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            integrationModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            module = lib.mkOption {type = lib.types.deferredModule;};
            nixOnDroidModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            nixosModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            pkgsPerSystem = lib.mkOption {type = with lib.types; functionTo pkgs;};
          };
        });
      };
    };
  };

  config.flake.schemas =
    inputs.flake-schemas.schemas
    // {
      nixOnDroidConfigurations = {
        version = 1;
        doc = ''
          The `nixOnDroidConfigurations` flake output defines [Nix-on-Droid configurations](https://github.com/nix-community/nix-on-droid).
        '';
        inventory = output:
          inputs.flake-schemas.lib.mkChildren (
            builtins.mapAttrs (configName: device: {
              what = "Nix-on-Droid configuration";
              derivationAttrPath = ["config" "build" "activationPackage"];
              forSystems = [device.pkgs.stdenv.system];
            })
            output
          );
      };
    };
}
