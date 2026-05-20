{
  lib,
  self,
  ...
}: {
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
          method.nixosUser.user = "thou";
          wrappers = {
            inherit
              (self.wrappers)
              atuin
              direnv
              git
              helix
              kitty
              niri
              nushell
              prismlauncher
              ;
          };
        })
      ]
      ++ map (m: m "thou")
      (with self.nixosUserModules; [prefs]);

    wrappers.users.thou = {
      atuin.daemon.systemd.enable = true;
      nushell = {
        environmentVariables = config.ext.users.thou.prefs.environmentVariables;
        shellAliases = config.ext.users.thou.prefs.shellAliases;
      };
      git.settings.user = {
        email = "thou.vow.etoile@gmail.com";
        name = "thou-vow";
      };
    };

    ext.users.thou = {
      prefs = {
        environmentVariables = {
          PERSIST_HOME = config.environment.variables.PERSIST + "/home/thou";
        };
        shellAliases = {};
      };
    };

    systemd.user.tmpfiles = let
      protonPackages = with inputs'.nix-packages.packages; {
        "DW-Proton" = dwproton.steamcompattool;
        "Proton-CachyOS" = proton-cachyos.steamcompattool;
        "Proton-CachyOS-v3" = proton-cachyos-v3.steamcompattool;
        "Proton-GE" = proton-ge.steamcompattool;
      };
      steaminstalldir = "%h/.local/share/Steam";
      compatdir = "${steaminstalldir}/compatibilitytools.d";
    in {
      enable = true;
      users.thou.rules =
        [
          "d ${compatdir} 0755 - - -"
          "d %h/.steam 0755 - - -"
        ]
        ++ (lib.mapAttrsToList
          (name: value: "L+ ${compatdir}/${name} - - - - ${value}")
          protonPackages)
        ++ [
          "L %h/.steam/root  - - - - ${steaminstalldir}"
          "L %h/.steam/steam - - - - ${steaminstalldir}"
        ];
    };

    users.users.thou = {
      uid = 1000;
      isNormalUser = true;
      description = "thou";
      extraGroups = ["networkmanager" "wheel"];
      packages =
        (with pkgs; [
          azahar
          bc
          cemu
          distrobox
          dolphin-emu
          faugus-launcher
          gcc
          geminicommit
          imagemagick
          krita
          libreoffice
          mame
          mangohud
          melonds
          mgba
          pcsx2
          qbittorrent
          rclone
          ripgrep
          typst
          vlc
          winetricks
          xdg-utils
          yazi
          zathura
        ])
        ++ [
          inputs'.nix-packages.packages.discord-rpc-lsp
        ];
      password = "123";
      shell = lib.getExe pkgs.bash;
    };
  };

  flake.nixosModules.u-attuned-specialisation = {inputs', ...}: {
    specialisation.attuned.configuration = {
      wrappers.users.thou.niri.package = inputs'.nix-packages.packages.niri-pr-attuned;
    };
  };
}
