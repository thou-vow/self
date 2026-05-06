{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.u = {
    config,
    inputs',
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
          inputs'.nyx-loner.legacyPackages.linuxPackages_cachyos-lto;

        kernelParams = [
          "mitigations=off"
        ];
      };

      hardware = {
        cpu = {
          amd.updateMicrocode = true;
          intel.updateMicrocode = true;
        };
        enableAllFirmware = true;
        enableAllHardware = true;
      };

      networking.nameservers = [
        "8.8.4.4"
        "8.8.8.8"
      ];

      zramSwap = {
        enable = true;
        memoryPercent = 80;
        priority = 1;
      };
    };
}
