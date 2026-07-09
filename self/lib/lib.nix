{lib, ...}: {
  flake.lib = {
    mkAutoEnableOption = name: lib.mkEnableOption name // {default = true;};

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
