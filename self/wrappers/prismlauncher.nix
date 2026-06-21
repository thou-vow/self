{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.prismlauncher = {
    autoDiscoverModules = "prismlauncher";
    autoDiscoverPresets = "prismlauncher";
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
  };

  flake.wrapperPresets.prismlauncher = {
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
