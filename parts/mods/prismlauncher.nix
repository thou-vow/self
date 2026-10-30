{
  lib,
  self,
  ...
}: {
  flake.homeModules.prismlauncher = {
    config,
    inputs',
    pkgs,
    self',
    ...
  }: let
    cfg = config.self.mods.prismlauncher;
  in {
    options.self.mods.prismlauncher = {
      enable = self.lib.mkAutoEnableOption "Prismlauncher";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.prismlauncher;
        description = "The Prismlauncher package to use.";
      };
    };

    config = lib.mkIf cfg.enable {
      programs.prismlauncher = {
        inherit (cfg) enable;
        package = cfg.package.override {
          jdks =
            [
              self'.packages.graalvm-oracle_25i
            ]
            ++ (with pkgs; [
              jdk8
              jdk17
              jdk21
              semeru-jre-bin-8
              semeru-jre-bin-17
              semeru-jre-bin-21
            ])
            ++ (with inputs'.nix-packages.packages; [
              graalvm-oracle_21
              semeru-jre-bin-25
            ]);
        };
      };
    };
  };
}
