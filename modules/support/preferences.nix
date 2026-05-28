{
  lib,
  self,
  wlib,
  ...
}: {
  flake.wrapperIntegrationModules.preferences = {
    options.preferences = {
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
    };
  };
}
