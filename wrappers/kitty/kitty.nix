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
            (lib.mkIf (config.keybindings != {}) (
              lib.mkOrder 510 (config.keybindings
                |> lib.generators.toKeyValue {
                  mkKeyValue = k: v: "map ${k} ${v}";
                })
            ))
            (lib.mkIf (config.mouseBindings != {}) (
              lib.mkOrder 520 (config.mouseBindings
                |> lib.generators.toKeyValue {
                  mkKeyValue = k: v: "mouse_map ${k} ${v}";
                })
            ))
            (lib.mkIf (config.settings != {}) (
              lib.mkOrder 530 (config.settings
                |> lib.generators.toKeyValue {
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
            ))
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
        kittyConf = lib.mkBefore ''
          include ./manual-kitty.conf
        '';
        settings.clear_all_shortcuts = true;
      }
    ];
  };
}
