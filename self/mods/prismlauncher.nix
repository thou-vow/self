{
  lib,
  self,
  ...
}: {
  flake.homeModules.prismlauncher = {
    config,
    inputs',
    pkgs,
    ...
  }: let
    cfg = config.self.mods.prismlauncher;
  in {
    options.self.mods.prismlauncher = {
      enable = self.lib.mkAutoEnableOption "Prismlauncher";
    };

    config = lib.mkIf cfg.enable {
      programs.prismlauncher = {
        inherit (cfg) enable;
        package = pkgs.prismlauncher.override {
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
      };
    };
  };
}
