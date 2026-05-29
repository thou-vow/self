{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.lib = {
    installWrappers = {
      method,
      wrappers,
      extraIntegrationModules ? [],
    }: let
      namespace =
        if method ? direct
        then method.direct.namespace
        else if method ? hjem
        then ["wrappers"]
        else if method ? nixOnDroid
        then ["wrappers"]
        else if method ? nixos
        then ["wrappers"]
        else throw "Unexpected method in installWrappers: ${builtins.toJSON method}";
    in
      {system, ...}: {
        imports =
          if method ? hjem
          then
            lib.pipe wrappers [
              (lib.filterAttrs (_: v: v.hjemModule or null != null))
              (lib.mapAttrsToList (_: v: v.hjemModule))
            ]
            ++ [
              ({config, ...}: {
                packages = lib.attrByPath (namespace ++ ["packages"]) [] config;
              })
            ]
          else if method ? nixOnDroid
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
          else [];

        options = lib.setAttrByPath namespace (lib.mkOption {
          type = let
            optionModules =
              lib.mapAttrsToList (name: value: {
                options = lib.setAttrByPath [name] (lib.mkOption {
                  default = {};
                  type = inputs.nix-wrapper-modules.lib.types.subWrapperModuleWith {
                    modules = [
                      value.module
                      self.wrapperModules.base
                      {pkgs = value.pkgsPerSystem system;}
                    ];
                    specialArgs = {inherit system;};
                  };
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
            lib.types.submoduleWith {
              modules =
                optionModules
                ++ integrationModules
                ++ [
                  packagesModule
                  self.wrapperIntegrationModules.base
                ]
                ++ extraIntegrationModules;
              specialArgs = {inherit system;};
            };

          default = {};
        });
      };

    mkWrapperPackage = {
      system,
      wrapper,
      extraWrapperModules ? [],
    }: let
      eval = inputs.nix-wrapper-modules.lib.evalModules {
        modules =
          [
            wrapper.module
            self.wrapperModules.base
            {pkgs = wrapper.pkgsPerSystem system;}
          ]
          ++ extraWrapperModules;
        specialArgs = {inherit system;};
      };
    in
      eval.config.wrapper;

    mkWrappersEnv = {
      system,
      wrappers,
      extraIntegrationModules ? [],
    }: let
      eval = lib.evalModules {
        modules = [
          (self.lib.installWrappers {
            inherit extraIntegrationModules wrappers;
            method.direct.namespace = ["wrappers"];
          })
        ];
        specialArgs = {inherit system;};
      };
    in
      (withSystem system ({pkgs, ...}: pkgs)).symlinkJoin {
        name = "wrappersEnv";
        paths = eval.config.wrappers.packages;
      };

    nixOnDroidConfiguration = {pkgs}: primaryAttrs: let
      system = pkgs.stdenv.hostPlatform.system;
    in
      inputs.nix-on-droid.lib.nixOnDroidConfiguration (primaryAttrs
        // {
          inherit pkgs;
          extraSpecialArgs = {inherit system;} // primaryAttrs.extraSpecialArgs or {};
          modules = [self.nixOnDroidModules.base] ++ primaryAttrs.modules or [];
        });

    nixosSystem = {
      pkgs,
      hjem ? false,
    }: primaryAttrs: let
      system = pkgs.stdenv.hostPlatform.system;
    in
      lib.nixosSystem (primaryAttrs
        // {
          modules =
            [
              self.nixosModules.base
              {nixpkgs = {inherit pkgs;};}
            ]
            ++ lib.optionals hjem [
              inputs.hjem.nixosModules.default
              {
                hjem = {
                  extraModules = [self.hjemModules.base];
                  specialArgs = {inherit system;};
                };
              }
            ]
            ++ primaryAttrs.modules or [];
          specialArgs = {inherit system;} // primaryAttrs.specialArgs or {};
        });
  };
}
