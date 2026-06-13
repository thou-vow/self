{
  inputs,
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.starship = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.starship;
  };
}
