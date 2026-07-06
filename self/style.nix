{
  lib,
  self,
  ...
}: let
  styleOption = {
    enable = self.lib.mkAutoEnableOption "common settings";
    palette = lib.mkOption {
      type = lib.types.submodule {
        options =
          lib.pipe [
            "main-cursor"
            "other-cursor"

            "dark-background"
            "background"
            "other-highlight"
            "main-highlight"
            "other-selection"
            "main-selection"
            "invisible"
            "comment"
            "dark-foreground"
            "foreground"

            "red"
            "orange"
            "yellow"
            "green"
            "aqua"
            "cyan"
            "blue"
            "violet"
            "magenta"

            "bright-red"
            "bright-orange"
            "bright-yellow"
            "bright-green"
            "bright-aqua"
            "bright-cyan"
            "bright-blue"
            "bright-violet"
            "bright-magenta"

            "boolean"
            "class"
            "constant"
            "escape"
            "function"
            "keyword"
            "namespace"
            "number"
            "operator"
            "parameter"
            "path"
            "string"
            "variable"

            "rainbow"
          ] [
            (map (name: {
              inherit name;
              value = lib.mkOption {
                type = lib.types.nullOr (lib.types.oneOf [
                  lib.types.str
                  (lib.types.listOf lib.types.str)
                ]);
              };
            }))
            builtins.listToAttrs
          ];
      };
    };
  };

  styleConfig = {
    palette = sub:
      with sub.config; {
        main-cursor = "#f4dbe2"; # 0 50 90
        other-cursor = "#e8b7c5"; # 0 50 80

        dark-background = "#060810"; # 270 30 5
        background = "#0d111b"; # 270 30 8
        other-highlight = "#161b29"; # 270 30 12
        main-highlight = "#202638"; # 270 30 17
        other-selection = "#37405a"; # 270 30 28
        main-selection = "#46516f"; # 270 30 35
        invisible = "#7683a8"; # 270 30 55
        comment = "#919dbf"; # 270 30 65
        dark-foreground = "#aeb8d4"; # 270 30 75
        foreground = "#ced4e6"; # 270 30 85

        red = "#f0a396"; # 30 70 75
        orange = "#eca870"; # 60 70 75
        yellow = "#d7b659"; # 90 70 75
        green = "#75d18b"; # 150 70 75
        aqua = "#5fd0bc"; # 180 70 75
        cyan = "#60cbdd"; # 210 70 75
        blue = "#a4b7f0"; # 270 70 75
        violet = "#c3abf0"; # 300 70 75
        magenta = "#e39edc"; # 330 70 75

        bright-red = "#f6c9c1"; # 30 70 85
        bright-orange = "#f6cba9"; # 60 70 85
        bright-yellow = "#efd387"; # 90 70 85
        bright-green = "#99ecaa"; # 150 70 85
        bright-aqua = "#84ebd7"; # 180 70 85
        bright-cyan = "#95e4f2"; # 210 75 85
        bright-blue = "#c8d4f6"; # 270 70 85
        bright-violet = "#daccf6"; # 300 70 85
        bright-magenta = "#eec6e9"; # 330 70 85

        boolean = bright-red;
        class = bright-green;
        constant = bright-blue;
        escape = bright-red;
        function = bright-violet;
        keyword = bright-magenta;
        namespace = bright-aqua;
        number = bright-green;
        operator = bright-aqua;
        parameter = bright-orange;
        path = bright-violet;
        string = bright-yellow;
        variable = bright-cyan;

        rainbow = [green magenta aqua red cyan orange blue yellow violet];
      };
  };
in {
  flake.nixosModules.style = _: {
    options.self.style = styleOption;

    config.self.style = styleConfig;
  };

  flake.homeModules.style = _: {
    options.self.style = styleOption;

    config.self.style = styleConfig;
  };
}
