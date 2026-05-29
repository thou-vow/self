{
  inputs,
  lib,
  self,
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

    types = {
      environmentVariable = with lib.types;
        nullOr (oneOf [
          (listOf (oneOf [
            int
            path
            str
          ]))
          int
          path
          str
        ]);

      environmentVariables = lib.types.attrsOf self.lib.types.environmentVariable;
    };
  };
}
