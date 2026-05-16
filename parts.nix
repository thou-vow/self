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

      lib = lib.mkOption {
        type = lib.types.attrs;
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
  };
}
