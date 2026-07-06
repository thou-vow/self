{
  inputs,
  lib,
  self,
  withSystem,
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
    homeManagerConfiguration = {pkgs}: primaryAttrs: let
      system = pkgs.stdenv.hostPlatform.system;
    in
      inputs.home-manager.lib.homeManagerConfiguration (primaryAttrs
        // {
          inherit pkgs;
          extraSpecialArgs = commonArgs system // primaryAttrs.extraSpecialArgs or {};
          modules = [self.homeModules.base] ++ primaryAttrs.modules or [];
        });

    nixosSystem = {
      pkgs,
      useHomeManager ? false,
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
            ++ lib.optionals useHomeManager [
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager = {
                  sharedModules = [self.homeModules.base];
                  extraSpecialArgs = commonArgs system;
                };
              }
            ]
            ++ primaryAttrs.modules or [];
          specialArgs = commonArgs system // primaryAttrs.specialArgs or {};
        });
  };
}
