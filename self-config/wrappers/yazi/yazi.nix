{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.yazi = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.yazi;
  };
}
