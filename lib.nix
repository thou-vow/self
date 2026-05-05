{
  inputs,
  lib,
  self,
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

    mkWrappersPackage = {
      name,
      pkgs,
      wrappers,
    }:
      lib.pipe {
        modules = [
          {_module.args = {inherit pkgs;};}
          (self.lib.mkInstallWrappers {
            method = {
              variant = "direct";
              namespace = ["namespace"];
            };
            inherit wrappers;
          })
        ];
      } [
        lib.evalModules
        (eval:
          pkgs.symlinkJoin {
            inherit name;
            paths = eval.config.namespace.packages;
          })
      ];

    mkInstallWrappers = {
      method,
      wrappers,
    }: let
      namespace =
        {
          direct = method.namespace;
          nixos = ["custom" "wrappers"];
          nixosUser = ["custom" "users" method.user "wrappers"];
        }.${
          method.variant
        } or (throw "Unexpected method.variant in mkInstallWrappers: ${method.variant}");
    in
      {pkgs, ...}: {
        imports =
          {
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
            wrapperOptionModules =
              lib.mapAttrsToList (name: value: {
                options = lib.setAttrByPath [name] (lib.mkOption {
                  default = {};
                  type = inputs.nix-wrapper-modules.lib.types.subWrapperModule [
                    value.module
                    {inherit pkgs;}
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
            lib.types.submodule (wrapperOptionModules ++ integrationModules ++ [packagesModule]);

          default = {};
        });
      };
  };
}
