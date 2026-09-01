{lib, ...}: {
  flake.lib = {
    mkAutoEnableOption = name: lib.mkEnableOption name // {default = true;};

    mkShellPackage = pkgs: name: {packages ? []}:
      pkgs.writeShellScriptBin name ''
        export PATH="${pkgs.lib.makeBinPath packages}:$PATH"

        if [ -n "''${SHELL-}" ]; then
          exec "$SHELL" "$@"
        else
          exec ${pkgs.runtimeShell} "$@"
        fi
      '';

    renderMustache = pkgs: name: data: template: let
      templateFile =
        if builtins.isString template
        then pkgs.writeText "${name}.mustache" template
        else template;

      dataJsonFile = pkgs.writeText "mustache-data.json" (builtins.toJSON data);
    in
      pkgs.runCommand name {} ''
        ${pkgs.mustache-go}/bin/mustache ${dataJsonFile} ${templateFile} > $out
      '';
  };
}
