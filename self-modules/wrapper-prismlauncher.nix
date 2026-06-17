{
  lib,
  wlib,
  ...
}: {
  flake.wrapperModules.prismlauncher = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      wlib.modules.makeWrapper
    ];

    options = {
      jdks = lib.mkOption {
        type = with lib.types; listOf package;
        default = [];
      };
    };

    config = {
      package = lib.mkDefault pkgs.prismlauncher;

      overrides = [(pkg: pkg.override {inherit (config) jdks;})];
    };
  };
}
