{
  lib,
  withSystem,
  wlib,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.nh.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

    flake.wrappers.nh.module = {pkgs, ...}: {
      imports = [
        wlib.modules.makeWrapper
      ];

      package = lib.mkDefault pkgs.nh;
    };

    flake.wrappers.nh.nixosModule = {config, ...}: {
      wrappers.nh.envDefault = lib.mkIf (config.support.mapState.flakePath or null != null) {
        NH_FLAKE = config.support.mapState.flakePath;
      };
    };
  }

  {
    flake.wrappers.nh.module = {
      envDefault.NH_SHOW_ACTIVATION_LOGS = "1";
    };
  }
]
