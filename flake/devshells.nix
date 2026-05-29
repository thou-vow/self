{
  inputs,
  lib,
  self,
  ...
} @ top: {
  perSystem = {
    inputs',
    pkgs,
    system,
    ...
  }: {
    devShells.default = pkgs.mkShell {
      buildInputs =
        (with pkgs; [
          alejandra
          kdlfmt
          schemat
          taplo
        ])
        ++ (with inputs'.nix-packages.packages; [
          nvfetcher
        ]);
    };
  };
}
