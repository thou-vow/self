{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.nh = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.nh;
    nixosModule = self.nixosModules.nh;
  };

  flake.wrapperModules.nh = _: {
    envDefault.NH_SHOW_ACTIVATION_LOGS = "1";
  };
}
