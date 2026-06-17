{
  lib,
  wlib,
  ...
}: {
  flake.wrapperModules.nh = {pkgs, ...}: {
    imports = [
      wlib.modules.makeWrapper
    ];

    config = {
      package = lib.mkDefault pkgs.nh;
    };
  };

  flake.nixosModules.nh = {config, ...}: {
    wrappers.nh.envDefault = lib.mkIf (config.modules.mapState.flakePath or null != null) {
      NH_FLAKE = config.modules.mapState.flakePath;
    };
  };
}
