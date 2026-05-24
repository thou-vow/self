{
  inputs,
  lib,
  self,
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
          value = self.lib.mkWrapperPackage {
            inherit system;
            wrapper = value;
          };
        })
        top.config.flake.wrappers)
      {
        all = self.lib.mkWrapperSetPackage {
          inherit (self) wrappers;
          inherit system;
        };

        shell = self.lib.mkWrapperSetPackage {
          inherit system;
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
