{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperModules.nushell = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.wrapperModules.writeFiles
    ];

    options = {
      configNu = lib.mkOption {
        type = wlib.types.dagOf lib.types.str;
        default = {};
      };
      environmentVariables = lib.mkOption {
        type = lib.types.attrsOf self.lib.types.nushellValue;
        default = {};
      };
      extraConfigFiles = lib.mkOption {
        type = self.lib.types.files pkgs;
        default = {};
      };
      plugins = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf self.lib.types.nushellValue;
        default = {};
      };
      shellAliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
      };
    };

    config = {
      configNu = {
        static =
          wlib.dag.entryBefore ["environmentVariables"]
          # nu
          ''
            const NU_PLUGIN_DIRS = [($nu.config-path | path dirname | path join 'plugins')]

            $env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
              PATH: {
                from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
              }
              XDG_DATA_DIRS: {
                from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
              }
            }
          '';

        environmentVariables = lib.pipe config.environmentVariables [
          (vars: "\nload-env ${self.lib.toNushell vars}\n")
          wlib.dag.entryAnywhere
        ];

        settings = lib.pipe config.settings [
          (s: {env.config = s;})
          self.lib.toNushellAssignments
          wlib.dag.entryAnywhere
        ];

        shellAliases = lib.pipe config.shellAliases [
          (lib.generators.toKeyValue {
            mkKeyValue = k: v: "alias ${builtins.toJSON k} = ${v}";
          })
          wlib.dag.entryAnywhere
        ];
      };

      flags = {
        "--config" = "${self.lib.potentiallyWritableShellInline config.writeFiles.nushellConfig.drv}/config.nu";
        "--plugin-config" = "${self.lib.potentiallyWritableShellInline config.writeFiles.nushellConfig.drv}/plugin.msgpackz";
      };

      package = lib.mkDefault pkgs.nushell;

      passthru.shellPath = config.wrapperPaths.relPath;

      writeFiles = {
        nushellConfig.entries = lib.mkMerge [
          {
            "config.nu".subject.text = self.lib.convertDagOfStrToLines config.configNu;
            "plugins.msgpackz".subject.source = let
              pluginCommands = lib.pipe config.plugins [
                (map (plugin: "plugin add ${lib.getExe plugin}"))
                (lib.concatStringsSep "; ")
              ];
              msgPackzDir = pkgs.runCommand "nushell-plugin-msgpackz-dir" {} ''
                mkdir -p $out
                ${lib.getExe config.package} \
                  --plugin-config "$out/plugin.msgpackz" \
                  --commands '${pluginCommands}'
              '';
            in "${msgPackzDir}/plugin.msgpackz";
          }
          config.extraConfigFiles
        ];
      };
    };
  };

  flake.wrapperIntegrationModules.nushell = {config, ...}: let
    inherit (config.nushell) pkgs;
  in {
    nushell = {
      configNu = {
        atuinIntegration = lib.mkIf (config.atuin or {} != {}) (
          wlib.dag.entryAnywhere ''
            source ${
              pkgs.runCommand "atuin-init-nu.nu" {nativeBuildInputs = [pkgs.writableTmpDirAsHomeHook];}
              "${lib.getExe config.atuin.package} init nu ${lib.escapeShellArgs config.atuin.initFlags} > $out"
            }
          ''
        );

        direnvIntegration = lib.mkIf (config.direnv or {} != {}) (
          wlib.dag.entryAfter ["static"]
          # nu
          ''
            $env.config.hooks.pre_prompt ++= [{||
              let exports = ${lib.getExe config.direnv.wrapper} export json
              | from json --strict
              | default {}
              if ($exports | is-empty) { return }

              load-env $exports
              $env.PATH = do $env.ENV_CONVERSIONS.PATH.from_string $env.PATH
            }]
          ''
        );

        starshipIntegration = lib.mkIf (config.starship or {} != {}) (
          wlib.dag.entryAnywhere ''
            use ${
              pkgs.runCommand "starship-init-nu.nu" {}
              ''
                ${lib.getExe config.starship.package} init nu > $out

                substituteInPlace $out \
                  --replace ${lib.getExe config.starship.package} ${lib.getExe config.starship.wrapper}
              ''
            }
          ''
        );
      };

      environmentVariables =
        lib.mkIf (config.preferences or {} != {})
        config.preferences.environmentVariables;

      shellAliases =
        lib.mkIf (config.preferences or {} != {})
        config.preferences.shellAliases;
    };
  };
}
