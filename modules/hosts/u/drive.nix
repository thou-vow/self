{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules.u = {
    config,
    pkgs,
    ...
  }: let
    hddId = "0x500003988168a3bd";
  in {
    imports = [inputs.impermanence.nixosModules.impermanence];

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
              mkdir -p /btrfs_tmp/old
              timestamp=$(date '+%Y-%m-%d_%H-%M-%S' --date="@$(stat -c %Y "/btrfs_tmp/@")")
              mv "/btrfs_tmp/@" "/btrfs_tmp/old/@$timestamp"
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
        grub = {
          enable = true;
          configurationLimit = 7;
          device = "/dev/disk/by-id/wwn-${hddId}";
          efiInstallAsRemovable = true;
          efiSupport = true;
        };
      };
    };

    fileSystems = {
      ${config.boot.loader.efi.efiSysMountPoint} = {
        device = "/dev/disk/by-id/wwn-${hddId}-part2";
        fsType = "vfat";
        options = ["fmask=0077" "dmask=0077"];
      };
      "/" = {
        device = "/dev/disk/by-id/wwn-${hddId}-part4";
        fsType = "btrfs";
        options = ["subvol=@" "commit=60" "compress=zstd:11" "noatime"];
      };
      "/nix" = {
        device = "/dev/disk/by-id/wwn-${hddId}-part4";
        fsType = "btrfs";
        options = ["subvol=@nix" "noatime"];
      };
      "/persist" = {
        device = "/dev/disk/by-id/wwn-${hddId}-part4";
        fsType = "btrfs";
        neededForBoot = true;
        options = ["subvol=@persist" "noatime"];
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
            ".cache/BraveSoftware"
            ".cache/mesa_shader_cache"
            ".cache/nix"
            ".cargo"
            ".config/Cemu"
            ".config/BraveSoftware"
            ".config/discord"
            ".config/PCSX2"
            ".local/bin"
            ".local/share/atuin"
            ".local/share/Cemu"
            ".local/share/containers"
            ".local/share/direnv"
            ".local/share/dolphin-emu"
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
            ".steam"
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

    services = {
      beesd.filesystems."-" = {
        spec = "/dev/disk/by-id/wwn-${hddId}-part4";
        hashTableSizeMB = 128;
        verbosity = "crit";
        extraOptions = ["--loadavg-target" "2.0"];
      };
    };

    swapDevices = [
      {
        device = "/dev/disk/by-id/wwn-${hddId}-part3";
        priority = 0;
      }
    ];

    systemd.services."beesd@-".wantedBy = lib.mkForce [];
  };
}
