{
  lib,
  self,
  ...
}: {
  flake.wrapperIntegrationModules.preferences = {config, ...}: {
    options.preferences = lib.mkOption {
      type = lib.types.submodule {
        options = {
          apps = {
            browser = lib.mkOption {type = lib.types.nullOr lib.types.str;};
            editor = lib.mkOption {type = lib.types.nullOr lib.types.str;};
            shell = lib.mkOption {type = lib.types.nullOr lib.types.str;};
            terminal = lib.mkOption {type = lib.types.nullOr lib.types.str;};
          };
          environmentVariables = lib.mkOption {
            type = self.lib.types.environmentVariables;
            default = {};
          };
          shellAliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
          };
          style = {
            palette = lib.mkOption {
              type = lib.types.submodule {
                options =
                  lib.pipe [
                    "main-cursor"
                    "other-cursor"

                    "dark-background"
                    "background"
                    "other-highlight"
                    "main-highlight"
                    "other-selection"
                    "main-selection"
                    "invisible"
                    "comment"
                    "dark-foreground"
                    "foreground"

                    "red"
                    "yellow"
                    "green"
                    "cyan"
                    "blue"
                    "magenta"
                    "bright-red"
                    "bright-yellow"
                    "bright-green"
                    "bright-cyan"
                    "bright-blue"
                    "bright-magenta"

                    "escape"
                    "parameter"
                    "class"
                    "constant"
                    "function"
                    "keyword"
                    "boolean"
                    "string"
                    "number"
                    "variable"
                    "namespace"
                    "operator"
                    "path"
                  ] [
                    (map (name: {
                      inherit name;
                      value = lib.mkOption {type = lib.types.nullOr lib.types.str;};
                    }))
                    builtins.listToAttrs
                  ];
              };
            };
          };
        };
      };
    };

    config.preferences = sub: {
      environmentVariables = with sub.config; {
        BROWSER = lib.mkIf (apps.browser != null) apps.browser;
        EDITOR = lib.mkIf (apps.editor != null) apps.editor;
        SHELL = lib.mkIf (apps.shell != null) apps.shell;
        TERMINAL = lib.mkIf (apps.terminal != null) apps.terminal;
      };
    };
  };
}
