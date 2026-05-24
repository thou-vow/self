{
  lib,
  withSystem,
  wlib,
  ...
}:
lib.mkMerge [
  {
    flake.wrappers.prismlauncher.pkgsPerSystem = system: (withSystem system ({pkgs, ...}: pkgs));

    flake.wrappers.prismlauncher.module = {
      config,
      pkgs,
      ...
    }: {
      imports = [
        wlib.modules.makeWrapper
      ];

      options.jdks = lib.mkOption {
        type = with lib.types; listOf package;
        default = [];
      };

      config = {
        package = lib.mkDefault pkgs.prismlauncher;

        overrides = [(pkg: pkg.override {inherit (config) jdks;})];
      };
    };
  }

  {
    flake.wrappers.prismlauncher.module = {
      inputs',
      pkgs,
      ...
    }: {
      jdks =
        (with pkgs; [
          # graalvmPackages.graalvm-oracle_17
          jdk8
          jdk17
          jdk21
        ])
        ++ (with inputs'.nix-packages.packages; [
          graalvm-oracle_21
          graalvm-oracle_25
        ]);
    };
  }
]
