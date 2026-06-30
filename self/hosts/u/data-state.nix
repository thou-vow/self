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
      initrd.systemd.tmpfiles.settings.preservation."/sysroot/persist/etc/machine-id".f.argument = "uninitialized";
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
        timeout = 15;
      };
    };

    fileSystems = {
      ${config.boot.loader.efi.efiSysMountPoint} = {
        device = "/dev/disk/by-id/wwn-${mainId}-part2";
        fsType = "vfat";
        noCheck = true;
        options = ["fmask=0077" "dmask=0077"];
      };
      "/" =
        if specialisation == "attuned"
        then {
          device = "/dev/disk/by-id/wwn-${attunedInternalDrive}-part5";
          fsType = "xfs";
          options = ["noatime"];
        }
        else {
          device = "/dev/disk/by-id/wwn-${mainId}-part4";
          fsType = "xfs";
          options = ["noatime"];
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
          "/root/.cache/nix"
          "/root/.local/share/nix"
          "/srv"
          "/var/lib/flatpak"
          "/var/lib/hjem"
          "/var/lib/iwd"
          "/var/lib/machines"
          "/var/lib/nixos"
          "/var/lib/nixos-containers"
          "/var/lib/portables"
          "/var/lib/systemd/coredump"
          "/var/lib/systemd/rfkill"
          "/var/lib/systemd/timers"
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
      udev.extraRules = builtins.concatStringsSep ", " [
        ''ACTION=="add|change"''
        ''SUBSYSTEM=="block"''
        ''ENV{DEVTYPE}=="disk"''
        ''ENV{ID_WWN}=="${mainId}"''
        ''ATTR{queue/add_random}="0"''
        ''ATTR{queue/nr_requests}="16"''
        ''ATTR{queue/read_ahead_kb}="1024"''
        ''ATTR{queue/rq_affinity}="2"''
        ''RUN+="${lib.getExe pkgs.hdparm} -B 255 /dev/%k"''
      ];
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

    systemd.services = {
      "beesd@attuned-internal" = lib.mkIf (specialisation == "attuned") {wantedBy = lib.mkForce [];};
      "beesd@main".wantedBy = lib.mkForce [];
      systemd-machine-id-commit.unitConfig.ConditionFirstBoot = true;
    };
  };
}
