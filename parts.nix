{
  flake-parts-lib,
  lib,
  ...
}: {
  options = {
    flake = {
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

      perSystem = flake-parts-lib.mkPerSystemOption {
        options.wrappers = lib.mkOption {
          type = lib.types.lazyAttrsOf (lib.types.submodule ({config, ...}: {
            options = {
              integrationModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
              module = lib.mkOption {type = lib.types.deferredModule;};
              nixOnDroidModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
              nixosModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
              nixosUserModule = lib.mkOption {type = with lib.types; nullOr (functionTo deferredModule);};
              package = lib.mkOption {
                readOnly = true;
                type = lib.types.package;
                default = config.module.wrap {inherit (config) pkgs;};
              };
              pkgs = lib.mkOption {type = lib.types.pkgs;};
            };
          }));
        };
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
        type = lib.types.lazyAttrsOf (lib.types.submodule ({config, ...}: {
          options = {
            integrationModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            module = lib.mkOption {type = lib.types.deferredModule;};
            nixOnDroidModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            nixosModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            nixosUserModule = lib.mkOption {type = with lib.types; nullOr (functionTo deferredModule);};
            pkgsPerSystem = lib.mkOption {type = with lib.types; functionTo pkgs;};
          };
        }));
      };
    };
  };
}
