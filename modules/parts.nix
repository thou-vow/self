{
  flake-parts-lib,
  lib,
  ...
}: {
  options = {
    flake = {
      wrappers = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.submodule {
          options = {
            integrationModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            module = lib.mkOption {type = lib.types.deferredModule;};
            nixOnDroidModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            nixosModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            nixosUserModule = lib.mkOption {type = with lib.types; nullOr (functionTo deferredModule);};
          };
        });
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

      nixosUserModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf (functionTo deferredModule);
        default = {};
      };

      wrapperModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrapperIntegrationModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };
    };

    perSystem = flake-parts-lib.mkPerSystemOption {
      options.pkgs =
        lib.pipe [
          "default"
          "nixOnDroid"
          "nixos"
          "wrappers"
        ] [
          (map (name: {
            inherit name;
            value = lib.mkOption {type = lib.types.pkgs;};
          }))
          builtins.listToAttrs
        ];
    };

    substituters = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          keys = lib.mkOption {type = with lib.types; listOf str;};
          urls = lib.mkOption {type = with lib.types; listOf str;};
        };
      });
      default = {};
    };
  };

  config.perSystem = {config, ...}: {
    _module.args.pkgs = config.pkgs.default;
  };
}
