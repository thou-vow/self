{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.kitty = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.constructFiles
      wlib.modules.makeWrapper
      wlib.modules.symlinkScript
    ];

    options = {
      environmentVariables = lib.mkOption {
        type = self.lib.types.environmentVariables;
        default = {};
      };
      extraConfigFiles = lib.mkOption {
        type = lib.types.attrsOf (wlib.types.file pkgs);
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
        type = lib.types.attrsOf self.lib.types.kittyValue;
        default = {};
      };
    };

    config = {
      constructFiles = lib.mkMerge [
        {
          "config/kitty.conf" = {
            content = self.lib.convertDagOfStrToLines config.kittyConf;
            relPath = "config/kitty.conf";
          };
        }
        (self.lib.filesToConstruct pkgs {parentDir = "config";} config.extraConfigFiles)
      ];

      envDefault."KITTY_CONFIG_DIRECTORY" = "${
        self.lib.potentiallyWritableShellInline (placeholder config.outputName)
      }/config";

      kittyConf = {
        environmentVariables = lib.pipe config.environmentVariables [
          (lib.generators.toKeyValue {
            mkKeyValue = k: v: "env ${k}=${toString v}";
          })
          wlib.dag.entryAnywhere
        ];

        settings = lib.pipe config.settings [
          self.lib.toKittyAssignments
          (wlib.dag.entryAfter ["environmentVariables"])
        ];

        keybindings = lib.pipe config.keybindings [
          (lib.generators.toKeyValue {
            mkKeyValue = k: v: "map ${k} ${v}";
          })
          (wlib.dag.entryAfter ["settings"])
        ];

        mouseBindings = lib.pipe config.mouseBindings [
          (lib.generators.toKeyValue {
            mkKeyValue = k: v: "mouse_map ${k} ${v}";
          })
          (wlib.dag.entryAfter ["keybindings"])
        ];
      };

      package = lib.mkDefault pkgs.kitty;
    };
  };

  flake.wrapperIntegrationModules.kitty = {config, ...}: {
    kitty.environmentVariables =
      lib.mkIf (config.preferences or {} != {})
      config.preferences.environmentVariables;
  };
}
