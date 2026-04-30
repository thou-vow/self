{
  flake.nixosModules.flatpak = {pkgs, ...}: {
    services.flatpak.enable = true;

    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
  };
}
