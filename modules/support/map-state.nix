{lib, ...}: {
  flake.nixOnDroidModules.mapState = {config, ...}: {
    options.support.mapState = {
      flakePath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "The absolute path of this flake.";
        default = null;
      };
    };

    config = {
      nix.registry.self.to = lib.mkIf (config.support.mapState.flakePath or null != null) {
        type = "git";
        url = "file://${config.support.mapState.flakePath}";
      };
    };
  };

  flake.nixosModules.mapState = {config, ...}: {
    options.support.mapState = {
      flakePath = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "The absolute path of this flake.";
        default = null;
      };
    };

    config = {
      nix.registry.self.to = lib.mkIf (config.support.mapState.flakePath or null != null) {
        type = "git";
        url = "file://${config.support.mapState.flakePath}";
      };
    };
  };
}
