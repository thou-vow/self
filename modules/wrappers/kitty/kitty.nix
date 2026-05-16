{
  inputs,
  lib,
  self,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.kitty = {
      module = {
        config,
        pkgs,
        ...
      }: {
        imports = [self.wrapperModules.writeFiles];

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
            type = self.lib.dagLinesType;
            default = "";
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

          kittyConf = lib.mkMerge [
            (lib.pipe config.settings [
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
              (self.lib.mkNamedEntryBetween "SETTINGS" [] [])
              (lib.mkIf (config.settings != {}))
            ])
            (lib.pipe config.keybindings [
              (lib.generators.toKeyValue {
                mkKeyValue = k: v: "map ${k} ${v}";
              })
              (self.lib.mkNamedEntryBetween "KEYBINDINGS" [] ["SETTINGS"])
              (lib.mkIf (config.keybindings != {}))
            ])
            (lib.pipe config.mouseBindings [
              (lib.generators.toKeyValue {
                mkKeyValue = k: v: "mouse_map ${k} ${v}";
              })
              (self.lib.mkNamedEntryBetween "MOUSE_BINDINGS" ["DEFAULT"] ["KEYBINDINGS"])
              (lib.mkIf (config.mouseBindings != {}))
            ])
          ];

          package = lib.mkDefault pkgs.kitty;

          writeFiles.kittyConfig = {
            eject.enable = true;
            entries = lib.mkMerge [
              {
                "kitty.conf" = lib.mkIf (config.kittyConf != "") {
                  subject.text = config.kittyConf;
                };
              }
              config.extraConfigFiles
            ];
          };
        };
      };
    };
  }

  {
    flake.wrappers.kitty = {
      module = {
        extraConfigFiles = {
          "manual-kitty.conf".subject.source = ./manual-kitty.conf;
          "theme.conf".subject.source = ./theme.conf;
        };
        kittyConf = self.lib.mkEntryAfter ["SETTINGS"] ''
          include ./manual-kitty.conf
        '';
        settings.clear_all_shortcuts = true;
      };
    };
  }
]
