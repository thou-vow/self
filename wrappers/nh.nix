{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    ...
  }: {
    packages.nh = inputs.wrapper-modules.lib.wrapPackage {
      inherit pkgs;
      env.NH_SHOW_ACTIVATION_LOGS = "true";
      package = lib.mkDefault pkgs.nh;
    };
  };

  flake.nixosModules."wrappers.nh" = {
    config,
    self',
    ...
  }: {
    options.custom = {
      build.wrappers.nh.outPackage = lib.mkOption {type = lib.types.package;};

      wrappers.nh.enable = lib.mkEnableOption "nh";
    };

    config = let
      cfg = config.custom.wrappers.nh;
    in {
      custom.build.wrappers.nh.outPackage = lib.mkIf cfg.enable (let
        package = self'.packages.nh;
      in
        if config.custom.core.flakePath or null != null
        then package.wrap {env.NH_FLAKE = config.custom.core.flakePath;}
        else package);
    };
  };
}
