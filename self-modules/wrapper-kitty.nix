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
      self.wrapperModules.writeFiles
      wlib.modules.symlinkScript
    ];

    options = {
      environmentVariables = lib.mkOption {
        type = self.lib.types.environmentVariables;
        default = {};
      };
      extraConfigFiles = lib.mkOption {
        type = self.lib.types.files pkgs;
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
      envDefault."KITTY_CONFIG_DIRECTORY" =
        self.lib.potentiallyWritableShellInline config.writeFiles.kittyConfig.drv;

      kittyConf = {
        environmentVariables = lib.pipe config.environmentVariables [
          (lib.generators.toKeyValue {
            mkKeyValue = k: v: "env ${k}=${toString v}";
          })
          wlib.dag.entryAnywhere
        ];

        settings = lib.pipe config.settings [
          self.lib.toKittyConf
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

      writeFiles = {
        kittyConfig.entries = lib.mkMerge [
          {
            "kitty.conf".subject.text = self.lib.convertDagOfStrToLines config.kittyConf;
          }
          config.extraConfigFiles
        ];
      };
    };
  };

  flake.wrapperIntegrationModules.kitty = {config, ...}: {
    kitty.environmentVariables =
      lib.mkIf (config.preferences or {} != {})
      config.preferences.environmentVariables;
  };
}
