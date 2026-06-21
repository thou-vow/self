{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.yazi = {
    autoDiscoverModules = "yazi";
    autoDiscoverPresets = "yazi";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };
}
