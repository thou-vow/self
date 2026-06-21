{
  inputs,
  lib,
  self,
  ...
}: let
  attunedInternalDrive = "0x50014ee6b2ede306";
  mainId = "0x500003988168a3bd";
in {
  flake.nixosPresets."!u" = {
    config,
    pkgs,
    specialisation,
    ...
  }: {
    imports = [
      self.nixosModules.mapState
      inputs.preservation.nixosModules.default
    ];

    modules.mapState.flakePath = "/self";

    boot = {
      initrd.systemd = {
        extraBin = {
          btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
          date = "${pkgs.coreutils}/bin/date";
          mkdir = "${pkgs.coreutils}/bin/mkdir";
          mv = "${pkgs.coreutils}/bin/mv";
          stat = "${pkgs.coreutils}/bin/stat";
        };

        services.btrfs-rolling = {
          description = "Archiving existing Btrfs @ subvolume and creating a fresh one";

          after = ["initrd-root-device.target" "local-fs-pre.target"];
          before = ["initrd.target"];
          requiredBy = ["initrd.target"];
          requires = ["initrd-root-device.target"];

          script = ''
            mkdir "/btrfs_tmp"
            mount ${config.fileSystems."/".device} "/btrfs_tmp"

            if [[ -e "/btrfs_tmp/@" ]]; then
              mkdir -p /btrfs_tmp/.archive
              timestamp=$(date '+%Y-%m-%d_%H-%M-%S' --date="@$(stat -c %Y "/btrfs_tmp/@")")
              mv "/btrfs_tmp/@" "/btrfs_tmp/.archive/@$timestamp"
            fi

            btrfs subvolume create "/btrfs_tmp/@"

            umount "/btrfs_tmp"
          '';

          serviceConfig.Type = "oneshot";
          unitConfig.DefaultDependencies = false;
        };

        tmpfiles.settings.preservation."/sysroot/persist/etc/machine-id".f.argument = "uninitialized";
      };
      loader = {
        efi.efiSysMountPoint = "/boot";
        limine = {
          enable = true;
          biosDevice = "/dev/disk/by-id/wwn-${mainId}";
          biosSupport = true;
          efiInstallAsRemovable = true;
          efiSupport = true;
          maxGenerations = 7;
        };
      };
    };

    fileSystems = {
      ${config.boot.loader.efi.efiSysMountPoint} = {
        device = "/dev/disk/by-id/wwn-${mainId}-part2";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
      "/" =
        if specialisation == "attuned"
        then {
          device = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part5";
          fsType = "btrfs";
          options = ["subvol=@" "commit=60" "compress=zstd:11" "noatime"];
        }
        else {
          device = "/dev/disk/by-id/wwn-${mainId}-part4";
          fsType = "btrfs";
          options = ["subvol=@" "commit=60" "compress=zstd:11" "noatime"];
        };
      "/mnt/attuned-internal" = lib.mkIf (specialisation == "attuned") {
        device = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part5";
        fsType = "btrfs";
        options = ["commit=60" "compress=zstd:11" "noatime"];
      };
      "/mnt/main" = {
        device = "/dev/disk/by-id/wwn-${mainId}-part4";
        fsType = "btrfs";
        options = ["commit=60" "compress=zstd:11" "noatime"];
      };
      "/nix" = {
        device = "/dev/disk/by-id/wwn-${mainId}-part4";
        fsType = "btrfs";
        options = ["subvol=@nix" "commit=60" "compress=zstd:11" "noatime"];
      };
      "/persist" = {
        device = "/dev/disk/by-id/wwn-${mainId}-part4";
        fsType = "btrfs";
        neededForBoot = true;
        options = ["subvol=@persist" "commit=60" "compress=zstd:11" "noatime"];
      };
    };

    preservation = {
      enable = true;
      preserveAt."/persist" = {
        directories = [
          {
            directory = config.modules.mapState.flakePath;
            user = "thou";
          }
          "/etc/NetworkManager/system-connections"
          "/root/.cache/nix"
          "/root/.local/share/nix"
          "/var/lib/flatpak"
          "/var/lib/hjem"
          "/var/lib/machines"
          "/var/lib/nixos"
          "/var/lib/nixos-containers"
          "/var/lib/portables"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/rfkill"
          "/var/lib/systemd/timers"
          "/var/lib/waydroid"
          "/var/log"
        ];
        files = [
          {
            file = "/etc/machine-id";
            inInitrd = true;
          }
          {
            file = "/var/lib/systemd/random-seed";
            how = "symlink";
            inInitrd = true;
            configureParent = true;
          }
        ];
        users.thou = {
          directories = [
            ".cache/nix"
            ".cargo"
            ".config/Cemu"
            ".config/BraveSoftware"
            ".config/PCSX2"
            ".jail"
            ".local/bin"
            ".local/share/atuin"
            ".local/share/containers"
            ".local/share/direnv"
            ".local/share/flatpak"
            ".local/share/helix"
            ".local/share/nix"
            ".local/share/qBittorrent"
            ".local/share/Trash"
            ".local/share/waydroid"
            ".local/share/zoxide"
            ".ssh"
            ".var"
            "Desktop"
            "Documents"
            "Downloads"
            "Games"
            "Music"
            "Pictures"
            "Projects"
            "Public"
            "Templates"
            "Videos"
          ];
          files = [
            ".bash_history"
            ".config/nushell/history.txt"
            {
              file = ".env";
              mode = "0600";
            }
          ];
        };
      };
    };

    services = {
      beesd.filesystems = {
        "attuned-internal" = lib.mkIf (specialisation == "attuned") {
          spec = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part5";
          hashTableSizeMB = 128;
          verbosity = "crit";
          extraOptions = ["--loadavg-target" "2.0"];
        };
        "main" = {
          spec = "/dev/disk/by-id/wwn-${mainId}-part4";
          hashTableSizeMB = 128;
          verbosity = "crit";
          extraOptions = ["--loadavg-target" "2.0"];
        };
      };
      zram-generator = {
        enable = true;
        settings.zram0 = {
          compression-algorithm = "lz4 zstd(level=3) (type=idle)";
          writeback-device =
            lib.mkIf (specialisation == "attuned")
            "/dev/disk/by-id/wwn-${attunedInternalDrive}-part4";
          zram-size = "4 / 5 * ram";
        };
      };
    };

    swapDevices = [
      {device = "/dev/disk/by-id/wwn-${mainId}-part3";}
    ];

    systemd.services = {
      "beesd@attuned-internal" = lib.mkIf (specialisation == "attuned") {wantedBy = lib.mkForce [];};
      "beesd@main".wantedBy = lib.mkForce [];
      systemd-machine-id-commit.unitConfig.ConditionFirstBoot = true;
    };
  };
}
