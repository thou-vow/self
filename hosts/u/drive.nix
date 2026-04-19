{
  inputs,
  lib,
  ...
}: {
  flake.nixosModules."hosts.u" = {
    config,
    pkgs,
    ...
  }: let
    hddId = "0x500003988168a3bd";
  in {
    imports = [inputs.impermanence.nixosModules.impermanence];

    boot = {
      initrd.postResumeCommands = ''
        mkdir "/btrfs"
        mount ${config.fileSystems."/".device} "/btrfs"

        if [[ -e "/btrfs/@" ]]; then
          mkdir -p /btrfs/old
          timestamp=$(date '+%Y-%m-%d_%H-%M-%S' --date="@$(stat -c %Y "/btrfs/@")")
          mv "/btrfs/@" "/btrfs/old/@$timestamp"
        fi

        btrfs subvolume create "/btrfs/@"

        umount "/btrfs"
      '';
      loader = {
        efi.efiSysMountPoint = "/boot";
        grub = {
          enable = true;
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
        options = ["subvol=@" "commit=60" "compress=zstd:10" "noatime"];
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
          config.custom.core.flakePath
          "/etc/NetworkManager/system-connections"
          "/root/.cache/nix"
          "/root/.local/share/nix"
          "/root/.local/state/nix"
          "/srv"
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
            ".cache/mesa_shader_cache"
            ".cache/nix"
            ".cargo"
            ".config/Cemu"
            ".config/discord"
            ".config/heroic"
            ".config/PCSX2"
            ".local/bin"
            ".local/share/Cemu"
            ".local/share/containers"
            ".local/share/direnv"
            ".local/share/dolphin-emu"
            ".local/share/nix"
            ".local/share/osuconfig"
            ".local/share/osu-wine"
            ".local/share/qBittorrent"
            ".local/share/Steam"
            ".local/share/umu"
            ".local/share/waydroid"
            ".local/share/wineprefixes"
            ".local/share/yawl"
            ".local/state/nix"
            ".m2"
            ".ssh"
            ".steam"
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

            ".local/share/atuin"
            ".local/share/flatpak"
            ".local/share/steel"
            ".local/share/zoxide"
            ".var"
          ];
          files = [
            ".local/share/fish/fish_history"

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

      # These rules only apply for HDD, preferably connected via USB 2.0
      udev.extraRules = lib.concatStringsSep ", " [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''ENV{DEVTYPE}=="disk"''
        ''ENV{ID_WWN}=="${hddId}"''
        # ''ATTR{queue/rotational}==1'' # Extra HDD validation
        ''RUN+="${lib.getExe pkgs.hdparm} -a 1024 -B 255 /dev/%k"''
      ];
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
