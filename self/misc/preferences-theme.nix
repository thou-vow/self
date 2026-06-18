_: {
  flake.wrapperIntegrationModules.preferences = _: {
    preferences.style.palette = sub:
      with sub.config; {
        main-cursor = "#f4dbe2"; # 0 50 90
        other-cursor = "#e9b7c5"; # 0 50 80

        dark-background = "#08080b"; # 280 10 5
        background = "#101114"; # 280 10 8
        other-highlight = "#18181d"; # 280 10 11
        main-highlight = "#212227"; # 280 10 15
        other-selection = "#34353c"; # 280 10 23
        main-selection = "#44454e"; # 280 10 30
        invisible = "#8e909d"; # 280 10 60
        comment = "#a9aab6"; # 280 10 70
        dark-foreground = "#c5c6cf"; # 280 10 80
        foreground = "#e2e2e7"; # 280 10 90

        red = "#eda2a1"; # 20 65 75
        orange = "#e8aa76"; # 60 65 75
        yellow = "#c9bb62"; # 100 65 75
        green = "#8ccd7e"; # 140 65 75
        aqua = "#69cebb"; # 180 65 75
        cyan = "#70c7e2"; # 220 65 75
        blue = "#9bbaed"; # 260 65 75
        violet = "#c2acec"; # 300 65 75
        magenta = "#e69fce"; # 340 65 75

        bright-red = "#f2b5b4"; # 20 65 80
        bright-orange = "#efbb91"; # 60 65 80
        bright-yellow = "#d7c972"; # 100 65 80
        bright-green = "#9bdb8d"; # 140 65 80
        bright-aqua = "#79dcc9"; # 180 65 80
        bright-cyan = "#88d4ec"; # 220 65 80
        bright-blue = "#afc8f1"; # 260 65 80
        bright-violet = "#cebcf0"; # 300 65 80
        bright-magenta = "#ebb2d7"; # 340 65 80

        boolean = bright-red;
        class = bright-violet;
        constant = violet;
        escape = bright-aqua;
        function = bright-green;
        keyword = bright-magenta;
        namespace = blue;
        number = bright-orange;
        operator = green;
        parameter = bright-cyan;
        path = bright-magenta;
        string = bright-yellow;
        variable = bright-blue;

        rainbow = [red yellow cyan violet];
      };
  };
}
