{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.u =
    self.lib.nixosSystem
    (withSystem "x86_64-linux" ({pkgs, ...}: pkgs)) {
      modules = [
        self.nixosModules.u
        self.nixosModules.u-attuned-specialisation
        self.nixosModules.u-default-specialisation
      ];
    };

  flake.nixosModules.u = {
    config,
    inputs',
    pkgs,
    system,
    ...
  }: {
    imports =
      [
        (self.lib.installWrappers system {
          method.nixos = true;
          wrappers = {
            inherit
              (self.wrappers)
              nh
              ;
          };
        })
      ]
      ++ (with self.nixosModules; [
        nix
        waydroid
      ]);

    ext = {
      nix.determinate.enable = true;
    };

    boot = {
      initrd.availableKernelModules = [
        "ehci_pci"
        "xhci_pci"
        "ahci"
        "usb_storage"
        "uas"
        "sd_mod"
        "usbhid"
      ];
      kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "kernel.split_lock_mitigate" = 0;
        "vm.swappiness" = 1;
        "vm.dirty_background_bytes" = 16777216;
        "vm.dirty_bytes" = 67108864;
        "vm.max_map_count" = 1048576;
      };
      kernelPackages = inputs'.nyx-loner.legacyPackages.linuxPackages_cachyos-lto;
      kernelParams = ["mitigations=off"];
    };

    console.useXkbConfig = true;

    environment = {
      systemPackages = with pkgs; [
        btop
        cabextract
        cachix
        cpuid
        curl
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
        unrar
        unzip
        usbutils
        util-linux
        wget
        zip
      ];
      variables = {
        MESA_SHADER_CACHE_MAX_SIZE = "10G";
        NIXPKGS_ALLOW_UNFREE = "1";
        PERSIST = "/persist";
      };
    };

    fonts = {
      enableDefaultPackages = true;
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = ["VictorMono Nerd Font Mono"];
          sansSerif = ["Noto Sans"];
          serif = ["Noto Serif"];
          emoji = ["Noto Color Emoji"];
        };
      };
      packages = with pkgs; [
        corefonts
        nerd-fonts.victor-mono
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
      ];
    };

    hardware = {
      bluetooth.enable = true;
      cpu.intel.updateMicrocode = true;
      graphics = {
        enable = true;
        enable32Bit = true;
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
      networkmanager = {
        enable = true;
        wifi.powersave = false;
      };
      nftables.enable = true;
      useNetworkd = true;
    };

    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
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
      auto-cpufreq = {
        enable = true;
        settings = {
          battery = {
            energy_perf_bias = "power";
            energy_performance_preference = "power";
            governor = "powersave";
            turbo = "never";
          };
          charger = {
            energy_perf_bias = "performance";
            energy_performance_preference = "performance";
            governor = "performance";
            turbo = "auto";
          };
        };
      };
      blueman.enable = true;
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
      pulseaudio.enable = false;
      xserver.xkb = {
        layout = "br,us";
        options = "caps:escape_shifted_capslock,grp:win_space_toggle";
      };
    };

    system.stateVersion = "25.11";

    systemd.oomd.enable = false;

    time = {
      hardwareClockInLocalTime = true;
      timeZone = "America/Sao_Paulo";
    };

    users.users.root.password = "123";
  };

  flake.nixosModules.u-default-specialisation = {
    config,
    inputs',
    pkgs,
    ...
  }:
    lib.mkIf (config.specialisation != {}) {
      hardware = {
        cpu.amd.updateMicrocode = true;
        enableAllFirmware = true;
        enableAllHardware = true;
      };

      networking.nameservers = [
        "8.8.4.4"
        "8.8.8.8"
      ];

      zramSwap = {
        enable = true;
        memoryPercent = 80;
        priority = 1;
      };
    };

  flake.nixosModules.u-attuned-specialisation = {
    inputs',
    pkgs,
    ...
  }: {
    specialisation.attuned.configuration = {
      boot.kernelParams = [
        "ath9k_core.nohwcrypt=1"
        "pcie_aspm=off"
        "zswap.enabled=1"
        "zswap.max_pool_percent=80"
        "zswap.shrinker_enabled=0"
      ];

      environment.etc."specialisation".text = "attuned";

      hardware = {
        graphics.package = inputs'.nix-packages.packages.mesa-attuned;
        enableRedistributableFirmware = true;
      };

      systemd.services.disable-i915-mitigations = {
        description = "Set i915 (Intel Graphics) mitigations off at runtime";
        before = ["graphical.target"];
        wantedBy = ["multi-user.target"];
        serviceConfig = {
          ExecStart = let
            script = pkgs.writeShellScript "disable-i915-mitigations" ''
              if [ -w /sys/module/i915/parameters/mitigations ]; then
                echo off > /sys/module/i915/parameters/mitigations
              fi
            '';
          in "${script}";
          Type = "oneshot";
          RemainAfterExit = "yes";
        };
      };
    };
  };
}
