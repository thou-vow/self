{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.fish.imports = [
    # Support
    self.wrapperModules.core

    # Schema
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
          default = [];
        };
        variables = lib.mkOption {
          type = with lib.types; attrsOf (oneOf [int float path str]);
          default = {};
        };
      };

      config = {
        core.eject.entries.fishConfig = let
          configFish = pkgs.writeTextFile {
            name = "config.fish";
            text = let
              pluginsWithCompletions = lib.filterAttrs (_: p: builtins.pathExists "${p.src}/completions") config.plugins;
              pluginsWithFunctions = lib.filterAttrs (_: p: builtins.pathExists "${p.src}/functions") config.plugins;
              pluginsWithConf = lib.filterAttrs (_: p: builtins.pathExists "${p.src}/conf.d") config.plugins;

              variablesStr =
                config.variables
                |> lib.mapAttrsToList (k: v: "set -gx ${k} ${lib.escapeShellArg v}")
                |> builtins.concatStringsSep "\n";

              setFishCompletionsStr = lib.optionalString (pluginsWithCompletions != []) ''
                set -p fish_complete_path ${lib.concatStringsSep " " (map (p: "${p.src}/completions") (builtins.attrValues pluginsWithCompletions))}
              '';
              setFishFunctionsStr = lib.optionalString (pluginsWithFunctions != []) ''
                set -p fish_function_path ${lib.concatStringsSep " " (map (p: "${p.src}/functions") (builtins.attrValues pluginsWithFunctions))}
              '';
              sourceFishConfsStr = lib.optionalString (pluginsWithConf != []) ''
                for plugin_dir in ${lib.concatStringsSep " " (map (p: p.src) (builtins.attrValues pluginsWithConf))}
                  for f in $plugin_dir/conf.d/*.fish
                    source $f
                  end
                end
              '';
            in
              # fish
              ''
                set -q __fish_config_sourced; and exit
                set -g __fish_config_sourced 1

                ${variablesStr}

                ${setFishCompletionsStr}
                ${setFishFunctionsStr}
                ${sourceFishConfsStr}

                status is-login; and begin
                  source (status dirname)/login-init.fish
                end

                status is-interactive; and begin
                  source (status dirname)/interactive-init.fish
                end
              '';
          };

          interactiveInitFish = pkgs.writeTextFile {
            name = "interactive-init.fish";
            text = let
              abbrsStr =
                config.shellAbbrs
                |> lib.mapAttrsToList (k: v: "abbr --add ${k} ${lib.escapeShellArg v}")
                |> builtins.concatStringsSep "\n";
              aliasesStr =
                config.shellAliases
                |> lib.mapAttrsToList (k: v: "alias ${k} ${lib.escapeShellArg v}")
                |> builtins.concatStringsSep "\n";
            in
              # fish
              ''
                ${abbrsStr}
                ${aliasesStr}

                ${config.interactiveInitFish}
              '';
          };

          loginInitFish = pkgs.writeTextFile {
            name = "login-init.fish";
            text =
              # fish
              ''
                ${config.loginInitFish}
              '';
          };
        in
          pkgs.linkFarm "fish-config" ([
              {
                inherit (configFish) name;
                path = configFish;
              }
              {
                inherit (interactiveInitFish) name;
                path = interactiveInitFish;
              }
              {
                inherit (loginInitFish) name;
                path = loginInitFish;
              }
            ]
            ++ config.extraPaths);

        flags = {
          "--no-config" = true;
          "--init-command" = {
            sep = "=";
            data = [
              "source ${config.core.eject.directory}/${baseNameOf config.core.eject.entries.fishConfig}/config.fish"
            ];
          };
        };

        package = lib.mkDefault pkgs.fish;

        passthru.shellPath = config.wrapperPaths.relPath;
      };
    })

    # Base defaults
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

  flake.nixosModules."wrappers.fish".imports = [
    # Support
    ({config, ...}: {
      options.custom.users = let
        subImports = [
          # Support
          (inputs.wrapper-modules.lib.mkInstallModule {
            name = "fish";
            optloc = ["wrappers"];
            loc = ["core" "packages"];
            value = self.wrapperModules.fish;
          })

          # Schema
          (sub: {
            options.wrappers.fish.loadSystemEnvironment = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };

            config.wrappers.fish = {
              interactiveInitFish = lib.mkIf sub.config.wrappers.atuin.enable ''
                ${
                  lib.getExe sub.config.wrappers.atuin.wrapper
                } init fish ${
                  lib.escapeShellArgs sub.config.wrappers.atuin.initFlags
                } | source
              '';

              overrides = lib.mkIf sub.config.wrappers.fish.loadSystemEnvironment [
                (pkg: pkg.override {fishEnvPreInit = source: source config.system.build.setEnvironment;})
              ];
            };
          })
        ];
      in
        lib.mkOption {type = lib.types.attrsOf (lib.types.submodule {imports = subImports;});};
    })
  ];
}
