{
  lib,
  self,
  ...
}: {
  flake.wrappers.prismlauncher = {
    module = lib.mkMerge [
      self.wrapperModules.core
      
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

      ({
        inputs',
        pkgs,
        ...
      }: {
        jdks =
          (with pkgs; [
            graalvmPackages.graalvm-oracle_17
            jdk8
            jdk17
            jdk21
          ])
          ++ (with inputs'.nix-packages.packages; [
            graalvm-oracle_21
            graalvm-oracle_25
          ]);
      })
    ];
  };
}
