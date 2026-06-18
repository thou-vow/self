{
  lib,
  self,
  wlib,
  ...
}: {
  flake.lib = {
    convertDagOfStrToLines = dag:
      lib.concatMapStringsSep "\n" (x: x.data)
      (wlib.dag.unwrapSort "convertDagOfStrToLines" dag);

    emptyDir = pkgs: pkgs.runCommand "empty-dir" {} ''mkdir -p $out'';

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

    potentiallyWritableShellInline = source: let
      wSource = "$WRITABLE_STORE/${baseNameOf source}";
      wInit =
        # sh
        ''if [ ! -e ${wSource} ]; then mkdir -p ${wSource}; cp -R --no-preserve=mode,ownership ${source} "$WRITABLE_STORE/"; fi'';
    in
      # sh
      ''$(if [ -n "$WRITABLE_STORE" ]; then ${wInit}; echo ${wSource}; else echo ${source}; fi)'';
  };
}
