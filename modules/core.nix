{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {

    flake = {
      nixOnDroidModules.core = {pkgs, ...}: {
        _module.args = let
          system = pkgs.stdenv.hostPlatform.system;
        in {
          inherit (withSystem system (args: args)) inputs' self';
          inherit system;
        };
      };

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
}
