{lib, ...}: let
  commonOptions = {
    configKdl = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    extraPaths = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
          };
          path = lib.mkOption {
            type = lib.types.path;
          };
        };
      });
      default = [];
    };
  };
in {
  flake.wrappers.niri = {inputs', ...}: {
    options =
      commonOptions
      // {
        xwayland-satellite.package = lib.mkOption {
          type = lib.types.package;
          default = inputs'.niri-flake.packages.xwayland-satellite-unstable;
        };
      };
  };

  flake.nixosModules."wrappers.niri" = {self', ...}: {
    options.custom = {
      build.wrappers.niri.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.outPackage = lib.mkOption {type = lib.types.package;};
        });
        default = {};
      };

      wrappers.niri.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options =
            commonOptions
            // {
              enable = lib.mkEnableOption "niri";
              package = lib.mkOption {
                type = lib.types.package;
                default = self'.packages.niri.configuration.package;
              };
              xwayland-satellite.package = lib.mkOption {
                type = lib.types.package;
                default = self'.packages.niri.configuration.xwayland-satellite.package;
              };
            };
        });
        default = {};
      };
    };
  };
}
