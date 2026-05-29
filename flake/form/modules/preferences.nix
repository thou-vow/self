{
  lib,
  self,
  wlib,
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
        BROWSER = lib.mkIf (config.preferences.map.browser != null) config.preferences.map.browser;
        EDITOR = lib.mkIf (config.preferences.map.editor != null) config.preferences.map.editor;
        SHELL = lib.mkIf (config.preferences.map.shell != null) config.preferences.map.shell;
        TERMINAL = lib.mkIf (config.preferences.map.terminal != null) config.preferences.map.terminal;
      };
    };
  };
}
