{
  inputs,
  lib,
  self,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.nushell = {
      module = {
        config,
        pkgs,
        ...
      }: {
        imports = [self.wrapperModules.writeFiles];

        options = {
          configNu = lib.mkOption {
            type = self.lib.dagLinesType;
            default = "";
          };
          environmentVariables = lib.mkOption {
            type = lib.types.attrsOf self.lib.nushellValueType;
            default = {};
          };
          extraConfigFiles = lib.mkOption {
            type = self.lib.filesType pkgs;
            default = {};
          };
          settings = lib.mkOption {
            type = lib.types.attrsOf self.lib.nushellValueType;
            default = {};
          };
          shellAliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
          };
        };

        config = {
          configNu = lib.mkMerge [
            (self.lib.mkNamedEntryBetween "STATIC" [] []
              # nu
              ''
                const NU_PLUGIN_DIRS = [($nu.config-path | path dirname | path join 'plugins')]

                $env.ENV_CONVERSIONS = $env.ENV_CONVERSIONS | merge {
                  PATH: {
                    from_string: {|s| $s | split row (char esep) | path expand --no-symlink }
                    to_string: {|v| $v | path expand --no-symlink | str join (char esep) }
                  }
                }
              '')
            (lib.pipe config.environmentVariables [
              (vars: "load-env ${self.lib.toNushell {} vars}")
              (self.lib.mkNamedEntryBetween "VARIABLES" [] ["STATIC"])
              (lib.mkIf (config.environmentVariables != {}))
            ])
            (lib.pipe config.settings [
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
                mkKeyValue = key: value: ''
                  $env.config.${key} = ${self.lib.toNushell {} value}
                '';
              })
              (self.lib.mkNamedEntryBetween "SETTINGS" [] ["VARIABLES"])
              (lib.mkIf (config.settings != {}))
            ])
            (lib.pipe config.shellAliases [
              (lib.generators.toKeyValue {
                mkKeyValue = k: v: "alias ${builtins.toJSON k} = ${v}";
              })
              (self.lib.mkNamedEntryBetween "ALIASES" ["DEFAULT"] ["SETTINGS"])
              (lib.mkIf (config.shellAliases != {}))
            ])
          ];

          flags = {
            "--config" = "${config.writeFiles.nushellConfig.location}/config.nu";
          };

          package = lib.mkDefault pkgs.nushell;

          passthru.shellPath = config.wrapperPaths.relPath;

          writeFiles.nushellConfig = {
            eject.enable = true;
            entries = lib.mkMerge [
              {
                "config.nu".subject.text = config.configNu;
                "plugins".subject.emptyDir = true;
              }
              config.extraConfigFiles
            ];
          };
        };
      };

      integrationModule = {
        config,
        pkgs,
        ...
      }: {
        nushell.configNu = lib.mkMerge [
          (lib.mkIf (config.atuin or {} != {}) ''
            source ${
              pkgs.runCommand "atuin-init-nu.nu" {nativeBuildInputs = [pkgs.writableTmpDirAsHomeHook];} ''
                ${lib.getExe config.atuin.wrapper} init nu ${lib.escapeShellArgs config.atuin.initFlags} > $out
              ''
            }
          '')
          (lib.mkIf (config.direnv or {} != {}) (self.lib.mkEntryAfter ["DEFAULT"]
            # nu
            ''
              $env.config.hooks.pre_prompt = $env.config.hooks.pre_prompt | append {||
                let exports = ${lib.getExe config.direnv.wrapper} export json
                | from json --strict
                | default {}
                if ($exports | is-empty) { return }

                load-env $exports
              }
            ''))
        ];
      };
    };
  }

  {
    flake.wrappers.nushell = {
      module = {
        config,
        pkgs,
        ...
      }: {
        configNu = lib.mkMerge [
          (self.lib.mkEntryBefore ["ALIASES"] ''
            source ${pkgs.runCommand "zoxide-init-nushell.nu" {} ''
              ${lib.getExe pkgs.zoxide} init nushell > $out
            ''}
          '')
          ''
            source ${pkgs.runCommand "carapace-nushell.nu" {} ''
              ${lib.getExe pkgs.carapace} _carapace nushell | sed 's|"/homeless-shelter|$"($env.HOME)|g' > $out
            ''}
          ''
          (self.lib.mkEntryAfter ["DEFAULT"] ''
            source ($nu.config-path | path dirname | path join 'manual-config.nu')
          '')
        ];
        extraConfigFiles = {
          "manual-config.nu".subject.source = ./manual-config.nu;
        };
        extraPackages = with pkgs; [carapace pokeget-rs zoxide];
        shellAliases = {
          "cd" = "z";
          "ci" = "zi";
          "e" = "exit";
        };
      };
    };
  }
]
