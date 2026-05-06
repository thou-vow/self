{
  lib,
  inputs,
  ...
}: {
  flake = {
    nixOnDroid.state = {
      options.ext.state = {
        flakePath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The absolute path of this flake.";
        };
      };
    };

    nixosModules.state = {
      options.ext.state = {
        flakePath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          description = "The absolute path of this flake.";
        };
      };
    };
  };
}
