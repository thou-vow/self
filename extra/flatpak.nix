{
  lib,
  ...
}: {
  flake.nixosModules."extra.flatpak" = {
    config,
    pkgs,
    ...
  }: {
    options.custom.extra.flatpak.enable = lib.mkEnableOption "Flatpak";

    config = let
      cfg = config.custom.extra.flatpak;
    in
      lib.mkIf cfg.enable {
        services.flatpak.enable = true;

        xdg.portal = {
          enable = true;
          config.common.default = "*";
          extraPortals = [pkgs.xdg-desktop-portal-gtk];
        };
      };
  };
}
