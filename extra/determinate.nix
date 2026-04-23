{
  lib,
  inputs,
  ...
}: {
  flake.nixosModules."extra.determinate" = {
    config,
    inputs',
    ...
  }: {
    imports = [inputs.determinate.nixosModules.default];

    options.custom.extra.determinate = {
      enable = lib.mkEnableOption "Determinate";
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs'.determinate-nix.packages.default;
      };
    };

    config = lib.mkMerge [
      {
        determinate.enable = config.custom.extra.determinate.enable;
      }
      (lib.mkIf config.custom.extra.determinate.enable {
        environment.variables.DETSYS_IDS_TELEMETRY = "disabled";

        nix.package = lib.mkOverride 75 config.custom.extra.determinate.package;
      })
    ];
  };
}
