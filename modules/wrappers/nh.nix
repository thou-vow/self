{
  inputs,
  lib,
  self,
  withSystem,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.nh = {
      pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

      module = {pkgs, ...}: {
        package = lib.mkDefault pkgs.nh;
      };

      nixosModule = {config, ...}: let
        namespace = ["wrappers"];
        mk = lib.setAttrByPath (namespace ++ ["nh"]);
      in {
        config = mk {
          env = lib.mkIf (config.ext.state.flakePath or null != null) {
            NH_FLAKE = config.ext.state.flakePath;
          };
        };
      };
    };
  }

  {
    flake.wrappers.nh = {
      module = {
        envDefault.NH_SHOW_ACTIVATION_LOGS = "true";
      };
    };
  }
]
