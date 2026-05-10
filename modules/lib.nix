{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.lib = {
    mkLinkFarmOptionalText = pred: {
      name,
      pkgs,
      text,
    }:
      lib.optionals pred [
        {
          inherit name;
          path = pkgs.writeTextFile {
            inherit name text;
          };
        }
      ];

    mkWrappersPackage = system: {
      name,
      wrappers,
      extraIntegrationModules ? [],
    }: let
        pkgs = withSystem system ({config,...}: config.pkgs.nixOnDroid);
    in
      (eval:
        pkgs.symlinkJoin {
          inherit name;
          paths = eval.config.namespace.packages;
        }) (lib.evalModules {
        modules = [
          (self.lib.mkInstallWrappers system {
            inherit extraIntegrationModules wrappers;
            method = {
              variant = "direct";
              namespace = ["namespace"];
            };
          })
        ];
      });

    mkInstallWrappers = system: {
      method,
      wrappers,
      extraIntegrationModules ? [],
    }: let
      namespace =
        {
          direct = method.namespace;
          nixOnDroid = ["wrappers"];
          nixos = ["wrappers"];
          nixosUser = ["wrappers" "users" method.user];
        }.${
          method.variant
        } or (throw "Unexpected method.variant in mkInstallWrappers: ${method.variant}");
    in {
      imports =
        {
          nixOnDroid =
            lib.pipe wrappers [
              (lib.filterAttrs (_: v: v.nixOnDroidModule or null != null))
              (lib.mapAttrsToList (_: v: v.nixOnDroidModule))
            ]
            ++ [
              ({config, ...}: {
                environment.packages =
                  lib.attrByPath (namespace ++ ["packages"]) [] config;
              })
            ];
          nixos =
            lib.pipe wrappers [
              (lib.filterAttrs (_: v: v.nixosModule or null != null))
              (lib.mapAttrsToList (_: v: v.nixosModule))
            ]
            ++ [
              ({config, ...}: {
                environment.systemPackages =
                  lib.attrByPath (namespace ++ ["packages"]) [] config;
              })
            ];
          nixosUser =
            lib.pipe wrappers [
              (lib.filterAttrs (_: v: v.nixosUserModule or null != null))
              (lib.mapAttrsToList (_: v: v.nixosUserModule method.user))
            ]
            ++ [
              ({config, ...}: {
                users.users.${method.user}.packages =
                  lib.attrByPath (namespace ++ ["packages"]) [] config;
              })
            ];
        }.${
          method.variant
        } or [
        ];

      options = lib.setAttrByPath namespace (lib.mkOption {
        type = let
          pkgs = withSystem system ({config, ...}: config.pkgs.wrappers);

          wrapperOptionModules =
            lib.mapAttrsToList (name: value: {
              options = lib.setAttrByPath [name] (lib.mkOption {
                default = {};
                type = inputs.nix-wrapper-modules.lib.types.subWrapperModule [
                  value.module
                  {inherit pkgs;}
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
          lib.types.submodule (wrapperOptionModules
            ++ integrationModules
            ++ [
              packagesModule
              {_module.args = {inherit pkgs;};}
              self.wrapperIntegrationModules.core
            ]
            ++ extraIntegrationModules);

        default = {};
      });
    };

    nixOnDroidConfiguration = system: {modules, ...} @ attrs:
      inputs.nix-on-droid.lib.nixOnDroidConfiguration (
        attrs
        // {
          modules = modules ++ [self.nixOnDroidModules.core];
          pkgs = withSystem system ({config, ...}: config.pkgs.nixOnDroid);
        }
      );

    nixosSystem = system: {modules, ...} @ attrs:
      lib.nixosSystem (
        attrs
        // {
          modules =
            modules
            ++ [
              {nixpkgs.pkgs = withSystem system ({config, ...}: config.pkgs.nixos);}
              self.nixosModules.core
            ];
        }
      );
  };
}
