{
  self,
  withSystem,
  ...
}: {
  flake.wrappers.prismlauncher = {
    pkgsPerSystem = system: withSystem system ({pkgs, ...}: pkgs);
    module = self.wrapperModules.prismlauncher;
  };

  flake.wrapperModules.prismlauncher = {
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
