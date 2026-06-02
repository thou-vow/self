{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.prismlauncher.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

  flake.wrappers.prismlauncher.module = {
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
