{
  lib,
  self,
  ...
}: {
  flake.wrappers.fish = {
    module = lib.mkMerge [
      self.wrapperModules.core
      self.wrapperModules.eject

      ({
        config,
        pkgs,
        ...
      }: {
        options = {
          configFish = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          extraPaths = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption {type = lib.types.str;};
                path = lib.mkOption {type = lib.types.path;};
              };
            });
            default = [];
          };
          shellAbbrs = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
          };
          shellAliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
          };
          interactiveInitFish = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          loginInitFish = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          plugins = lib.mkOption {
            type = lib.types.attrsOf lib.types.path;
            default = {};
          };
          variables = lib.mkOption {
            type = with lib.types; attrsOf (oneOf [int float path str]);
            default = {};
          };
        };

        config = {
          configFish = let
            pluginsWithCompletions = lib.filterAttrs (_: p: builtins.pathExists "${p}/completions") config.plugins;
            pluginsWithFunctions = lib.filterAttrs (_: p: builtins.pathExists "${p}/functions") config.plugins;
            pluginsWithConf = lib.filterAttrs (_: p: builtins.pathExists "${p}/conf.d") config.plugins;
          in
            lib.mkMerge [
              (lib.mkOrder 100 ''
                set -q __fish_config_sourced; and exit
                set -g __fish_config_sourced 1
              '')
              (lib.pipe config.variables [
                (lib.generators.toKeyValue {
                  mkKeyValue = k: v: "set -gx ${k} ${lib.escapeShellArg v}";
                })
                (lib.mkOrder 510)
                (lib.mkIf (config.variables != {}))
              ])
              (lib.pipe pluginsWithCompletions [
                builtins.attrValues
                (map (p: "${p}/completions"))
                (lib.concatStringsSep " ")
                (s: "set -p fish_complete_path ${s}")
                (lib.mkOrder 520)
                (lib.mkIf (pluginsWithCompletions != []))
              ])
              (lib.pipe pluginsWithFunctions [
                builtins.attrValues
                (map (p: "${p}/functions"))
                (lib.concatStringsSep " ")
                (s: "set -p fish_function_path ${s}")
                (lib.mkOrder 530)
                (lib.mkIf (pluginsWithFunctions != []))
              ])
              (lib.pipe pluginsWithConf [
                builtins.attrValues
                (lib.concatStringsSep " ")
                (s: ''
                  for plugin_dir in ${s}
                    for f in $plugin_dir/conf.d/*.fish
                      source $f
                    end
                  end
                '')
                (lib.mkOrder 540)
                (lib.mkIf (pluginsWithConf != []))
              ])
              (lib.mkIf (config.loginInitFish != "")
                (lib.mkOrder 550 ''
                  status is-login; and begin
                    source (status dirname)/login-init.fish
                  end
                ''))
              (lib.mkIf (config.interactiveInitFish != "")
                (lib.mkOrder 560 ''
                  status is-interactive; and begin
                    source (status dirname)/interactive-init.fish
                  end
                ''))
            ];

          eject.entries.fishConfig = pkgs.linkFarm "fish-config" (
            self.lib.mkLinkFarmOptionalText (config.configFish != "") {
              inherit pkgs;
              name = "config.fish";
              text = config.configFish;
            }
            ++ self.lib.mkLinkFarmOptionalText (config.interactiveInitFish != "") {
              inherit pkgs;
              name = "interactive-init.fish";
              text = config.interactiveInitFish;
            }
            ++ self.lib.mkLinkFarmOptionalText (config.loginInitFish != "") {
              inherit pkgs;
              name = "login-init.fish";
              text = config.loginInitFish;
            }
            ++ config.extraPaths
          );

          filesToPatch = ["share/systemd/user/niri.service"];

          flags = {
            "--no-config" = true;
            "--init-command" = {
              sep = "=";
              data = [
                "source ${config.eject.directory}/${baseNameOf config.eject.entries.fishConfig}/config.fish"
              ];
            };
          };

          interactiveInitFish = lib.mkMerge [
            (lib.pipe config.shellAbbrs [
              (lib.generators.toKeyValue {
                mkKeyValue = k: v: "abbr --add ${k} ${lib.escapeShellArg v}";
              })
              (lib.mkOrder 510)
              (lib.mkIf (config.shellAbbrs != {}))
            ])
            (lib.pipe config.shellAliases [
              (lib.generators.toKeyValue {
                mkKeyValue = k: v: "alias ${k} ${lib.escapeShellArg v}";
              })
              (lib.mkOrder 520)
              (lib.mkIf (config.shellAliases != {}))
            ])
          ];

          package = lib.mkDefault pkgs.fish;

          passthru.shellPath = config.wrapperPaths.relPath;
        };
      })

      ({pkgs, ...}: {
        extraPackages = with pkgs; [eza pokeget-rs zoxide];

        extraPaths = [
          {
            name = "manual-interactive-init.fish";
            path = ./manual-interactive-init.fish;
          }
        ];

        interactiveInitFish = lib.mkMerge [
          ''
            ${lib.getExe pkgs.zoxide} init fish | source
          ''
          (lib.mkAfter ''
            source (status dirname)/manual-interactive-init.fish
          '')
        ];

        plugins = {inherit (pkgs.fishPlugins) autopair puffer;};

        shellAbbrs = {
          cd = "z";
          ci = "zi";
          e = "exit";
          la = "eza -a";
          ll = "eza -l";
          lla = "eza -la";
          ls = "eza";
          lt = "eza --tree";
        };
        shellAliases = {
          eza = "eza --group-directories-first --icons";
        };
      })
    ];

    integrationModule = lib.mkMerge [
      ({config, ...}: {
        fish.interactiveInitFish = lib.mkMerge [
          (lib.mkIf (config.atuin or {} != {}) ''
            ${lib.getExe config.atuin.wrapper} init fish ${lib.escapeShellArgs config.atuin.initFlags} | source
          '')
          (lib.mkIf (config.direnv or {} != {}) (lib.mkAfter ''
            ${lib.getExe config.direnv.wrapper} hook fish | source
          ''))
        ];
      })
    ];

    nixosUserModule = user: let
      namespace = ["custom" "users" user "wrappers"];
      mk = lib.setAttrByPath (namespace ++ ["fish"]);
    in
      lib.mkMerge [
        ({config, ...}: let
          cfg = lib.attrByPath (namespace ++ ["fish"]) {} config;
        in {
          options = mk {
            loadSystemEnvironment = lib.mkEnableOption "loading system environment";
          };

          config = mk {
            overrides = lib.mkIf cfg.loadSystemEnvironment [
              (pkg: pkg.override {fishEnvPreInit = source: source config.system.build.setEnvironment;})
              (pkg:
                pkg.overrideAttrs {
                  doCheck = false;
                })
            ];
          };
        })
      ];
  };
}
