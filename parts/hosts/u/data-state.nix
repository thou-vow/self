{inputs, ...}: let
  driveId = "0x50014ee6b2ede306";
in {
  flake.nixosModules.u = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      "${inputs.preservation}/module.nix"
    ];

    self.base.flakePath = "/self";

    boot = {
      initrd = {
        kernelModules = [
          "ahci"
          "sd_mod"
          "uas"
          "usb_storage"
          "usbhid"
          "xhci_pci"
        ];

        systemd = {
          extraBin = {
            date = "${pkgs.coreutils}/bin/date";
            mkdir = "${pkgs.coreutils}/bin/mkdir";
            mv = "${pkgs.coreutils}/bin/mv";
            stat = "${pkgs.coreutils}/bin/stat";
          };

          services.root-rolling = {
            description = "Archiving current / and creating a fresh one";

            after = ["initrd-root-device.target" "local-fs-pre.target"];
            before = ["initrd.target" "sysroot.mount"];
            requiredBy = ["initrd.target"];
            requires = ["initrd-root-device.target"];

            script = ''
              mkdir "/xfs"
              mount -o noatime ${config.fileSystems."/".device} "/xfs"

              if [[ -e "/xfs/@" ]]; then
                mkdir -p "/xfs/.archive"
                timestamp=$(date '+%Y-%m-%d_%H-%M-%S' --date="@$(stat -c %Y "/xfs/@")")
                mv "/xfs/@" "/xfs/.archive/@$timestamp"
              fi

              mkdir "/xfs/@"
              umount "/xfs"
            '';

            serviceConfig.Type = "oneshot";
            unitConfig.DefaultDependencies = false;
          };

          tmpfiles.settings.preservation."/sysroot/persist/etc/machine-id".f.argument = "uninitialized";
        };
      };

      loader = {
        efi.efiSysMountPoint = "/boot";
        limine = {
          enable = true;
          biosDevice = "nodev";
          efiInstallAsRemovable = true;
          efiSupport = true;
          maxGenerations = 15;
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
      "/cache" = {
        device = "/dev/disk/by-id/wwn-${driveId}-part10";
        fsType = "xfs";
        options = ["X-mount.subdir=@cache" "noatime"];
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
      preserveAt = {
        "/cache" = {
          directories = [
            {
              directory = "/var/tmp";
              mode = "1777";
            }
          ];
          users = {
            root = {
              home = "/root";
              directories = [".cache/nix"];
            };
            thou.directories = [
              ".cache/BraveSoftware"
              ".cache/mesa_shader_cache"
              ".cache/nix"
            ];
          };
        };

        "/persist" = {
          directories = [
            {
              directory = config.self.base.flakePath;
              user = "thou";
            }
            "/srv"
            "/var/lib/flatpak"
            "/var/lib/iwd"
            "/var/lib/nixos"
            "/var/lib/nixos-containers"
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
          users = {
            root = {
              home = "/root";
              directories = [".local/share/nix"];
            };
            thou = {
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
                ".local/state/nix"
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
