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
      _module.args = let
        system = pkgs.stdenv.hostPlatform.system;
      in {
        inherit (withSystem system (args: args)) inputs' self';
        inherit system;
      };
    };

    wrapperIntegrationModules.core = {pkgs, ...}: {
      _module.args = let
        system = pkgs.stdenv.hostPlatform.system;
      in {
        inherit (withSystem system (args: args)) inputs' self';
        inherit system;
      };
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
}
