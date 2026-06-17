{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.kitty = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.kitty;
    integrationModule = self.wrapperIntegrationModules.kitty;
  };

  flake.wrapperModules.kitty = {wlib, ...}: {
    extraConfigFiles = {
      "kittens".subject.source = ./kittens;
      "manual-kitty.conf".subject.source = ./manual-kitty.conf;
      "theme.conf".subject.source = ./theme.conf;
    };

    kittyConf.manual = wlib.dag.entryAfter ["settings"] ''
      include ./manual-kitty.conf
    '';

    settings.clear_all_shortcuts = true;
  };
}
