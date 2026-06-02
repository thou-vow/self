{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.niri.module = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    configKdl.manual = wlib.dag.entryAfter ["settings"] ''
      include "manual-config.kdl"
    '';
    extraConfigFiles = {
      "manual-config.kdl".subject.source = ./manual-config.kdl;
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
        brave-latest
      ]);
  };
}
