style:
with style.palette; {
  cursor = main-cursor;
  cursor_text_color = "background";

  url_color = bright-violet;
  url_style = "dotted";

  active_border_color = main-cursor;
  inactive_border_color = background;
  bell_border_color = bright-orange;

  active_tab_foreground = main-cursor;
  active_tab_background = background;
  inactive_tab_foreground = dark-foreground;
  inactive_tab_background = dark-background;

  foreground = foreground;
  background = dark-background;
  transparent_background_colors = toString [
    background
    other-highlight
    main-highlight
    other-selection
    main-selection
  ];
  selection_foreground = null;
  selection_background = main-selection;

  color0 = background;
  color1 = red;
  color2 = green;
  color3 = yellow;
  color4 = blue;
  color5 = magenta;
  color6 = cyan;
  color7 = dark-foreground;
  color8 = invisible;
  color9 = bright-red;
  color10 = bright-green;
  color11 = bright-yellow;
  color12 = bright-blue;
  color13 = bright-magenta;
  color14 = bright-cyan;
  color15 = foreground;
}
