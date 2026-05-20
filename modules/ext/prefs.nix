{
  lib,
  inputs,
  ...
}: {
  flake.nixosUserModules.prefs = user: {
    options.ext.users.${user} = lib.mkOption {
      type = lib.types.submodule {
        options.prefs = {
          environmentVariables = lib.mkOption {
            type = with lib.types; attrsOf (oneOf [int float path str]);
            default = {};
          };
          shellAliases = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = {};
          };
        };
      };
      default = {};
    };
  };
}
