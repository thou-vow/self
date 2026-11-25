{
  lib,
  self,
  ...
}: {
  flake.homeModules.prismlauncher = {
    config,
    inputs',
    options,
    pkgs,
    self',
    ...
  }: let
    cfg = config.self.mods.prismlauncher;
  in {
    options.self.mods.prismlauncher = {
      inherit (options.programs.prismlauncher) package;
      enable = self.lib.mkAutoEnableOption options.programs.prismlauncher.enable;
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
