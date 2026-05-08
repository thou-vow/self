{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake = {
    nixOnDroidConfigurations.leia = self.lib.nixOnDroidConfiguration "aarch64-linux" {
      modules = [self.nixOnDroidModules.leia];
    };

    nixosConfigurations.u = self.lib.nixosSystem "x86_64-linux" {
      modules = [self.nixosModules.u];
    };
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [alejandra kdlfmt schemat taplo];
    };

    formatter = inputs.treefmt-nix.lib.mkWrapper pkgs {
      projectRootFile = "flake.nix";
      programs = {
        alejandra.enable = true;
        kdlfmt.enable = true;
        taplo.enable = true;
      };
      settings.formatter.schemat = {
        command = lib.getExe pkgs.bash;
        options = ["-euc" ''for file in "$@"; do ${lib.getExe pkgs.schemat} $file; done'' "--"];
        includes = ["*.scm"];
      };
    };

    packages = {
      all = self.lib.mkWrappersPackage system {
        inherit (self) wrappers;
        name = "all";
      };

      shell = self.lib.mkWrappersPackage system {
        name = "shell";
        wrappers = {inherit (self.wrappers) atuin direnv fish helix;};
      };
    };

    pkgs = let
      stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
      unstable = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      default = unstable;
      nixOnDroid = stable;
      nixos = unstable;
      wrappers = unstable;
    };
  };

  systems = lib.systems.flakeExposed;
}
