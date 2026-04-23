{
  inputs,
  lib,
  self,
  ...
}: {
  flake.wrappers.prismlauncher.imports = [
    # Support
    self.wrapperModules.core

    # Schema
    ({
      config,
      pkgs,
      ...
    }: {
      options.jdks = lib.mkOption {
        type = with lib.types; listOf package;
        default = [];
      };

      config = {
        package = lib.mkDefault pkgs.prismlauncher;

        overrides = [(pkg: pkg.override {inherit (config) jdks;})];
      };
    })

    # Base defaults
    ({pkgs, ...}: {
      jdks = with pkgs; [
        jdk8
        graalvmPackages.graalvm-oracle_17
        jdk21
        graalvmPackages.graalvm-oracle_25
      ];
    })
  ];

  flake.nixosModules."wrappers.prismlauncher".imports = [
    # Support
    {
      options.custom.users = let
        subImports = [
          # Support
          (inputs.wrapper-modules.lib.mkInstallModule {
            name = "prismlauncher";
            optloc = ["wrappers"];
            loc = ["core" "packages"];
            value = self.wrapperModules.prismlauncher;
          })
        ];
      in
        lib.mkOption {type = lib.types.attrsOf (lib.types.submodule {imports = subImports;});};
    }
  ];
}
