{
  lib,
  inputs,
  ...
}: {
  flake = {
    nixOnDroidModules.state = {
      options.ext.state = {
        flakePath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The absolute path of this flake.";
          default = null;
        };
      };
    };

    nixosModules.state = {
      options.ext.state = {
        flakePath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The absolute path of this flake.";
          default = null;
        };
      };
    };
  };
}
