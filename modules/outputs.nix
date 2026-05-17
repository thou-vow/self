{
  inputs,
  lib,
  self,
  withSystem,
  ...
} @ top: {
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

    packages = lib.mkMerge [
      (lib.mapAttrs' (name: value: {
          name = "wrapper-${name}";
          value = self.lib.mkWrappersPackage pkgs {
            wrappers = {${name} = value;};
          };
        })
        top.config.flake.wrappers)
      {
        all = self.lib.mkWrappersPackage pkgs {inherit (self) wrappers;};

        shell = self.lib.mkWrappersPackage pkgs {
          wrappers = {
            inherit
              (self.wrappers)
              atuin
              direnv
              helix
              nushell
              ;
          };
        };
      }
    ];
  };

  systems = lib.systems.flakeExposed;
}
