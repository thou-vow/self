{...}: {
  flake.nixosModules.u = {
    driveId,
    pkgs,
    ...
  }: {
    boot = {
      kernel.sysctl = {
        "vm.page-cluster" = 0;
        "vm.swappiness" = 50;
      };

      kernelModules = ["zram"];
    };

    systemd = {
      services = {
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
            # Only run maintenance when ZRAM's memory usage exceeds 50% of its
            # memory limit. Pages that recompression could not shrink enough go
            # to the backing device. Pages that zstd shrinks, and small pages,
            # stay in RAM.
            #
            # Each cycle:
            # 1. Read current memory usage and limit from mm_stat. If usage is
            #    at or below 50% of the limit, skip maintenance.
            # 2. Mark pages not accessed for more than 300 seconds as idle.
            # 3. Write back pages flagged INCOMPRESSIBLE by an earlier cycle. The
            #    idle mark from step 2 is refreshed just before, so this works
            #    whether or not the mode checks idleness.
            # 4. Try zstd (priority 1, the only and therefore highest secondary
            #    algorithm) on idle pages whose stored size is >= 2500 bytes:
            #    - It saves memory and ends below the threshold: the page keeps zstd
            #      and later scans skip it (already at priority 1).
            #    - Otherwise: the page keeps its current form (HUGE or lz4) and is
            #      flagged INCOMPRESSIBLE, which stops further attempts. It is
            #      written back by the next cycle that passes the usage check.
            #
            # Notes:
            # - The usage check compares mem_used_total against 50% of mem_limit.
            #   Below it, nothing is recompressed or written back.
            # - Stored size < 2500 bytes: skipped by the threshold, stays in RAM.
            # - Pages younger than 300 seconds are untouched, including raw HUGE ones.
            # - HUGE: the page is stored raw at full page size because the primary
            #   algorithm (lz4) could not shrink it at swap-out. Recompression never
            #   creates HUGE pages. The flag clears when the slot is freed or
            #   replaced by a recompressed copy.
            # - INCOMPRESSIBLE: the highest-priority recompression algorithm (zstd)
            #   did not save enough, so no further attempts are made. In this setup
            #   the page is either raw (HUGE) or lz4-compressed.
            # - Written-back pages are excluded from recompression.
            # - Swapping a page back in normally frees its slot, so a page that is
            #   evicted again starts over as a new page.
            # https://www.kernel.org/doc/html/latest/admin-guide/blockdev/zram.html
            ''
              read -r _ _ mem_used_total mem_limit _ < /sys/block/zram0/mm_stat

              if [ "$((mem_used_total * 2))" -le "$mem_limit" ]; then
                exit 0
              fi

              echo 300 > /sys/block/zram0/idle
              echo incompressible > /sys/block/zram0/writeback
              echo "type=idle threshold=2500 priority=1" > /sys/block/zram0/recompress
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
            echo "$((total_mem_kb * 2))K" > /sys/block/zram0/disksize
            echo "$((total_mem_kb / 2))K" > /sys/block/zram0/mem_limit

            mkswap -L zram0 /dev/zram0
            swapon /dev/zram0
          '';
        };
      };
      timers.zram-maintenance = {
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "3min";
          OnUnitActiveSec = "3min";
        };
      };
    };
  };
}
