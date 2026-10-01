{
  lib,
  self,
  ...
}: let
  option = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        enable = self.lib.mkAutoEnableOption "dev environment";
        packages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
        };
      };
    });
    default = {};
  };
in {
  flake.homeModules.dev = {
    config,
    pkgs,
    ...
  }: {
    options.self.dev = option;

    config = {
      home.packages =
        lib.mapAttrsToList (k: v: (self.lib.mkShellEnv pkgs "dev-${k}" {
          inherit (v) packages;
        }))
        config.self.dev;
    };
  };
}
