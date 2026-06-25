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

    filesToConstruct = pkgs: {parentDir ? null, ...}: attrsFiles:
      lib.mapAttrs' (name: value: {
        name = lib.optionalString (parentDir != null) "${parentDir}/" + name;
        value = {
          relPath = lib.optionalString (parentDir != null) "${parentDir}/" + name;
          builder = ''${pkgs.coreutils}/bin/cp -RL "${value.path}" "$2" || true'';
        };
      })
      attrsFiles;

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
      wSource = "$WRITABLE_STORE/$base";
      wInit =
        # sh
        ''if [ ! -e ${wSource} ]; then mkdir -p ${wSource}; cp -RL --no-preserve=mode,ownership ${source} "$WRITABLE_STORE/"; fi'';
    in
      # sh
      ''$(base=$(basename ${source}); if [ -n "$WRITABLE_STORE" ]; then ${wInit}; echo ${wSource}; else echo ${source}; fi)'';
  };
}
