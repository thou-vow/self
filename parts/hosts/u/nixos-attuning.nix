{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.u = {
    config,
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
        "fs.file-max" = 2097152;
        "kernel.printk" = "3 3 3 3";
        "kernel.split_lock_mitigate" = 0;
        "net.core.netdev_max_backlog" = 4096;
        "net.ipv4.tcp_congestion_control" = "bbr";
        "vm.dirty_background_bytes" = 33554432;
        "vm.dirty_bytes" = 134217728;
        "vm.dirty_expire_centisecs" = 6000;
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.max_map_count" = 2147483642;
        "vm.vfs_cache_pressure" = 50;
        "vm.watermark_scale_factor" = 50;
      };

      kernelModules = ["ntsync"];

      kernelPackages =
        inputs.linux-cachyos-lto-v3.inputs.chaotic-nyx.legacyPackages.${system}.linuxPackages_cachyos-lto.extend
        (_: _: {
          kernel = inputs'.linux-cachyos-lto-v3.packages.default;
        });

      kernelParams = [
        "8250.nr_uarts=0"
        "ath9k_core.nohwcrypt=1"
        "mitigations=off"
        "nowatchdog"
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

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [intel-vaapi-driver];
      extraPackages32 = with pkgs.pkgsi686Linux; [intel-vaapi-driver];
      package = inputs'.nix-packages.packages.mesa-attuned;
    };

    networking.wireless.iwd.settings.DriverQuirks.PowerSaveDisable = "ath9k";

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";

      settings = {
        max-substitution-jobs = 2;
        tarball-ttl = 604800;
      };
    };

    powerManagement.resumeCommands = ''
      udevadm trigger --subsystem-match=block --property-match=DEVTYPE=disk
    '';

    services = {
      journald.settings.Journal.SystemMaxUse = "50M";
      udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="scsi_host", KERNEL=="host*", \
          ATTR{link_power_management_supported}=="1", \
          ATTR{link_power_management_policy}=="*", \
          ATTR{link_power_management_policy}="max_performance"

        ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", \
          ENV{ID_BUS}=="ata", RUN+="${lib.getExe pkgs.hdparm} -B 254 -S 0 /dev/%k"
      '';
    };

    systemd = {
      network.wait-online.enable = false;
      oomd.enable = false;
      services = {
        disable-i915-mitigations = {
          description = "Set i915 (Intel Graphics) mitigations off at runtime";
          before = ["graphical.target"];
          wantedBy = ["multi-user.target"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = "yes";
          };
          script = ''
            if [ -w /sys/module/i915/parameters/mitigations ]; then
              echo off > /sys/module/i915/parameters/mitigations
            fi
          '';
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
