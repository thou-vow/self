{
  lib,
  self,
  ...
}: {
  flake.nixosModules.waydroid = {config, ...}: let
    cfg = config.self.mods.waydroid;
  in {
    options.self.mods.waydroid = {
      enable = self.lib.mkAutoEnableOption "Waydroid";
    };

    config = lib.mkIf cfg.enable {
      # https://github.com/pioner14/Waydroid_on_NixOS
      boot.kernel.sysctl = {
        "net.ipv4.conf.all.forwarding" = 1;
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
      };

      networking.firewall.trustedInterfaces = ["waydroid0"];

      systemd.services."waydroid-container".wantedBy = lib.mkForce [];

      virtualisation.waydroid = {
        inherit (cfg) enable;
      };
    };
  };
}
