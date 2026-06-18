{
  lib,
  self,
  ...
}: {
  flake.wrapperIntegrationModules.preferences = _: {
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
                    "orange"
                    "yellow"
                    "green"
                    "aqua"
                    "cyan"
                    "blue"
                    "violet"
                    "magenta"

                    "bright-red"
                    "bright-orange"
                    "bright-yellow"
                    "bright-green"
                    "bright-aqua"
                    "bright-cyan"
                    "bright-blue"
                    "bright-violet"
                    "bright-magenta"

                    "boolean"
                    "class"
                    "constant"
                    "escape"
                    "function"
                    "keyword"
                    "namespace"
                    "number"
                    "operator"
                    "parameter"
                    "path"
                    "string"
                    "variable"

                    "rainbow"
                  ] [
                    (map (name: {
                      inherit name;
                      value = lib.mkOption {
                        type = lib.types.nullOr (lib.types.oneOf [
                          lib.types.str
                          (lib.types.listOf lib.types.str)
                        ]);
                      };
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
