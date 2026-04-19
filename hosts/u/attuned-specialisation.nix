{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules."hosts.u" = {pkgs, ...}: let
    internalHddId = "0x50014ee6b2ede306";
  in {
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
      # initrd = {
      #   availableKernelModules = lib.mkForce [];
      #   kernelModules = lib.mkForce [];
      # };
      # kernelModules = lib.mkForce [];

      # kernelPackages =
      #   pkgs.linuxPackagesFor
      #   inputs.nix-packages.legacyPackages.${pkgs.stdenv.hostPlatform.system}.attunedPackages.custom-linux;
      kernelPackages =
        inputs.nix-cachyos-kernel.legacyPackages.${pkgs.stdenv.hostPlatform.system}.linuxPackages-cachyos-lts-lto-x86_64-v3;

      kernelParams = [
        # I think these are needed for Wi-Fi to work properly
        "ath9k_core.nohwcrypt=1"
        "pcie_aspm=off"
      ];

      loader.grub.configurationName = "Attuned";
    };

    environment = {
      etc."specialisation".text = "attuned";

      persistence."/persist-internal" = {
        enable = true;
        users.thou = {
          directories = [".local/share/PrismLauncher"];
        };
      };

      variables.PERSIST_INTERNAL = "/persist-internal";
    };

    fileSystems = {
      "/persist-internal" = {
        device = "/dev/disk/by-id/wwn-${internalHddId}-part5";
        fsType = "btrfs";
        neededForBoot = true;
        options = ["commit=60" "compress-force=zstd:10" "noatime"];
      };
    };

    hardware = {
      cpu.intel.updateMicrocode = true;
      graphics.package = inputs.nix-packages.legacyPackages.${pkgs.stdenv.hostPlatform.system}.attunedPackages.mesa;
      enableRedistributableFirmware = true;
    };

    # nix.package = inputs.nix-packages.legacyPackages.${pkgs.stdenv.hostPlatform.system}.attunedPackages.lix;

    services = {
      udev.extraRules = lib.concatStringsSep ", " [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''ENV{DEVTYPE}=="disk"''
        ''ENV{ID_WWN}=="${internalHddId}"''
        ''ATTR{queue/rotational}==1''
        ''RUN+="${lib.getExe pkgs.hdparm} -B 255 /dev/%k"''
      ];
    };

    swapDevices = [
      {
        device = "/dev/disk/by-id/wwn-${internalHddId}-part4";
        priority = 1;
      }
    ];

    systemd.services = {
      disable-i915-mitigations = {
        description = "Set i915 (Intel Graphics) mitigations off at runtime";
        wantedBy = ["multi-user.target"];
        before = ["graphical.target"];
        serviceConfig = {
          ExecStart = let
            script = pkgs.writeShellScript "disable-i915-mitigations" ''
              if [ -w /sys/module/i915/parameters/mitigations ]; then
                echo off > /sys/module/i915/parameters/mitigations
              fi
            '';
          in "${script}";
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
      };
    };
  };
}
