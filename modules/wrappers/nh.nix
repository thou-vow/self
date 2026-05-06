{
  lib,
  inputs,
  self,
  ...
}: {
  flake.wrappers.nh = {
    module = lib.mkMerge [
      self.wrapperModules.core

      ({pkgs, ...}: {
        package = lib.mkDefault pkgs.nh;
      })

      {
        env.NH_SHOW_ACTIVATION_LOGS = "true";
      }
    ];

    nixosModule = let
      namespace = ["custom" "wrappers"];
      mk = lib.setAttrByPath (namespace ++ ["nh"]);
    in
      lib.mkMerge [
        ({config, ...}: {
          config = mk {
            env = lib.mkIf (config.custom.flakePath or null != null) {
              NH_FLAKE = config.custom.flakePath;
            };
          };
        })
      ];
  };
}
