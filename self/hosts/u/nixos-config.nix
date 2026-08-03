{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.u =
    self.lib.nixosSystem {
      inherit (withSystem "x86_64-linux" (args: args)) pkgs;
      useHomeManager = true;
    } {
      modules = [
        self.nixosModules.u
        ({pkgs, ...}: {
          home-manager = {
            backupCommand = "${pkgs.trash-cli}/bin/trash";
            useGlobalPkgs = true;
            useUserPackages = true;
            verbose = true;
          };
        })
      ];
    };

  flake.nixosModules.u = {
    inputs',
    pkgs,
    self',
    system,
    ...
  }: {
    imports = with self.nixosModules; [
      style

      nh
      waydroid
    ];

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
        systemd.emergencyAccess = true;
      };
      kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "kernel.split_lock_mitigate" = 0;
        "vm.dirty_background_bytes" = 33554432;
        "vm.dirty_bytes" = 268435456;
        "vm.dirty_expire_centisecs" = 6000;
        "vm.dirty_writeback_centisecs" = 1500;
        "vm.max_map_count" = 2147483642;
        "vm.min_free_kbytes" = 122880;
        "vm.page-cluster" = 0;
        "vm.swappiness" = 20;
        "vm.vfs_cache_pressure" = 25;
        "vm.watermark_scale_factor" = 100;
      };

      kernelPackages =
        inputs.linux-cachyos-lto-v3.inputs.chaotic-nyx.legacyPackages.${system}.linuxPackages_cachyos-lto.extend
        (_: _: {
          kernel = inputs'.linux-cachyos-lto-v3.packages.default;
        });

      kernelParams = [
        "8250.nr_uarts=0"
        "ath9k_core.nohwcrypt=1"
        "mitigations=off"
      ];
    };

    console.useXkbConfig = true;

    environment = {
      sessionVariables = {
        GSK_RENDERER = "gl";
        MESA_SHADER_CACHE_MAX_SIZE = "10G";
        NIXPKGS_ALLOW_UNFREE = "1";
        PERSIST = "/persist";
      };
      systemPackages =
        (with pkgs; [
          android-tools
          brightnessctl
          btop
          cabextract
          cachix
          cpuid
          curl
          ddrescue
          dmidecode
          dnsutils
          fastfetch
          fd
          fio
          git
          hdparm
          inxi
          iotop
          jq
          lm_sensors
          lsof
          ncdu
          nix-output-monitor
          ntfs3g
          p7zip
          pciutils
          rclone
          ripgrep
          ripgrep-all
          smartmontools
          strace
          sysstat
          tree
          unrar
          unzip
          usbutils
          util-linux
          wget
          zip
        ])
        ++ (with self'.packages; [
          steam-run
        ]);
    };

    hardware = {
      enableRedistributableFirmware = true;
      bluetooth.enable = true;
      cpu.intel.updateMicrocode = true;
      graphics = {
        enable = true;
        enable32Bit = true;
        package = inputs'.nix-packages.packages.mesa-attuned;
      };
    };

    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = {
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "pt_BR.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };
    };

    networking = {
      dhcpcd.enable = false;
      hostName = "u";
      nftables.enable = true;
      useNetworkd = true;
      wireless.iwd = {
        enable = true;
        settings = {
          DriverQuirks.PowerSaveDisable = "ath9k";
          General.EnableNetworkConfiguration = true;
          Settings.AutoConnect = true;
        };
      };
    };

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";

      package = inputs'.nix-packages.packages.lix-attuned;

      settings.tarball-ttl = 604800;
    };

    programs = {
      dconf.enable = true;
    };

    security = {
      rtkit.enable = true;
      polkit.enable = true;
      sudo.extraConfig = ''
        Defaults pwfeedback
        Defaults insults
      '';
    };

    services = {
      flatpak.enable = true;
      lvm.enable = false;
      openssh.enable = true;
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
      };
      power-profiles-daemon.enable = true;
      pulseaudio.enable = false;
      upower.enable = true;
      xserver.xkb = {
        layout = "br,us";
        options = "caps:escape_shifted_capslock,grp:win_space_toggle";
      };
    };

    system.stateVersion = "26.05";

    systemd = {
      network = {
        networks."10-wired" = {
          matchConfig.Type = "ether";
          networkConfig.DHCP = "yes";
        };
        wait-online.enable = false;
      };
      oomd.enable = false;
      services.disable-i915-mitigations = {
        description = "Set i915 (Intel Graphics) mitigations off at runtime";
        before = ["graphical.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = "${pkgs.writeShellScript "disable-i915-mitigations" ''
            if [ -w /sys/module/i915/parameters/mitigations ]; then
              echo off > /sys/module/i915/parameters/mitigations
            fi
          ''}";
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
      };
    };

    time = {
      hardwareClockInLocalTime = true;
      timeZone = "America/Sao_Paulo";
    };

    users.users = {
      root.password = "123";
      thou = {
        uid = 1000;
        isNormalUser = true;
        description = "thou";
        extraGroups = ["networkmanager" "wheel"];
        password = "123";
        shell = lib.getExe pkgs.bash;
      };
    };

    virtualisation.waydroid.package = pkgs.waydroid-nftables;

    xdg.portal = {
      enable = true;
      config.common.default = ["gtk"];
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
  };
}
