{
  inputs,
  lib,
  self,
  ...
}: let
  mainId = "0x500003988168a3bd";
in {
  flake.nixosModules.u = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.state
      inputs.impermanence.nixosModules.impermanence
    ];

    ext.state.flakePath = "/self";

    boot = {
      initrd.systemd = {
        extraBin = {
          btrfs = "${pkgs.btrfs-progs}/bin/btrfs";
          date = "${pkgs.coreutils}/bin/date";
          mkdir = "${pkgs.coreutils}/bin/mkdir";
          mv = "${pkgs.coreutils}/bin/mv";
          stat = "${pkgs.coreutils}/bin/stat";
        };

        services.impermanence-btrfs-rolling = {
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

    environment.persistence = {
      "/persist" = {
        enable = true;
        directories = [
          config.ext.state.flakePath
          "/etc/NetworkManager/system-connections"
          "/root/.cache/nix"
          "/root/.local/share/nix"
          "/var/lib/flatpak"
          "/var/lib/machines"
          "/var/lib/nixos"
          "/var/lib/nixos-containers"
          "/var/lib/portables"
          "/var/lib/waydroid"
          "/var/log"
          "/var/tmp"
        ];
        users.thou = {
          directories = [
            ".bwrap"
            ".cache/nix"
            ".cargo"
            ".config/Cemu"
            ".config/BraveSoftware"
            ".config/discord"
            ".config/faugus-launcher"
            ".config/PCSX2"
            ".local/bin"
            ".local/share/atuin"
            ".local/share/Cemu"
            ".local/share/containers"
            ".local/share/direnv"
            ".local/share/dolphin-emu"
            ".local/share/faugus-launcher"
            ".local/share/flatpak"
            ".local/share/helix"
            ".local/share/nix"
            ".local/share/qBittorrent"
            ".local/share/Steam"
            ".local/share/steel"
            ".local/share/umu"
            ".local/share/waydroid"
            ".local/share/yawl"
            ".local/share/zoxide"
            ".m2"
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
            ".config/nushell/history.txt"
            ".env"
          ];
        };
      };
    };

    fileSystems = {
      ${config.boot.loader.efi.efiSysMountPoint} = {
        device = "/dev/disk/by-id/wwn-${mainId}-part2";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
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

    services = {
      beesd.filesystems."main" = {
        spec = "/dev/disk/by-id/wwn-${mainId}-part4";
        hashTableSizeMB = 128;
        verbosity = "crit";
        extraOptions = ["--loadavg-target" "2.0"];
      };
    };

    swapDevices = [
      {
        device = "/dev/disk/by-id/wwn-${mainId}-part3";
        priority = 0;
      }
    ];

    systemd.services."beesd@main".wantedBy = lib.mkForce [];
  };

  flake.nixosModules.u-default-specialisation = {config, ...}:
    lib.mkIf (config.specialisation != {}) {
      fileSystems = {
        "/" = {
          device = "/dev/disk/by-id/wwn-${mainId}-part4";
          fsType = "btrfs";
          options = ["subvol=@" "commit=60" "compress=zstd:11" "noatime"];
        };
      };
    };

  flake.nixosModules.u-attuned-specialisation = let
    attunedInternalDrive = "0x50014ee6b2ede306";
  in
    {...}: {
      specialisation.attuned.configuration = {
        fileSystems = {
          # "/" = {
          #   device = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part5";
          #   fsType = "btrfs";
          #   options = ["subvol=@" "commit=60" "compress=zstd:11" "noatime"];
          # };
          "/" = {
            device = "/dev/disk/by-id/wwn-${mainId}-part4";
            fsType = "btrfs";
            options = ["subvol=@" "commit=60" "compress=zstd:11" "noatime"];
          };
          "/mnt/attuned-internal" = {
            device = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part5";
            fsType = "btrfs";
            options = ["commit=60" "compress=zstd:11" "noatime"];
          };
        };

        services = {
          beesd.filesystems."attuned-internal" = {
            spec = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part5";
            hashTableSizeMB = 128;
            verbosity = "crit";
            extraOptions = ["--loadavg-target" "2.0"];
          };
        };

        swapDevices = [
          {
            device = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part4";
            priority = 1;
          }
        ];

        systemd.services."beesd@attuned-internal".wantedBy = lib.mkForce [];
      };
    };
}
