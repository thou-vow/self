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
    nixosSystem = {
      pkgs,
      useHomeManager ? false,
    }: primaryAttrs: let
      system = pkgs.stdenv.hostPlatform.system;
    in
      inputs.linux-cachyos-lto-v3.inputs.nixpkgs.lib.nixosSystem (primaryAttrs
        // {
          modules =
            [
              self.nixosModules.base
              {nixpkgs = {inherit pkgs;};}
            ]
            ++ lib.optionals useHomeManager [
              "${inputs.home-manager}/nixos"
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
