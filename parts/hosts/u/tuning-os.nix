{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.u = {
    config,
    driveId,
    inputs',
    pkgs,
    system,
    ...
  }: {
    boot = {
      blacklistedKernelModules = [
        "iTCO_wdt"
      ];

      extraModprobeConfig = ''
        options snd_hda_intel power_save=0
      '';

      kernel.sysctl = {
        "kernel.split_lock_mitigate" = 0;
        "vm.dirty_background_bytes" = 33554432;
        "vm.dirty_bytes" = 134217728;
        "vm.dirty_expire_centisecs" = 6000;
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.min_free_kbytes" = 122880;
        "vm.page-cluster" = 0;
        "vm.swappiness" = 20;
        "vm.vfs_cache_pressure" = 25;
        "vm.watermark_scale_factor" = 50;

        "fs.file-max" = 2097152;
        "kernel.printk" = "3 3 3 3";
        "net.core.netdev_max_backlog" = 4096;
        "vm.max_map_count" = 2147483642;
      };

      kernelModules = [
        "ntsync"
      ];

      kernelPackages =
        inputs.linux-cachyos-lto-v3.inputs.chaotic-nyx.legacyPackages.${system}.linuxPackages_cachyos-lto.extend
        (_: _: {
          kernel = inputs'.linux-cachyos-lto-v3.packages.default;
        });

      kernelParams = [
        "8250.nr_uarts=0"
        "ath9k_core.nohwcrypt=1"
        "mitigations=off"
      ];
    };

    environment.sessionVariables = {
      GSK_RENDERER = "gl";
      MESA_SHADER_CACHE_MAX_SIZE = "10G";
    };

    fileSystems = {
      ${config.boot.loader.efi.efiSysMountPoint}.noCheck = true;
      "/".options = ["logbsize=256k" "noatime"];
      "/cache".options = ["logbsize=256k" "noatime"];
      "/nix".options = ["logbsize=256k" "noatime"];
      "/persist".options = ["logbsize=256k" "noatime"];

      "/mnt/u".options = ["logbsize=256k" "noatime"];
    };

    networking.wireless.iwd.settings.DriverQuirks.PowerSaveDisable = "ath9k";

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";

      package = inputs'.nix-packages.packages.lix-attuned;

      settings = {
        max-substitution-jobs = 2;
        tarball-ttl = 604800;
      };
    };

    powerManagement.resumeCommands = ''
      udevadm trigger --subsystem-match=block --property-match=DEVTYPE=disk
    '';

    services = {
      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
          ATTR{link_power_management_supported}=="1", \
          ATTR{link_power_management_policy}=="*", \
          ATTR{link_power_management_policy}="max_performance"

        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
          ENV{ID_BUS}=="ata", RUN+="${lib.getExe pkgs.hdparm} -B 254 -S 0 /dev/%k"
      '';
      zram-generator = {
        enable = true;
        settings.zram0 = {
          compression-algorithm = "zstd zstd(level=3) (type=idle)";
          writeback-device = "/dev/disk/by-id/wwn-${driveId}-part9";
          zram-size = "4 / 5 * ram";
        };
      };
    };

    systemd = {
      oomd.enable = false;
      services = {
        disable-i915-mitigations = {
          description = "Set i915 (Intel Graphics) mitigations off at runtime";
          before = ["graphical.target"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            ExecStart = "${pkgs.writeShellScript "disable-i915-mitigations" ''
              if [ -w /sys/module/i915/parameters/mitigations ]; then
                echo off > /sys/module/i915/parameters/mitigations
              fi
            ''}";
            Type = "oneshot";
            RemainAfterExit = "yes";
          };
        };
        rtkit-daemon.serviceConfig.LogLevelMax = "info";
      };
      settings.Manager = {
        DefaultLimitNOFILE = "2048:2097152";
        DefaultTimeoutStartSec = "15s";
        DefaultTimeoutStopSec = "10s";
      };
      user.settings.Manager = {
        DefaultLimitNOFILE = "2048:2097152";
        DefaultTimeoutStartSec = "15s";
        DefaultTimeoutStopSec = "10s";
      };
    };
  };
}
