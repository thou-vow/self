{
  inputs,
  lib,
  self,
  withSystem,
  wlib,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.kitty.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

    flake.wrappers.kitty.module = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        self.wrapperModules.writeFiles
        wlib.modules.symlinkScript
      ];

      options = {
        extraConfigFiles = lib.mkOption {
          type = self.lib.filesType pkgs;
          default = {};
        };
        keybindings = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
        };
        kittyConf = lib.mkOption {
          type = wlib.types.dagOf lib.types.str;
          default = {};
        };
        mouseBindings = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = {};
        };
        settings = lib.mkOption {
          type = with lib.types; attrsOf (oneOf [bool float int str]);
          default = {};
        };
      };

      config = {
        flags."--config" = "${config.writeFiles.kittyConfig.location}/kitty.conf";

        kittyConf = {
          settings = lib.pipe config.settings [
            (lib.generators.toKeyValue {
              mkKeyValue = key: value: let
                value' =
                  if builtins.isBool value
                  then
                    if value
                    then "yes"
                    else "no"
                  else toString value;
              in "${key} ${value'}";
            })
            wlib.dag.entryAnywhere
            (lib.mkIf (config.settings != {}))
          ];

          keybindings = lib.pipe config.keybindings [
            (lib.generators.toKeyValue {
              mkKeyValue = k: v: "map ${k} ${v}";
            })
            (wlib.dag.entryAfter ["settings"])
            (lib.mkIf (config.keybindings != {}))
          ];

          mouseBindings = lib.pipe config.mouseBindings [
            (lib.generators.toKeyValue {
              mkKeyValue = k: v: "mouse_map ${k} ${v}";
            })
            (wlib.dag.entryAfter ["keybindings"])
            (lib.mkIf (config.mouseBindings != {}))
          ];
        };

        package = lib.mkDefault pkgs.kitty;

        writeFiles.kittyConfig = {
          eject.enable = true;
          entries = lib.mkMerge [
            {
              "kitty.conf" = lib.mkIf (config.kittyConf != "") {
                subject.text = self.lib.convertDagOfStrToLines config.kittyConf;
              };
            }
            config.extraConfigFiles
          ];
        };
      };
    };
  }

  {
    flake.wrappers.kitty.module = {wlib, ...}: {
      extraConfigFiles = {
        "manual-kitty.conf".subject.source = ./manual-kitty.conf;
        "theme.conf".subject.source = ./theme.conf;
      };
      kittyConf.manual = wlib.dag.entryAfter ["settings"] ''
        include ./manual-kitty.conf
      '';
      settings.clear_all_shortcuts = true;
    };
  }
]
