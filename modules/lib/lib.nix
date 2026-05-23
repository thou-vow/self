{
  inputs,
  lib,
  self,
  withSystem,
  ...
}: {
  flake.lib = {
    convertDagOfStrToLines = dag:
      lib.concatMapStringsSep "\n" (x: x.data)
      (inputs.nix-wrapper-modules.lib.dag.unwrapSort "convertDagOfStrToLines" dag);

    emptyDir = pkgs: pkgs.runCommandCC "empty-dir" {} ''mkdir -p $out '';

    makeExecutable = pkgs: name: path:
      pkgs.runCommand name {} ''
        cp -R ${path} $out
        chmod -R +x $out
      '';
  };
}
