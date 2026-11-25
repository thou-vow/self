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

      specialArgs.driveId = "0x50014ee6b2ede306";
    };

  flake.nixosModules.u = {
    config,
    inputs',
    pkgs,
    self',
    ...
  }: {
    imports =
      (with self.nixosModules; [
        style

        nh
        waydroid
      ])
      ++ [
        inputs.aagl-gtk-on-nix.nixosModules.default
      ];

    boot.kernel.sysctl = {
      "net.ipv4.ip_unprivileged_port_start" = 80;
    };

    console.useXkbConfig = true;

    environment = {
      etc =
        lib.mapAttrs' (k: v: {
          name = "inputs/${k}";
          value.source = v;
        })
        inputs;

      pathsToLink = ["/share/xdg-desktop-portal"];

      sessionVariables = {
        NIXPKGS_ALLOW_UNFREE = "1";
        PERSIST = "/persist";
      };

      systemPackages =
        [
          inputs'.nix-packages.packages.tack
        ]
        ++ (with pkgs; [
          android-tools
          brightnessctl
          btop
          busybox
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
          gomi
          hdparm
          intel-gpu-tools
          inxi
          iotop
          jq
          keyd
          libva-utils
          lm_sensors
          lshw
          lsof
          mesa-demos
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
          vulkan-tools
          wev
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
      firewall = {
        allowedUDPPorts = [config.services.tailscale.port];
        trustedInterfaces = [config.services.tailscale.interfaceName];
      };
      hostName = "u";
      nftables.enable = true;
      useNetworkd = true;
      wireless.iwd = {
        enable = true;
        settings = {
          General.EnableNetworkConfiguration = true;
          Settings.AutoConnect = true;
        };
      };
    };

    programs = {
      appimage = {
        enable = true;
        binfmt = true;
      };
      dconf.enable = true;
      gpu-screen-recorder = {
        enable = true;
        ui.enable = true;
      };
      honkers-railway-launcher.enable = true;
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
      crossmacro = {
        enable = true;
        users = ["thou"];
      };
      keyd = {
        enable = true;
        keyboards.default = {
          ids = ["*" "m:10c4:0005:0e62ec36"];
          settings = {
            main.capslock = "overload(middle, escape)";
            middle = {
              leftmouse = "scrollup";
              rightmouse = "scrolldown";
              tab = "middlemouse";
            };
          };
        };
      };
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
      xserver.xkb.layout = "br";
      zerotierone.enable = true;
    };

    system.stateVersion = "26.11";

    systemd = {
      network.networks."10-wired" = {
        matchConfig.Type = "ether";
        networkConfig.DHCP = "yes";
      };
      services = {
        crossmacro.wantedBy = lib.mkForce [];
        "user@".serviceConfig.Delegate = lib.mkDefault [
          "cpu"
          "cpuset"
          "io"
          "memory"
          "pids"
        ];
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
        description = "thou";
        extraGroups = ["networkmanager" "wheel"];
        isNormalUser = true;
        linger = true;
        password = "123";
        shell = lib.getExe pkgs.zsh;
        subGidRanges = [
          {
            startGid = 100000;
            count = 65536;
          }
        ];
        subUidRanges = [
          {
            startUid = 100000;
            count = 65536;
          }
        ];
      };
    };

    virtualisation.waydroid.package = pkgs.waydroid-nftables;
  };
}
