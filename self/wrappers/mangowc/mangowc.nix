{
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.mangowc = {
    autoDiscoverModules = "mangowc";
    autoDiscoverPresets = "mangowc";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.mangowc = {
    inputs',
    pkgs,
    ...
  }: {
    configConf.manual = wlib.dag.entryAfter ["settings"] ''
      source=./manual-config.conf
    '';
    extraConfigFiles = {
      "manual-config.conf".path = ./manual-config.conf;
    };

    runtimePkgs =
      (with pkgs; [
        brightnessctl
        dash
        flameshot
        fuzzel
        kdePackages.dolphin
        playerctl
        waybar
        wireplumber
        wl-clipboard
      ])
      ++ (with inputs'.nix-packages.packages; [
        brave
      ]);
  };
}
