{lib, ...}: let
  commonOptions = {
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
    shellAbbrs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
    shellAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
    };
    interactiveInitFish = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    loginInitFish = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };
    plugins = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
    };
    variables = lib.mkOption {
      type = with lib.types; attrsOf (oneOf [int float path str]);
      default = {};
    };
  };
in {
  flake.wrappers.fish.options = commonOptions;

  flake.nixosModules."wrappers.fish".options.custom = {
    build.wrappers.fish.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.outPackage = lib.mkOption {type = lib.types.package;};
      });
      default = {};
    };

    wrappers.fish.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options =
          commonOptions
          // {
            enable = lib.mkEnableOption "fish";
            loadSystemEnvironment = lib.mkOption {
              type = lib.types.bool;
              default = false;
            };
          };
      });
      default = {};
    };
  };
}
