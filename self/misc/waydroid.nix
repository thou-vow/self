{lib, ...}: {
  flake.nixosModules.waydroid = _: {
    # https://github.com/pioner14/Waydroid_on_NixOS
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = 1;
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    networking.firewall.trustedInterfaces = ["waydroid0"];

    systemd.services."waydroid-container".wantedBy = lib.mkForce [];

    virtualisation.waydroid.enable = true;
  };
}
