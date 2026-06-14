{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.git = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.git;
  };
}
