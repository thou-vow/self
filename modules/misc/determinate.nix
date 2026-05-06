{
  lib,
  inputs,
  ...
}: {
  flake.nixosModules.determinate = {
    config,
    inputs',
    ...
  }: {
    imports = [inputs.determinate.nixosModules.default];

    options.custom.extra.determinate = {
      package = lib.mkOption {
        type = lib.types.package;
        default = inputs'.determinate-nix.packages.default;
      };
    };

    config = {
      determinate.enable = true;

      environment.variables.DETSYS_IDS_TELEMETRY = "disabled";

      nix.package = lib.mkOverride 75 config.custom.extra.determinate.package;
    };
  };
}
