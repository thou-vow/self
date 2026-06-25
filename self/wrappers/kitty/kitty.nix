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
      "kittens".path = ./kittens;
      "manual-kitty.conf".path = ./manual-kitty.conf;
    };

    kittyConf.manual = wlib.dag.entryAfter ["settings"] ''
      include ./manual-kitty.conf
    '';

    settings.clear_all_shortcuts = true;
  };

  flake.wrapperIntegrationPresets.kitty = {config, ...}: {
    kitty = lib.mkIf (config.preferences or {} != {}) {
      extraConfigFiles."theme.conf".content = let
        theme = import ./_kitty-theme.nix config.preferences.style;
      in
        self.lib.toKittyAssignments theme;

      kittyConf.theme = wlib.dag.entryAnywhere ''
        include ./theme.conf
      '';
    };
  };
}
