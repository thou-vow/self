_: {
  perSystem = {pkgs, ...}: {
    devShells.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        alejandra
        kdlfmt
        schemat
        taplo
      ];
    };
  };
}
