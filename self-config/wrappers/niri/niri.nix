{
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.niri = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.niri;
    integrationModule = self.wrapperIntegrationModules.niri;
  };

  flake.wrapperModules.niri = {
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
