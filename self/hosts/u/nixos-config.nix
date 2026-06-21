{
  lib,
  self,
  withSystem,
  ...
}: {
  flake.nixosConfigurations.u =
    self.lib.nixosSystem {
      inherit (withSystem "x86_64-linux" (args: args)) pkgs;
      hjem = true;
    } {
      modules = [
        self.nixosPresets."!u"
        ({
          config,
          specialisation,
          ...
        }: {
          _module.args.specialisation = lib.mkIf (config.specialisation != {}) null;
          hjem.specialArgs = {inherit specialisation;};
          specialisation.attuned.configuration._module.args.specialisation = "attuned";
        })
      ];
    };

  flake.nixosPresets."!u" = {
    inputs',
    pkgs,
    self',
    specialisation,
    ...
  }: {
    imports =
      [
        (self.lib.installWrappers {
          method.nixos = true;
          wrappers = {
            inherit
              (self.wrappers)
              nh
              ;
          };
        })
      ]
      ++ (with self.nixosPresets; [
        waydroid
      ]);

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
        "vm.dirty_background_bytes" = 16777216;
        "vm.dirty_bytes" = 67108864;
        "vm.max_map_count" = 2147483642;
        "vm.page-cluster" = 0;
        "vm.swappiness" = 1;
        "vm.vfs_cache_pressure" = 10;
      };
      kernelPackages = inputs'.chaotic-nyx.legacyPackages.linuxPackages_cachyos-lto;
      kernelParams = ["mitigations=off"];
    };

    console.useXkbConfig = true;

    environment = {
      etc."specialisation" = lib.mkIf (specialisation != null) {text = specialisation;};
      sessionVariables = {
        MESA_SHADER_CACHE_MAX_SIZE = "10G";
        NIXPKGS_ALLOW_UNFREE = "1";
        PERSIST = "/persist";
        WRITABLE_STORE = "/tmp/store";
      };
      systemPackages =
        (with pkgs; [
          android-tools
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

    nix = {
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";

      package = pkgs.lix;

      settings = {
        max-jobs = 8;
        max-substitution-jobs = 2;
        tarball-ttl = 604800;
      };
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
      config.common = {
        "default" = ["gnome" "gtk" "kde"];
        "org.freedesktop.impl.portal.Access" = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "kde";
        "org.freedesktop.impl.portal.Notification" = "gtk";
      };
      extraPortals = with pkgs; [
        kdePackages.xdg-desktop-portal-kde
        xdg-desktop-portal-gnome
        xdg-desktop-portal-gtk
      ];
    };
  };
}
