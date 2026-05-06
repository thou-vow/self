{
  inputs,
  lib,
  self,
  ...
}: {
  flake.nixosModules.u = {
    config,
    inputs',
    pkgs,
    ...
  }: {
    imports =
      [
        (self.lib.mkInstallWrappers {
          method.variant = "nixos";
          wrappers = {
            inherit
              (self.wrappers)
              nh
              ;
          };
        })
      ]
      ++ (with self.nixosModules; [
        core
        flatpak
        nix
        state
        waydroid
      ]);

    ext = {
      nix.determinate.enable = true;
      state.flakePath = "/self";
    };

    boot = {
      kernel.sysctl = {
        "kernel.nmi_watchdog" = 0;
        "kernel.split_lock_mitigate" = 0;
        "vm.swappiness" = 1;
        "vm.dirty_background_bytes" = 16777216;
        "vm.dirty_bytes" = 67108864;
      };
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
        hdparm
        heroic
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
      firefox.enable = true;
      git.enable = true;
      haguichi.enable = true;
      steam.enable = true;
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
      kmscon.enable = true;
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
    };

    virtualisation.podman.enable = true;
  };
}
