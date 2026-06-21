{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.kitty = {
    autoDiscoverModules = "kitty";
    autoDiscoverPresets = "kitty";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.kitty = {wlib, ...}: {
    extraConfigFiles = {
      "kittens".subject.source = ./kittens;
      "manual-kitty.conf".subject.source = ./manual-kitty.conf;
    };

    kittyConf.manual = wlib.dag.entryAfter ["settings"] ''
      include ./manual-kitty.conf
    '';

    settings.clear_all_shortcuts = true;
  };

  flake.wrapperIntegrationPresets.kitty = {config, ...}: {
    kitty = lib.mkIf (config.preferences or {} != {}) {
      extraConfigFiles."theme.conf".subject.text = let
        theme = import ./_kitty-theme.nix config.preferences.style;
      in
        self.lib.toKittyAssignments theme;

      kittyConf.theme = wlib.dag.entryAnywhere ''
        include ./theme.conf
      '';
    };
  };
}
