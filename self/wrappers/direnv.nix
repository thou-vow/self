{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.direnv = {
    autoDiscoverModules = "direnv";
    autoDiscoverPresets = "direnv";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.direnv = _: {
    nix-direnv.enable = true;
    silent = true;
  };
}
