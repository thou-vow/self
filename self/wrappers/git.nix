{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.git = {
    autoDiscoverModules = "git";
    autoDiscoverPresets = "git";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };
}
