{
  inputs,
  lib,
  self,
  withSystem,
  wlib,
  ...
}: let
  commonArgs = system: {
    inherit
      (withSystem system (args: args))
      inputs'
      self'
      system
      ;
  };
in {
  flake.lib = {
    installWrappers = {
      method,
      wrappers,
      extraWrapperIntegrations ? [],
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
              (lib.filterAttrs (_: v: v.hjem or null != null))
              (lib.mapAttrsToList (_: v: v.hjem))
            ]
            ++ [
              ({config, ...}: {
                packages = lib.attrByPath (namespace ++ ["packages"]) [] config;
              })
            ]
          else if method ? nixOnDroid
          then
            lib.pipe wrappers [
              (lib.filterAttrs (_: v: v.nixOnDroid or null != null))
              (lib.mapAttrsToList (_: v: v.nixOnDroid))
            ]
            ++ [
              ({config, ...}: {
                environment.packages = lib.attrByPath (namespace ++ ["packages"]) [] config;
              })
            ]
          else if method ? nixos
          then
            lib.pipe wrappers [
              (lib.filterAttrs (_: v: v.nixos or null != null))
              (lib.mapAttrsToList (_: v: v.nixos))
            ]
            ++ [
              ({config, ...}: {
                environment.systemPackages = lib.attrByPath (namespace ++ ["packages"]) [] config;
              })
            ]
          else [];

        options = lib.setAttrByPath namespace (lib.mkOption {
          type = lib.types.submoduleWith {
            modules =
              lib.pipe wrappers [
                (lib.mapAttrsToList (k: v: {
                  options = lib.setAttrByPath [k] (lib.mkOption {
                    default = {};
                    type = wlib.types.subWrapperModuleWith {
                      modules = [
                        v.wrapper
                        self.wrapperPresets.base
                        {pkgs = v.pkgsPerSystem system;}
                      ];
                      specialArgs = commonArgs system;
                    };
                  });
                }))
              ]
              ++ lib.pipe wrappers [
                (lib.filterAttrs (_: v: v.wrapperIntegration or null != null))
                (lib.mapAttrsToList (_: v: v.wrapperIntegration))
              ]
              ++ [
                ({config, ...}: {
                  options.packages = lib.mkOption {
                    type = lib.types.listOf lib.types.package;
                    default = [];
                  };
                  config.packages = map (k: config.${k}.wrapper) (builtins.attrNames wrappers);
                })
                self.wrapperIntegrationPresets.base
              ]
              ++ extraWrapperIntegrations;
            specialArgs = commonArgs system;
          };

          default = {};
        });
      };

    mkWrapperPackage = {
      system,
      wrapper,
    }: let
      eval = wlib.evalModules {
        modules = [
          wrapper.wrapper
          self.wrapperPresets.base
          {pkgs = wrapper.pkgsPerSystem system;}
        ];
        specialArgs = commonArgs system;
      };
    in
      eval.config.wrapper;

    mkWrappersSet = {
      system,
      wrappers,
      extraWrapperIntegrations ? [],
    }: let
      eval = lib.evalModules {
        modules = [
          (self.lib.installWrappers {
            inherit extraWrapperIntegrations wrappers;
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
          extraSpecialArgs = commonArgs system // primaryAttrs.extraSpecialArgs or {};
          modules = [self.nixOnDroidPresets.base] ++ primaryAttrs.modules or [];
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
              self.nixosPresets.base
              {nixpkgs = {inherit pkgs;};}
            ]
            ++ lib.optionals hjem [
              inputs.hjem.nixosModules.default
              {
                hjem = {
                  extraModules = [self.hjemPresets.base];
                  specialArgs = commonArgs system;
                };
              }
            ]
            ++ primaryAttrs.modules or [];
          specialArgs = commonArgs system // primaryAttrs.specialArgs or {};
        });
  };
}
