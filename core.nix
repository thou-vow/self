{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  options.flake = {
    wrappers = lib.mkOption {
      type = lib.types.lazyAttrsOf (lib.types.submodule {
        options = {
          integrationModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
          module = lib.mkOption {type = lib.types.deferredModule;};
          nixosModule = lib.mkOption {type = with lib.types; nullOr deferredModule;};
          nixosUserModule = lib.mkOption {type = with lib.types; nullOr (functionTo deferredModule);};
        };
      });
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

  config = {
    flake = {
      nixosModules.core = {pkgs, ...}: {
        options.custom = {
          flakePath = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "The absolute path of this flake.";
          };
        };

        config = {
          _module.args = let
            system = pkgs.stdenv.hostPlatform.system;
          in {
            inherit (withSystem system (args: args)) inputs' self';
            inherit system;
          };
        };
      };

      nixosUserModules.core = user: let
        namespace = ["custom" "users" user];
      in {
        options = lib.setAttrByPath namespace (lib.mkOption {
          type = lib.types.submodule {
            options = {
              shellAliases = lib.mkOption {
                type = lib.types.attrsOf lib.types.str;
                default = {};
              };
              variables = lib.mkOption {
                type = with lib.types; attrsOf (oneOf [int float path str]);
                default = {};
              };
            };
          };
          default = {};
        });
      };

      wrapperModules.core = {pkgs, ...}: {
        imports = [
          inputs.nix-wrapper-modules.lib.modules.default
        ];

        _module.args = let
          system = pkgs.stdenv.hostPlatform.system;
        in {
          inherit (withSystem system (args: args)) inputs' self';
          inherit system;
        };
      };
    };

    perSystem = {system, ...}: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    };
  };
}
