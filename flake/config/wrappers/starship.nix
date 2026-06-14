{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.starship = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.starship;
  };
}
