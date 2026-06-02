{
  lib,
  self,
  withSystem,
  wlib,
  ...
}: {
  flake.wrappers.prismlauncher.module = {
    config,
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
