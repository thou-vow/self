{lib, ...}: {
  flake.nixosModules."extra.flatpak" = {
    config,
    pkgs,
    ...
  }: {
    options.custom.extra.flatpak = {
      enable = lib.mkEnableOption "Flatpak";
    };

    config = lib.mkIf config.custom.extra.flatpak.enable {
      services.flatpak.enable = true;

      xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
      };
    };
  };
}
