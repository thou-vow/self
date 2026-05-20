{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.nushell.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

    flake.wrappers.nushell.module = {
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
          (self.lib.mkNamedEntryBetween [] "STATIC" []
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
            (vars: "\nload-env ${self.lib.toNushell {} vars}\n")
            (self.lib.mkNamedEntryBetween ["STATIC"] "VARIABLES" [])
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
              mkKeyValue = key: value: "$env.config.${key} = ${self.lib.toNushell {} value}";
            })
            (self.lib.mkNamedEntryBetween ["VARIABLES"] "SETTINGS" [])
            (lib.mkIf (config.settings != {}))
          ])

          (lib.pipe config.shellAliases [
            (lib.generators.toKeyValue {
              mkKeyValue = k: v: "alias ${builtins.toJSON k} = ${v}";
            })
            (self.lib.mkNamedEntryBetween ["SETTINGS"] "ALIASES" ["DEFAULT"])
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

    flake.wrappers.nushell.integrationModule = {config, ...}: let
      inherit (config.nushell) pkgs;
    in {
      nushell.configNu = lib.mkMerge [
        (let
          atuin-init-nu =
            pkgs.runCommand "atuin-init-nu.nu" {nativeBuildInputs = [pkgs.writableTmpDirAsHomeHook];}
            "${lib.getExe config.atuin.wrapper} init nu ${lib.escapeShellArgs config.atuin.initFlags} > $out";
        in
          lib.mkIf (config.atuin or {} != {}) "\nsource ${atuin-init-nu}\n")

        (lib.mkIf (config.direnv or {} != {}) (self.lib.mkEntryBetween ["DEFAULT"] []
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
          ''))
      ];
    };
  }

  {
    flake.wrappers.nushell.module = {
      config,
      pkgs,
      ...
    }: {
      configNu = lib.mkMerge [
        (self.lib.mkEntryBetween [] ["ALIASES"] (let
          zoxide-init-nushell =
            pkgs.runCommand "zoxide-init-nushell.nu" {}
            "${lib.getExe pkgs.zoxide} init nushell > $out";
        in "\nsource ${zoxide-init-nushell}\n"))

        (self.lib.mkEntryBetween ["SETTINGS"] ["DEFAULT"]
          # nu
          ''
            let carapace_completer = {|spans|
              load-env {
               	CARAPACE_SHELL_BUILTINS:
               	  (help commands | where category != "" | get name | each { split row " " | first } | uniq  | str join "\n")
               	CARAPACE_SHELL_FUNCTIONS:
                 	(help commands | where category == "" | get name | each { split row " " | first } | uniq  | str join "\n")
              }
              CARAPACE_LENIENT=1 carapace $spans.0 nushell ...$spans | from json
            }

            $env.config.completions.external.enable = true
            $env.config.completions.external.completer = {|spans|
              let expanded_alias = scope aliases | where name == $spans.0 | $in.0?.expansion?

              let spans = if $expanded_alias != null {
                $spans | skip 1 | prepend ($expanded_alias | split row ' ' | take 1)
              } else { $spans }

              match $spans.0 {
                _ => $carapace_completer
              } | do $in $spans
            }
            $env.config.completions.external.max_results = 9
          '')

        (self.lib.mkEntryBetween ["DEFAULT"] []
          "\nsource ($nu.config-path | path dirname | path join 'manual-config.nu')\n")
      ];
      extraConfigFiles = {
        "manual-config.nu".subject.source = ./manual-config.nu;
      };
      runtimePkgs = with pkgs; [carapace pokeget-rs zoxide];
      settings = {
        auto_cd_implicit = true;
        completions.algorithm = "fuzzy";
        rm.always_trash = true;
      };
      shellAliases = {
        "cd" = "z";
        "ci" = "zi";
        "e" = "exit";
      };
    };
  }
]
