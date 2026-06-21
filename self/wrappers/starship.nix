{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.starship = {
    autoDiscoverModules = "starship";
    autoDiscoverPresets = "starship";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };
}
