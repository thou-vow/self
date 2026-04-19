{
  lib,
  self,
  ...
}: let
  commonOptions = {
    jdks = lib.mkOption {
      type = with lib.types; listOf package;
      default = [];
    };
  };
in {
  flake.wrappers.prismlauncher = {
    config,
    pkgs,
    ...
  }: {
    imports = [self.wrapperModules.core];

    options = commonOptions;

    config = {
      package = lib.mkDefault pkgs.prismlauncher;

      overrides = [(pkg: pkg.override {inherit (config) jdks;})];
    };
  };

  perSystem = {pkgs, ...}: {
    packages.prismlauncher = self.wrappers.prismlauncher.wrap {
      inherit pkgs;
      jdks = with pkgs; [
        jdk8
        graalvmPackages.graalvm-oracle_17
        jdk21
        graalvmPackages.graalvm-oracle_25
      ];
    };
  };

  flake.nixosModules."wrappers.prismlauncher" = {
    config,
    self',
    ...
  }: {
    options.custom = {
      build.wrappers.prismlauncher.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options.outPackage = lib.mkOption {type = lib.types.package;};
        });
        default = {};
      };

      wrappers.prismlauncher.users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            inherit (commonOptions) jdks;
            enable = lib.mkEnableOption "Prismlauncher";
          };
        });
        default = {};
      };
    };

    config = let
      perUser = f:
        config.custom.wrappers.prismlauncher.users
        |> lib.mapAttrsToList f
        |> lib.mkMerge;
    in {
      custom.build.wrappers.prismlauncher.users = perUser (name: cfg:
        lib.mkIf cfg.enable {
          ${name}.outPackage = let
            package = self'.packages.prismlauncher;
          in
            package.wrap {jdks = lib.mkMerge [package.configuration.jdks cfg.jdks];};
        });

      users.users = perUser (name: cfg:
        lib.mkIf cfg.enable {
          ${name}.packages = [
            config.custom.build.wrappers.prismlauncher.users.${name}.outPackage
          ];
        });
    };
  };
}
