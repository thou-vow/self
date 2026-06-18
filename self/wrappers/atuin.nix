{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.atuin = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.atuin;
    integrationModule = self.wrapperIntegrationModules.atuin;
    hjemModule = self.hjemModules.atuin;
  };

  flake.wrapperModules.atuin = _: {
    settings = {
      inline_height = 9;
      prefers_reduced_motion = true;
      show_help = false;
      show_tabs = false;
      workspaces = true;
    };
  };

  flake.wrapperIntegrationModules.atuin = _: {
    atuin.initFlags = ["--disable-up-arrow"];
  };
}
