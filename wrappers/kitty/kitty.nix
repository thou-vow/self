{
  lib,
  self,
  ...
}: {
  flake.wrappers.kitty = {
    module = lib.mkMerge [
      self.wrapperModules.core
      self.wrapperModules.eject

      ({
        config,
        pkgs,
        ...
      }: {
        options = {
          extraPaths = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {type = lib.types.str;};
                path = lib.mkOption {type = lib.types.path;};
              };
            });
            default = [];
          };
          keybindings = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
          };
          kittyConf = lib.mkOption {
            type = lib.types.lines;
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
          flags."--config" = "${config.eject.directory}/${baseNameOf config.eject.entries.kittyConfig}/kitty.conf";

          eject.entries.kittyConfig = pkgs.linkFarm "kitty-config" (
            self.lib.mkLinkFarmOptionalText (config.kittyConf != "") {
              inherit pkgs;
              name = "kitty.conf";
              text = config.kittyConf;
            }
            ++ config.extraPaths
          );

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
              (lib.mkOrder 510)
              (lib.mkIf (config.settings != {}))
            ])
            (lib.pipe config.keybindings [
              (lib.generators.toKeyValue {
                mkKeyValue = k: v: "map ${k} ${v}";
              })
              (lib.mkOrder 520)
              (lib.mkIf (config.keybindings != {}))
            ])
            (lib.pipe config.mouseBindings [
              (lib.generators.toKeyValue {
                mkKeyValue = k: v: "mouse_map ${k} ${v}";
              })
              (lib.mkOrder 530)
              (lib.mkIf (config.mouseBindings != {}))
            ])
          ];

          package = lib.mkDefault pkgs.kitty;
        };
      })

      {
        extraPaths = [
          {
            name = "manual-kitty.conf";
            path = ./manual-kitty.conf;
          }
          {
            name = "theme.conf";
            path = ./theme.conf;
          }
        ];
        kittyConf = ''
          include ./manual-kitty.conf
        '';
        settings.clear_all_shortcuts = true;
      }
    ];
  };
}
