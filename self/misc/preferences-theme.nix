_: {
  flake.wrapperIntegrationPresets.preferencesTheme = _: {
    preferences.style.palette = sub:
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
        constant = bright-violet;
        escape = bright-red;
        function = bright-magenta;
        keyword = bright-magenta;
        namespace = bright-blue;
        number = bright-green;
        operator = bright-blue;
        parameter = bright-orange;
        path = bright-violet;
        string = bright-yellow;
        variable = bright-cyan;

        rainbow = [green magenta aqua red cyan orange blue yellow violet];
      };
  };
}
