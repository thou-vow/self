{
  inputs,
  lib,
  ...
} @ top: {
  options = {
    flake = {
      hjemModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      hjemPresets = lib.mkOption {
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

      nixOnDroidPresets = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      nixosPresets = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrapperIntegrationModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrapperIntegrationPresets = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrapperModules = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrapperPresets = lib.mkOption {
        type = with lib.types; lazyAttrsOf deferredModule;
        default = {};
      };

      wrappers = lib.mkOption {
        type = lib.types.lazyAttrsOf (lib.types.submodule ({config, ...}: {
          options = {
            autoDiscoverModules = lib.mkOption {type = with lib.types; nullOr str;};
            autoDiscoverPresets = lib.mkOption {type = with lib.types; nullOr str;};
            hjem = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            nixOnDroid = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            nixos = lib.mkOption {type = with lib.types; nullOr deferredModule;};
            pkgsPerSystem = lib.mkOption {type = with lib.types; functionTo pkgs;};
            wrapper = lib.mkOption {type = lib.types.deferredModule;};
            wrapperIntegration = lib.mkOption {type = with lib.types; nullOr deferredModule;};
          };

          config = lib.mkMerge [
            (lib.mkIf (config.autoDiscoverModules != null) {
              hjem = top.config.flake.hjemModules.${config.autoDiscoverModules} or {};
              nixOnDroid = top.config.flake.nixOnDroidModules.${config.autoDiscoverModules} or {};
              nixos = top.config.flake.nixosModules.${config.autoDiscoverModules} or {};
              wrapper = top.config.flake.wrapperModules.${config.autoDiscoverModules} or {};
              wrapperIntegration = top.config.flake.wrapperIntegrationModules.${config.autoDiscoverModules} or {};
            })
            (lib.mkIf (config.autoDiscoverPresets != null) {
              hjem = top.config.flake.hjemPresets.${config.autoDiscoverPresets} or {};
              nixOnDroid = top.config.flake.nixOnDroidPresets.${config.autoDiscoverPresets} or {};
              nixos = top.config.flake.nixosPresets.${config.autoDiscoverPresets} or {};
              wrapper = top.config.flake.wrapperPresets.${config.autoDiscoverPresets} or {};
              wrapperIntegration = top.config.flake.wrapperIntegrationPresets.${config.autoDiscoverPresets} or {};
            })
          ];
        }));
      };
    };
  };
}
