{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules."hosts.u" = {
    config,
    pkgs,
    ...
  }:
    lib.mkIf (config.specialisation != {}) {
      boot = {
        initrd.availableKernelModules = [
          "ehci_pci"
          "xhci_pci"
          "ahci"
          "usb_storage"
          "uas"
          "sd_mod"
          "usbhid"
        ];

        kernelPackages =
          inputs.nix-cachyos-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages-cachyos-lts-lto;
      };

      hardware = {
        cpu = {
          amd.updateMicrocode = true;
          intel.updateMicrocode = true;
        };
        enableAllFirmware = true;
        enableAllHardware = true;
      };

      # Sometimes the default don't work
      networking.nameservers = [
        "8.8.4.4"
        "8.8.8.8"
      ];

      # nix.package = pkgs.lixPackageSets.latest.lix;

      services.cloudflare-warp.enable = true;
    };
}
