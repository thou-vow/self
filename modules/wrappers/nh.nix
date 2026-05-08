{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.nh = {
    module = lib.mkMerge [
      ({pkgs, ...}: {
        package = lib.mkDefault pkgs.nh;
      })

      {
        env.NH_SHOW_ACTIVATION_LOGS = "true";
      }
    ];

    nixosModule = let
      namespace = ["wrappers"];
      mk = lib.setAttrByPath (namespace ++ ["nh"]);
    in
      lib.mkMerge [
        ({config, ...}: {
          config = mk {
            env = lib.mkIf (config.ext.state.flakePath or null != null) {
              NH_FLAKE = config.ext.state.flakePath;
            };
          };
        })
      ];
  };
}
