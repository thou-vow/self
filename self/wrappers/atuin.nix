{
  withSystem,
  ...
}: {
  flake.wrappers.atuin = {
    autoDiscoverModules = "atuin";
    autoDiscoverPresets = "atuin";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.atuin = _: {
    settings = {
      inline_height = 9;
      prefers_reduced_motion = true;
      show_help = false;
      show_tabs = false;
      workspaces = true;
    };
  };

  flake.wrapperIntegrationPresets.atuin = _: {
    atuin.initFlags = ["--disable-up-arrow"];
  };
}
