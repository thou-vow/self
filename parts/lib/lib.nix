{lib, ...}: {
  flake.lib = {
    mkAutoEnableOption = value:
      if builtins.isString value
      then lib.mkEnableOption value // {default = true;}
      else if lib.isType "option" value
      then value // {default = true;}
      else throw "Unexpected value in self.lib.mkAutoEnableOption: ${value}";

    mkShellEnv = pkgs: name: {packages ? []}:
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
