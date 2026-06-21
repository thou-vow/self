{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.nh = {
    autoDiscoverModules = "nh";
    autoDiscoverPresets = "nh";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.nh = _: {
    envDefault.NH_SHOW_ACTIVATION_LOGS = "1";
  };
}
