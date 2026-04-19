{
  lib,
  self,
  ...
}: {
  flake.wrappers.fish = {
    config,
    pkgs,
    ...
  }: {
    imports = [self.wrapperModules.core];

    core.eject.entries.fishConfig = let
      configFish = pkgs.writeTextFile {
        name = "config.fish";
        text = let
          pluginsWithCompletions = builtins.filter (p: builtins.pathExists "${p.src}/completions") config.plugins;
          pluginsWithFunctions = builtins.filter (p: builtins.pathExists "${p.src}/functions") config.plugins;
          pluginsWithConf = builtins.filter (p: builtins.pathExists "${p.src}/conf.d") config.plugins;

          variablesStr =
            config.variables
            |> lib.mapAttrsToList (k: v: "set -gx ${k} ${lib.escapeShellArg v}")
            |> builtins.concatStringsSep "\n";

          setFishCompletionsStr = lib.optionalString (pluginsWithCompletions != []) ''
            set -p fish_complete_path ${lib.concatStringsSep " " (map (p: "${p.src}/completions") pluginsWithCompletions)}
          '';
          setFishFunctionsStr = lib.optionalString (pluginsWithFunctions != []) ''
            set -p fish_function_path ${lib.concatStringsSep " " (map (p: "${p.src}/functions") pluginsWithFunctions)}
          '';
          sourceFishConfsStr = lib.optionalString (pluginsWithConf != []) ''
            for plugin_dir in ${lib.concatStringsSep " " (map (p: p.src) pluginsWithConf)}
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

  perSystem = {pkgs, ...}: {
    packages.fish = self.wrappers.fish.wrap {
      inherit pkgs;
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
      plugins = with pkgs.fishPlugins; [autopair puffer];
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
    };
  };

  flake.nixosModules."wrappers.fish" = {
    config,
    self',
    ...
  }: let
    perUser = f:
      config.custom.wrappers.fish.users
      |> lib.mapAttrsToList f
      |> lib.mkMerge;
  in {
    custom.build.wrappers.fish.users = perUser (name: cfg: {
      ${name}.outPackage = let
        package = self'.packages.fish;
      in
        package.wrap {
          interactiveInitFish = lib.mkMerge [
            package.configuration.interactiveInitFish
            (lib.mkIf (config.custom.wrappers.atuin.users.${name}.enable or false != false) ''
              ${
                lib.getExe config.custom.build.wrappers.atuin.users.${name}.outPackage
              } init fish ${
                lib.escapeShellArgs config.custom.wrappers.atuin.users.${name}.initFlags
              } | source
            '')
            cfg.interactiveInitFish
          ];
          loginInitFish = lib.mkMerge [package.configuration.loginInitFish cfg.loginInitFish];
          shellAbbrs = lib.mkMerge [package.configuration.shellAbbrs cfg.shellAbbrs];
          shellAliases = lib.mkMerge [package.configuration.shellAliases cfg.shellAliases];
          overrides = lib.mkIf cfg.loadSystemEnvironment [
            (pkg: pkg.override {fishEnvPreInit = source: source config.system.build.setEnvironment;})
          ];
          plugins = lib.mkMerge [package.configuration.plugins cfg.plugins];
          variables = lib.mkMerge [package.configuration.variables cfg.variables];
        };
    });

    users.users = perUser (name: cfg:
      lib.mkIf cfg.enable {
        ${name}.packages = [config.custom.build.wrappers.fish.users.${name}.outPackage];
      });
  };
}
