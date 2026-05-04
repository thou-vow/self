{lib, ...}: {
  flake.nixosModules.u = {
    inputs',
    pkgs,
    ...
  }: let
    internalHddId = "0x50014ee6b2ede306";
  in {
    specialisation.attuned.configuration = {
      boot = {
        # WIP
        initrd.availableKernelModules = [
          "ehci_pci"
          "xhci_pci"
          "ahci"
          "usb_storage"
          "uas"
          "sd_mod"
          "usbhid"
        ];

        # WIP
        kernelPackages =
          inputs'.nyx-loner.legacyPackages.linuxPackages_cachyos-lto;

        kernelParams = [
          # I think these are needed for Wi-Fi to work properly
          "ath9k_core.nohwcrypt=1"
          "pcie_aspm=off"

          "mitigations=off" # WIP

          "zswap.enabled=1"
          "zswap.max_pool_percent=80"
          "zswap.shrinker_enabled=0"
        ];

        loader.grub.configurationName = "Attuned";
      };

      environment = {
        etc."specialisation".text = "attuned";
      };

      hardware = {
        cpu.intel.updateMicrocode = true;
        graphics.package = inputs'.nix-packages.packages.mesa-attuned;
        enableRedistributableFirmware = true;
      };

      # services = {
      #   udev.extraRules = lib.concatStringsSep ", " [
      #     ''ACTION=="add|change"''
      #     ''SUBSYSTEM=="block"''
      #     ''ENV{DEVTYPE}=="disk"''
      #     ''ENV{ID_WWN}=="${internalHddId}"''
      #     ''ATTR{queue/rotational}==1''
      #     ''RUN+="${lib.getExe pkgs.hdparm} -B 255 /dev/%k"''
      #   ];
      # };

      swapDevices = [
        {
          device = "/dev/disk/by-id/wwn-${internalHddId}-part4";
          priority = 1;
        }
      ];

      systemd.services = {
        disable-i915-mitigations = {
          description = "Set i915 (Intel Graphics) mitigations off at runtime";
          before = ["graphical.target"];
          wantedBy = ["multi-user.target"];
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
  };
}
