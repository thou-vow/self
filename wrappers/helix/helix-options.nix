{lib, ...}: let
  commonOptions.steel = {
    cogs = lib.mkOption {
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
    initScm = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    helixScm = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
  };
in {
  flake.wrappers.helix.options.custom = commonOptions;

  flake.nixosModules."wrappers.helix" = {self', ...}: {
    options.custom = {
      build.wrappers.helix.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.outPackage = lib.mkOption {type = lib.types.package;};
        });
        default = {};
      };

      wrappers.helix.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options =
            commonOptions
            // {
              enable = lib.mkEnableOption "helix";
              package = lib.mkOption {
                type = lib.types.package;
                default = self'.packages.helix.configuration.package;
              };
            };
        });
        default = {};
      };
    };
  };
}
