{
  lib,
  self,
  ...
}: {
  flake.homeModules.umbriel = {
    config,
    inputs',
    pkgs,
    ...
  }: let
    cfg = config.self.mods.umbriel;
  in {
    imports = [
      "${inputs'.nixpkgs.legacyPackages.umbriel.src}/nix/home-module.nix"
    ];

    options.self.mods.umbriel = {
      enable = self.lib.mkAutoEnableOption "Umbriel";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.umbriel;
        description = "The Umbriel package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        dash
        brightnessctl
        playerctl
        wireplumber
        wl-clipboard
      ];

      programs.umbriel = {
        inherit (cfg) enable package;
        settings = {
          include.files =
            (lib.optionals (config.self.style.enable or false) ["umbriel-theme.toml"])
            ++ ["umbriel-manual.toml"];

          keybinds =
            lib.pipe {
              "Mod+Shift+Escape" = "spawn noctalia msg panel-toggle session";
              "Print" = "spawn noctalia msg screenshot-region"; # Frozen region
              "Shift+Print" = "spawn noctalia msg screenshot-region"; # Frozen fullscreen
              "Ctrl+Print" = "spawn noctalia msg annotate"; # Unfrozen fullscreen
              "Mod+backslash" = "spawn noctalia msg panel-toggle control-center";
              "Mod+Shift+backslash" = "spawn noctalia msg settings-toggle";
              "Mod+V" = "spawn noctalia msg panel-toggle clipboard";
              "Mod+Shift+V" = "spawn noctalia msg panel-toggle emoji";
            } [
              (builtins.mapAttrs (_: v: {
                action = v;
                repeat = false;
              }))
              (lib.mkIf (config.self.mods.noctalia.enable or false))
            ];
        };
      };

      xdg = {
        configFile = {
          "umbriel/umbriel-manual.toml".source = ./umbriel-manual.toml;
          "umbriel/umbriel-theme.toml" = lib.mkIf (config.self.style.enable or false) {
            source =
              self.lib.renderMustache pkgs "umbriel-theme.toml"
              config.self.style.palette
              ./umbriel-theme.toml.mustache;
          };
        };

        portal = {
          enable = true;
          config.umbriel.default = ["umbriel" "gtk"];
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-umbriel
          ];
        };
      };
    };
  };
}
