{
  lib,
  ...
}: let
  commonOptions = {
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = ''
        Configuration of atuin.
        See <https://docs.atuin.sh/configuration/config/> for the full list of options.
      '';
    };
  };
in {
  flake.wrappers.atuin.options = commonOptions;

  flake.nixosModules."wrappers.atuin".options.custom = {
    build.wrappers.atuin.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options.outPackage = lib.mkOption {type = lib.types.package;};
      });
      default = {};
    };

    wrappers.atuin.users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options =
          commonOptions
          // {
            inherit (commonOptions) settings;
            enable = lib.mkEnableOption "Atuin";
            daemon.enable = lib.mkEnableOption "Atuin daemon";
            initFlags = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
            };
          };
      });
      default = {};
    };
  };
}
