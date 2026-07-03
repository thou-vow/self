{
  inputs,
  self,
  ...
}: let
  driveId = "0x50014ee6b2ede306";
in {
  flake.nixosPresets."!u" = {config, ...}: {
    imports = [
      self.nixosModules.mapState
      inputs.preservation.nixosModules.default
    ];

    modules.mapState.flakePath = "/self";

    boot = {
      initrd.systemd.tmpfiles.settings.preservation."/sysroot/persist/etc/machine-id".f.argument = "uninitialized";
      loader = {
        efi.efiSysMountPoint = "/boot";
        limine = {
          enable = true;
          biosDevice = "nodev";
          efiInstallAsRemovable = true;
          efiSupport = true;
          maxGenerations = 7;
        };
        timeout = 15;
      };
    };

    fileSystems = {
      ${config.boot.loader.efi.efiSysMountPoint} = {
        device = "/dev/disk/by-id/wwn-${driveId}-part8";
        fsType = "vfat";
        noCheck = true;
        options = ["fmask=0077" "dmask=0077"];
      };
      "/" = {
        device = "/dev/disk/by-id/wwn-${driveId}-part10";
        fsType = "xfs";
        options = ["X-mount.subdir=@" "noatime"];
      };
      "/nix" = {
        device = "/dev/disk/by-id/wwn-${driveId}-part10";
        fsType = "xfs";
        options = ["X-mount.subdir=@nix" "noatime"];
      };
      "/persist" = {
        device = "/dev/disk/by-id/wwn-${driveId}-part10";
        fsType = "xfs";
        neededForBoot = true;
        options = ["X-mount.subdir=@persist" "noatime"];
      };

      "/mnt/u" = {
        device = "/dev/disk/by-id/wwn-${driveId}-part10";
        fsType = "xfs";
        options = ["noatime"];
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
          "/root/.local/share/nix"
          "/srv"
          "/var/lib/flatpak"
          "/var/lib/hjem"
          "/var/lib/iwd"
          "/var/lib/nixos"
          "/var/lib/nixos-containers"
          "/var/lib/waydroid"
          "/var/log"
          "/var/tmp"
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
            ".config/Cemu"
            ".config/BraveSoftware"
            ".config/PCSX2"
            ".jail"
            ".local/bin"
            ".local/share/atuin"
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
      zram-generator = {
        enable = true;
        settings.zram0 = {
          compression-algorithm = "lz4 zstd(level=3) (type=idle)";
          writeback-device = "/dev/disk/by-id/wwn-${driveId}-part9";
          zram-size = "4 / 5 * ram";
        };
      };
    };

    systemd.services = {
      systemd-machine-id-commit.unitConfig.ConditionFirstBoot = true;
    };
  };
}
