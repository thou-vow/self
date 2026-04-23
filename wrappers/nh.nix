{
  inputs,
  lib,
  self,
  ...
}: {
  flake .wrappers.nh.imports = [
    # Support
    self.wrapperModules.core

    # Schema
    ({pkgs, ...}: {
      package = lib.mkDefault pkgs.nh;
    })

    # Base defaults
    {
      env.NH_SHOW_ACTIVATION_LOGS = "true";
    }
  ];

  flake.nixosModules."wrappers.nh".imports = [
    # Support
    (inputs.wrapper-modules.lib.mkInstallModule {
      name = "nh";
     optloc = ["custom" "wrappers"];
      loc = ["environment" "systemPackages"];
      value = self.wrapperModules.nh;
    })

    # Schema
    ({config, ...}: {
      custom.wrappers.nh.env = lib.mkIf (config.custom.system.core.flakePath or null != null) {
        NH_FLAKE = config.custom.system.core.flakePath;
      };
    })
  ];
}
