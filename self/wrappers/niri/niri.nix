{
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.niri = {
    autoDiscoverModules = "niri";
    autoDiscoverPresets = "niri";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.niri = {
    inputs',
    pkgs,
    ...
  }: {
    configKdl.manual = wlib.dag.entryAfter ["settings"] ''
      include "manual-config.kdl"
    '';
    extraConfigFiles = {
      "manual-config.kdl".path = ./manual-config.kdl;
    };

    runtimePkgs =
      (with pkgs; [
        brightnessctl
        dash
        kdePackages.dolphin
        fuzzel
        wireplumber
        wl-clipboard
      ])
      ++ (with inputs'.nix-packages.packages; [
        brave
      ]);
  };
}
