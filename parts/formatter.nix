{
  inputs,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    ...
  }: {
    formatter = (import inputs.treefmt-nix).mkWrapper pkgs {
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
  };
}
