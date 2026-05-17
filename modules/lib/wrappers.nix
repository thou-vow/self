{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.lib = {
    installWrappers = system: {
      method,
      wrappers,
      extraIntegrationModules ? [],
    }: let
      namespace =
        if method ? direct
        then method.direct.namespace
        else if method ? nixOnDroid
        then ["wrappers"]
        else if method ? nixos
        then ["wrappers"]
        else if method ? nixosUser
        then ["wrappers" "users" method.nixosUser.user]
        else throw "Unexpected method in installWrappers: ${builtins.toJSON method}";
    in {
      imports =
        if method ? nixOnDroid
        then
          lib.pipe wrappers [
            (lib.filterAttrs (_: v: v.nixOnDroidModule or null != null))
            (lib.mapAttrsToList (_: v: v.nixOnDroidModule))
          ]
          ++ [
            ({config, ...}: {
              environment.packages = lib.attrByPath (namespace ++ ["packages"]) [] config;
            })
          ]
        else if method ? nixos
        then
          lib.pipe wrappers [
            (lib.filterAttrs (_: v: v.nixosModule or null != null))
            (lib.mapAttrsToList (_: v: v.nixosModule))
          ]
          ++ [
            ({config, ...}: {
              environment.systemPackages = lib.attrByPath (namespace ++ ["packages"]) [] config;
            })
          ]
        else if method ? nixosUser
        then
          lib.pipe wrappers [
            (lib.filterAttrs (_: v: v.nixosUserModule or null != null))
            (lib.mapAttrsToList (_: v: v.nixosUserModule method.nixosUser.user))
          ]
          ++ [
            ({config, ...}: {
              users.users.${method.nixosUser.user}.packages =
                lib.attrByPath (namespace ++ ["packages"]) [] config;
            })
          ]
        else [];

      options = lib.setAttrByPath namespace (lib.mkOption {
        type = let
          optionModules =
            lib.mapAttrsToList (name: value: {
              options = lib.setAttrByPath [name] (lib.mkOption {
                default = {};
                type = inputs.nix-wrapper-modules.lib.types.subWrapperModule [
                  value.module
                  {pkgs = value.pkgsPerSystem system;}
                  self.wrapperModules.core
                ];
              });
            })
            wrappers;

          integrationModules = lib.pipe wrappers [
            (lib.filterAttrs (_: v: v.integrationModule or null != null))
            (lib.mapAttrsToList (_: v: v.integrationModule))
          ];

          packagesModule = {config, ...}: {
            options.packages = lib.mkOption {
              type = lib.types.listOf lib.types.package;
              default = [];
            };
            config.packages = map (name: config.${name}.wrapper) (builtins.attrNames wrappers);
          };
        in
          lib.types.submodule (optionModules
            ++ integrationModules
            ++ [
              packagesModule
              self.wrapperIntegrationModules.core
            ]
            ++ extraIntegrationModules);

        default = {};
      });
    };

    mkWrappersPackage = pkgs: {
      wrappers,
      extraIntegrationModules ? [],
    }:
      (eval:
        pkgs.symlinkJoin {
          name = "wrappersPackage";
          paths = eval.config.wrappers.packages;
        }) (lib.evalModules {
        modules = [
          (self.lib.installWrappers pkgs.stdenv.hostPlatform.system {
            inherit extraIntegrationModules wrappers;
            method.direct.namespace = ["wrappers"];
          })
        ];
      });
  };
}
