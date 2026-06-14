{
  lib,
  self,
  ...
}: {
  flake.wrapperIntegrationModules.preferences = {config, ...}: {
    options.preferences = {
      environmentVariables = lib.mkOption {
        type = self.lib.types.environmentVariables;
        default = {};
      };
      map = {
        browser = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
        };
        editor = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
        };
        shell = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
        };
        terminal = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
        };
      };
      shellAliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
      };
    };

    config.preferences = {
      environmentVariables = {
        BROWSER = config.preferences.map.browser;
        EDITOR = config.preferences.map.editor;
        SHELL = config.preferences.map.shell;
        TERMINAL = config.preferences.map.terminal;
      };
    };
  };
}
