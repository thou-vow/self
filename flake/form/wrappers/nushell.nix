{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.nushell.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

  flake.wrappers.nushell.module = {
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
          (vars: "\nload-env ${self.lib.toNushell {} vars}\n")
          wlib.dag.entryAnywhere
          (lib.mkIf (config.environmentVariables != {}))
        ];

        settings = lib.pipe config.settings [
          (let
            flattenAttrs = prefix: attrs:
              lib.concatMapAttrs (
                name: value:
                  if builtins.isAttrs value
                  then flattenAttrs (prefix + name + ".") value
                  else {${prefix + name} = value;}
              )
              attrs;
          in
            flattenAttrs "")
          (lib.generators.toKeyValue {
            mkKeyValue = key: value: "$env.config.${key} = ${self.lib.toNushell {} value}";
          })
          wlib.dag.entryAnywhere
          (lib.mkIf (config.settings != {}))
        ];

        shellAliases = lib.pipe config.shellAliases [
          (lib.generators.toKeyValue {
            mkKeyValue = k: v: "alias ${builtins.toJSON k} = ${v}";
          })
          wlib.dag.entryAnywhere
          (lib.mkIf (config.shellAliases != {}))
        ];
      };

      flags = {
        "--config" = "${config.writeFiles.nushellConfig.location}/config.nu";
        "--plugin-config" =
          lib.mkIf (config.plugins != [])
          "${config.writeFiles.nushellConfig.location}/plugin.msgpackz";
      };

      package = lib.mkDefault pkgs.nushell;

      passthru.shellPath = config.wrapperPaths.relPath;

      writeFiles = {
        nushellConfig.entries = lib.mkMerge [
          {
            "config.nu" = lib.mkIf (config.configNu != {}) {
              subject.text =
                self.lib.convertDagOfStrToLines config.configNu;
            };

            "plugins.msgpackz" = lib.mkIf (config.plugins != []) {
              subject.source = let
                pluginCommands = lib.pipe config.plugins [
                  (map (plugin: "plugin add ${lib.getExe plugin}"))
                  (lib.concatStringsSep "; ")
                ];
              in
                pkgs.runCommand "nushell-plugin.msgpackz" {} ''
                  ${lib.getExe config.package} \
                    --plugins-config "$out" \
                    --commands '${pluginCommands}'
                '';
            };
          }
          config.extraConfigFiles
        ];
      };
    };
  };

  flake.wrappers.nushell.integrationModule = {config, ...}: let
    inherit (config.nushell) pkgs;
  in {
    nushell = {
      configNu = {
        atuinIntegration = lib.mkIf (config.atuin or {} != {}) (wlib.dag.entryAnywhere "\nsource ${
          pkgs.runCommand "atuin-init-nu.nu" {nativeBuildInputs = [pkgs.writableTmpDirAsHomeHook];}
          "${lib.getExe config.atuin.wrapper} init nu ${lib.escapeShellArgs config.atuin.initFlags} > $out"
        }\n");

        direnvIntegration = lib.mkIf (config.direnv or {} != {}) (wlib.dag.entryAfter ["static"]
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
          '');
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
