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
        "vm.min_free_kbytes" = 122880;
        "vm.page-cluster" = 0;
        "vm.swappiness" = 20;
        "vm.vfs_cache_pressure" = 25;
        "vm.watermark_scale_factor" = 50;
      };

      kernelModules = [
        "ntsync"
        "zram"
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
      extraPackages = with pkgs; [intel-media-driver];
      extraPackages32 = with pkgs.pkgsi686Linux; [intel-media-driver];
      package = inputs'.nix-packages.packages.mesa-attuned;
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
      coredump.settings.Coredump = {
        ProcessSizeMax = 0;
        Storage = "none";
      };
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

        zram-maintenance = {
          requires = ["zram-setup.service"];
          after = ["zram-setup.service"];
          restartIfChanged = false;
          stopIfChanged = false;
          serviceConfig = {
            Type = "oneshot";
            Nice = 19;
            IOSchedulingClass = "idle";
          };
          script =
            # Only pages that recompression could not shrink enough go to the
            # backing device. Pages that zstd shrinks, and small pages, stay in RAM.
            #
            # Each cycle:
            # 1. Mark pages not accessed for more than 300 seconds as idle.
            # 2. Try zstd (priority 1, the only and therefore highest secondary
            #    algorithm) on idle pages whose stored size is >= 3000 bytes:
            #    - It saves memory and ends below the threshold: the page keeps zstd
            #      and later scans skip it (already at priority 1).
            #    - Otherwise: the page keeps its current form (HUGE or lz4) and is
            #      flagged INCOMPRESSIBLE, which stops further attempts.
            # 3. Write back INCOMPRESSIBLE pages. Expected to select by flag, not by
            #    idle mark, so pages flagged in step 2 leave RAM in the same cycle.
            #
            # Notes:
            # - Stored size < 3000 bytes: skipped by the threshold, stays in RAM.
            # - Pages younger than 300 seconds are untouched, including raw HUGE ones.
            # - INCOMPRESSIBLE means "recompression did not save enough", not HUGE and
            #   not provably incompressible.
            # - Written-back pages are excluded from recompression.
            # - Touching a page frees its slot, so it restarts the cycle as a new page.
            ''
              echo 300 > /sys/block/zram0/idle
              echo "type=idle threshold=3000 priority=1" > /sys/block/zram0/recompress
              echo incompressible > /sys/block/zram0/writeback
            '';
        };
        zram-setup = {
          description = "ZRAM swap with recompression and writeback";
          wantedBy = ["multi-user.target"];
          restartIfChanged = false;
          stopIfChanged = false;
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
          };
          path = [pkgs.util-linux];
          script = ''
            echo lz4 > /sys/block/zram0/comp_algorithm

            echo "algo=zstd priority=1" > /sys/block/zram0/recomp_algorithm
            echo "priority=1 level=3" > /sys/block/zram0/algorithm_params

            echo /dev/disk/by-id/wwn-${driveId}-part9 > /sys/block/zram0/backing_dev
            echo yes > /sys/block/zram0/compressed_writeback

            read -r _ total_mem_kb _ < /proc/meminfo
            echo "$((total_mem_kb * 5 / 2))K" > /sys/block/zram0/disksize
            echo "$((total_mem_kb * 3 / 5))K" > /sys/block/zram0/mem_limit

            mkswap -L zram0 /dev/zram0
            swapon /dev/zram0
          '';
        };
      };
      settings.Manager = {
        DefaultLimitNOFILE = "2048:2097152";
        DefaultTimeoutStartSec = "15s";
        DefaultTimeoutStopSec = "10s";
      };
      timers.zram-maintenance = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "10min";
          OnUnitActiveSec = "10min";
        };
      };
      user.settings.Manager = {
        DefaultLimitNOFILE = "2048:2097152";
        DefaultTimeoutStartSec = "15s";
        DefaultTimeoutStopSec = "10s";
      };
    };
  };
}
