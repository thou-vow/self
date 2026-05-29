{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.nh.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

  flake.wrappers.nh.module = {pkgs, ...}: {
    imports = [
      wlib.modules.makeWrapper
    ];

    config = {
      package = lib.mkDefault pkgs.nh;
    };
  };

  flake.wrappers.nh.nixosModule = {config, ...}: {
    wrappers.nh.envDefault = lib.mkIf (config.modules.mapState.flakePath or null != null) {
      NH_FLAKE = config.modules.mapState.flakePath;
    };
  };
}
