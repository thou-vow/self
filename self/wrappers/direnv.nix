{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.direnv = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.direnv;
  };

  flake.wrapperModules.direnv = _: {
    nix-direnv.enable = true;
    silent = true;
  };
}
