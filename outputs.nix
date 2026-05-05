{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake = {
    nixOnDroidConfigurations.leia = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
      modules = [self.nixOnDroidModules.leia];
      pkgs = withSystem "aarch64-linux" ({pkgs, ...}: pkgs);
    };

    nixosConfigurations.u = lib.nixosSystem {
      modules = [
        self.nixosModules.u
        {nixpkgs.pkgs = withSystem "x86_64-linux" ({pkgs, ...}: pkgs);}
      ];
    };
  };

  perSystem = {pkgs, ...}: {
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
      all = self.lib.mkWrappersPackage {
        inherit (self) wrappers;
        inherit pkgs;
        name = "all";
      };

      shell = self.lib.mkWrappersPackage {
        inherit pkgs;
        name = "shell";
        wrappers = {inherit (self.wrappers) atuin direnv fish helix;};
      };
    };
  };

  systems = ["aarch64-linux" "x86_64-linux"];
}
