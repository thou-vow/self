{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: let
  commonModuleArgs = system: {
    inherit
      (withSystem system (args: args))
      inputs'
      self'
      ;
    inherit system;
  };
in {
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
                      {pkgs = value.pkgsPerSystem system;}
                    ];
                    specialArgs = commonModuleArgs system;
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
                ++ [packagesModule]
                ++ extraIntegrationModules;
              specialArgs = commonModuleArgs system;
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
            {pkgs = wrapper.pkgsPerSystem system;}
          ]
          ++ extraWrapperModules;
        specialArgs = commonModuleArgs system;
      };
    in
      eval.config.wrapper;

    mkWrapperSetPackage = {
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
        name = "wrapperSet";
        paths = eval.config.wrappers.packages;
      };

    nixOnDroidConfiguration = {pkgs}: primaryAttrs:
      inputs.nix-on-droid.lib.nixOnDroidConfiguration (primaryAttrs
        // {
          inherit pkgs;
          extraSpecialArgs =
            commonModuleArgs pkgs.stdenv.hostPlatform.system
            // primaryAttrs.extraSpecialArgs or {};
        });

    nixosSystem = {
      pkgs,
      hjem ? false,
    }: primaryAttrs:
      lib.nixosSystem (primaryAttrs
        // {
          modules =
            [{nixpkgs = {inherit pkgs;};}]
            ++ lib.optionals hjem [
              inputs.hjem.nixosModules.default
              {hjem.specialArgs = commonModuleArgs pkgs.stdenv.hostPlatform.system;}
            ]
            ++ primaryAttrs.modules or [];
          specialArgs =
            commonModuleArgs pkgs.stdenv.hostPlatform.system
            // primaryAttrs.specialArgs or {};
        });
  };
}
