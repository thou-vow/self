{
  lib,
  inputs,
  ...
}: {
  flake.nixosModules."extra.determinate-nix" = {
    config,
    inputs',
    ...
  }: {
    imports = [inputs.determinate.nixosModules.default];

    options.custom.extra.determinate-nix = {
      enable = lib.mkEnableOption "Determinate Nix";
      package =
        lib.mkPackageOption inputs'.determinate-nix.packages "Determinate Nix" {default = "default";};
    };

    config = let
      cfg = config.custom.extra.determinate-nix;
    in
      lib.mkMerge [
        {
          determinate.enable = cfg.enable;
        }
        (lib.mkIf cfg.enable {
          environment.variables.DETSYS_IDS_TELEMETRY = "disabled";

          nix.package = lib.mkOverride 75 cfg.package;
        })
      ];
  };
}
