{
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.mangowc = {
    autoDiscoverModules = "mangowc";
    autoDiscoverPresets = "mangowc";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.mangowc = {
    inputs',
    pkgs,
    ...
  }: {
  };
}
