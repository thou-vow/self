{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.nh.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

    flake.wrappers.nh.module = {pkgs, ...}: {
      package = lib.mkDefault pkgs.nh;
    };

    flake.wrappers.nh.nixosModule = {config, ...}: {
      wrappers.nh.envDefault = lib.mkIf (config.ext.state.flakePath or null != null) {
        NH_FLAKE = config.ext.state.flakePath;
      };
    };
  }

  {
    flake.wrappers.nh.module = {
      envDefault.NH_SHOW_ACTIVATION_LOGS = "1";
    };
  }
]
