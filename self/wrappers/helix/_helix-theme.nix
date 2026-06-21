style:
with style.palette; {
  "ui.background" = {bg = background;};
  "ui.cursor.normal" = {bg = main-selection;};
  "ui.cursor.insert" = {bg = main-selection;};
  "ui.cursor.select" = {bg = main-selection;};
  "ui.cursor.primary.normal" = {
    fg = dark-background;
    bg = main-cursor;
    modifiers = ["bold"];
  };
  "ui.cursor.primary.insert" = {
    fg = dark-background;
    bg = bright-green;
    modifiers = ["bold"];
  };
  "ui.cursor.primary.select" = {
    fg = dark-background;
    bg = bright-blue;
    modifiers = ["bold"];
  };
  "ui.cursor.match" = {
    fg = main-cursor;
    underline = {
      color = main-cursor;
      style = "line";
    };
  };
  "ui.linenr" = {fg = invisible;};
  "ui.linenr.selected" = {fg = foreground;};
  "ui.statusline" = {
    fg = foreground;
    bg = dark-background;
  };
  "ui.statusline.inactive" = {
    fg = invisible;
    bg = dark-background;
  };
  "ui.statusline.normal" = {
    fg = main-cursor;
    modifiers = ["bold"];
  };
  "ui.statusline.insert" = {
    fg = dark-background;
    bg = bright-green;
    modifiers = ["bold"];
  };
  "ui.statusline.select" = {
    fg = dark-background;
    bg = bright-blue;
    modifiers = ["bold"];
  };
  "ui.bufferline" = {
    fg = dark-foreground;
    bg = dark-background;
  };
  "ui.bufferline.active" = {
    fg = main-cursor;
    bg = background;
    underline = {
      color = main-cursor;
      style = "line";
    };
  };
  "ui.popup" = {
    fg = foreground;
    bg = other-highlight;
  };
  "ui.window" = {fg = dark-background;};
  "ui.help" = {
    fg = foreground;
    bg = other-highlight;
  };
  "ui.text" = {fg = foreground;};
  "ui.text.focus" = {
    fg = main-cursor;
    bg = other-highlight;
    modifiers = ["bold"];
  };
  "ui.text.inactive" = {fg = dark-foreground;};
  "ui.text.directory" = {fg = blue;};
  "ui.virtual" = {
    fg = invisible;
    modifiers = ["italic"];
  };
  "ui.virtual.ruler" = {bg = other-highlight;};
  "ui.virtual.jump-label" = {
    fg = main-cursor;
    modifiers = ["bold"];
  };
  "ui.menu" = {
    fg = foreground;
    bg = other-highlight;
  };
  "ui.menu.selected" = {
    fg = main-cursor;
    bg = main-highlight;
    modifiers = ["bold"];
  };
  "ui.menu.scroll" = {
    fg = foreground;
    bg = dark-background;
  };
  "ui.selection" = {bg = other-selection;};
  "ui.selection.primary" = {bg = main-selection;};
  "ui.highlight" = {bg = main-highlight;};
  "ui.cursorline.primary" = {bg = main-highlight;};
  "ui.cursorline.secondary" = {bg = other-highlight;};
  "ui.cursorcolumn.primary" = {bg = main-highlight;};
  "ui.cursorcolumn.secondary" = {bg = other-highlight;};
  "warning" = {fg = bright-yellow;};
  "error" = {fg = bright-red;};
  "info" = {fg = bright-cyan;};
  "hint" = {fg = foreground;};
  "diagnostic.warning" = {
    underline = {
      color = bright-yellow;
      style = "curl";
    };
  };
  "diagnostic.error" = {
    underline = {
      color = bright-red;
      style = "curl";
    };
  };
  "diagnostic.info" = {
    underline = {
      color = bright-cyan;
      style = "curl";
    };
  };
  "diagnostic.hint" = {
    underline = {
      color = foreground;
      style = "curl";
    };
  };
  "diagnostic.unnecessary" = {
    underline = {
      color = dark-foreground;
      style = "curl";
    };
  };
  "diagnostic.deprecated" = {modifiers = ["crossed_out"];};

  "attribute" = {fg = variable;};
  "type" = {fg = class;};
  "type.enum.variant" = {fg = variable;};
  "constant" = {fg = constant;};
  "constant.builtin.boolean" = {fg = boolean;};
  "constant.character" = {fg = string;};
  "constant.character.escape" = {fg = escape;};
  "constant.numeric" = {fg = number;};
  "string" = {fg = string;};
  "string.regexp" = {fg = escape;};
  "string.special" = {fg = escape;};
  "string.special.path" = {fg = path;};
  "string.special.url" = {
    fg = escape;
    underline = {
      color = escape;
      style = "dotted";
    };
  };
  "comment" = {fg = comment;};
  "variable" = {fg = variable;};
  "variable.builtin" = {fg = keyword;};
  "variable.parameter" = {fg = parameter;};
  "label" = {fg = namespace;};
  "punctuation" = {
    fg = dark-foreground;
    # modifiers = ["dim"];
  };
  "keyword" = {fg = keyword;};
  "operator" = {fg = operator;};
  "function" = {fg = function;};
  "tag" = {fg = keyword;};
  "namespace" = {fg = namespace;};
  "special" = {fg = escape;};

  "diff.plus" = {fg = green;};
  "diff.minus" = {fg = red;};
  "diff.delta" = {fg = yellow;};

  "markup.heading" = {fg = function;};
  "markup.list" = {fg = namespace;};
  "markup.bold" = {
    fg = number;
    modifiers = ["bold"];
  };
  "markup.italic" = {
    fg = operator;
    modifiers = ["italic"];
  };
  "markup.strikethrough" = {
    fg = boolean;
    modifiers = ["crossed-out"];
  };
  "markup.link" = {
    fg = path;
    underline = {
      color = path;
      style = "dotted";
    };
  };
  "markup.raw" = {fg = constant;};

  "rainbow" = rainbow;
}
