{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake = {
    nixOnDroidConfigurations.leia =
      self.lib.nixOnDroidConfiguration
      (withSystem "aarch64-linux" ({pkgs-nod, ...}: pkgs-nod)) {
        modules = [self.nixOnDroidModules.leia];
      };

    nixosConfigurations.u =
      self.lib.nixosSystem
      (withSystem "x86_64-linux" ({pkgs, ...}: pkgs)) {
        modules = [self.nixosModules.u];
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
      all = self.lib.mkWrappersPackage pkgs {
        inherit (self) wrappers;
        name = "all";
      };

      helix = self.lib.mkWrappersPackage pkgs {
        name = "helix";
        wrappers = {inherit (self.wrappers) helix;};
      };

      shell = self.lib.mkWrappersPackage pkgs {
        name = "shell";
        wrappers = {inherit (self.wrappers) atuin direnv helix nushell;};
      };
    };
  };

  systems = lib.systems.flakeExposed;
}
