(require (prefix-in hx.cmd. "helix/commands.scm"))
(require (prefix-in hx.theme. "helix/themes.scm"))
(require "self/utils.scm")

;;; Okhsl

(define main-cursor "#f4dbe2") ; 0 50 90
(define other-cursor "#e8b7c5") ; 0 50 80

(define dark-background "#060810") ; 270 30 5
(define background "#121622") ; 270 30 10
(define other-highlight "#1c2232") ; 270 30 15
(define main-highlight "#272d41") ; 270 30 20
(define other-selection "#313950") ; 270 30 25
(define main-selection "#46516f") ; 270 30 35
(define invisible "#7683a8") ; 270 30 55
(define comment "#919dbf") ; 270 30 65
(define dark-foreground "#aeb8d4") ; 270 30 75
(define foreground "#ced4e6") ; 270 30 85

(define red "#f0a396") ; 30 70 75
(define yellow "#d7b659") ; 90 70 75
(define green "#75d18b") ; 150 70 75
(define cyan "#60cbdd") ; 210 70 75
(define blue "#a4b7f0") ; 270 70 75
(define magenta "#e39edc") ; 330 70 75
(define bright-red "#f6c9c1") ; 30 70 85
(define bright-yellow "#efd387") ; 90 70 85
(define bright-green "#99ecaa") ; 150 70 85
(define bright-cyan "#95e4f2") ; 210 75 85
(define bright-blue "#c8d4f6") ; 270 70 85
(define bright-magenta "#eec6e9") ; 330 70 85

(define escape red)
(define parameter yellow)
(define class green)
(define constant cyan)
(define function blue)
(define keyword magenta)
(define boolean bright-red)
(define string bright-yellow)
(define number bright-green)
(define variable bright-cyan)
(define namespace bright-blue)
(define operator bright-blue)
(define path bright-magenta)

(define theme
  (hx.theme.hashmap->theme "theme"
    (kv (ls "ui.background" (kv (ls 'bg background)))
      (ls "ui.cursor.normal" (kv (ls 'bg main-selection)))
      (ls "ui.cursor.insert" (kv (ls 'bg main-selection)))
      (ls "ui.cursor.select" (kv (ls 'bg main-selection)))
      (ls "ui.cursor.primary.normal"
        (kv (ls 'fg dark-background) (ls 'bg main-cursor) (ls 'modifiers (ls "bold"))))
      (ls "ui.cursor.primary.insert"
        (kv (ls 'fg dark-background) (ls 'bg bright-green) (ls 'modifiers (ls "bold"))))
      (ls "ui.cursor.primary.select"
        (kv (ls 'fg dark-background) (ls 'bg bright-blue) (ls 'modifiers (ls "bold"))))
      (ls "ui.cursor.match"
        (kv (ls 'fg main-cursor)
          (ls 'underline (kv (ls 'color main-cursor) (ls 'style "line")))))
      (ls "ui.linenr" (kv (ls 'fg invisible)))
      (ls "ui.linenr.selected" (kv (ls 'fg foreground)))
      (ls "ui.statusline" (kv (ls 'fg foreground) (ls 'bg dark-background)))
      (ls "ui.statusline.inactive" (kv (ls 'fg invisible) (ls 'bg dark-background)))
      (ls "ui.statusline.normal" (kv (ls 'fg main-cursor) (ls 'modifiers (ls "bold"))))
      (ls "ui.statusline.insert"
        (kv (ls 'fg dark-background) (ls 'bg bright-green) (ls 'modifiers (ls "bold"))))
      (ls "ui.statusline.select"
        (kv (ls 'fg dark-background) (ls 'bg bright-blue) (ls 'modifiers (ls "bold"))))
      (ls "ui.bufferline" (kv (ls 'fg dark-foreground) (ls 'bg dark-background)))
      (ls "ui.bufferline.active"
        (kv (ls 'fg main-cursor)
          (ls 'bg background)
          (ls 'underline (kv (ls 'color main-cursor) (ls 'style "line")))))
      (ls "ui.popup" (kv (ls 'fg foreground) (ls 'bg other-highlight)))
      (ls "ui.window" (kv (ls 'fg dark-background)))
      (ls "ui.help" (kv (ls 'fg foreground) (ls 'bg other-highlight)))
      (ls "ui.text" (kv (ls 'fg foreground)))
      (ls "ui.text.focus"
        (kv (ls 'fg main-cursor) (ls 'bg other-highlight) (ls 'modifiers (ls "bold"))))
      (ls "ui.text.inactive" (kv (ls 'fg dark-foreground)))
      (ls "ui.text.directory" (kv (ls 'fg blue)))
      (ls "ui.virtual" (kv (ls 'fg invisible)))
      (ls "ui.virtual.ruler" (kv (ls 'bg other-highlight)))
      (ls "ui.virtual.jump-label" (kv (ls 'fg main-cursor) (ls 'modifiers (ls "bold"))))
      (ls "ui.menu" (kv (ls 'fg foreground) (ls 'bg other-highlight)))
      (ls "ui.menu.selected"
        (kv (ls 'fg main-cursor) (ls 'bg main-highlight) (ls 'modifiers (ls "bold"))))
      (ls "ui.menu.scroll" (kv (ls 'fg foreground) (ls 'bg dark-background)))
      (ls "ui.selection" (kv (ls 'bg other-selection)))
      (ls "ui.selection.primary" (kv (ls 'bg main-selection)))
      (ls "ui.highlight" (kv (ls 'bg main-highlight)))
      (ls "ui.cursorline.primary" (kv (ls 'bg main-highlight)))
      (ls "ui.cursorline.secondary" (kv (ls 'bg other-highlight)))
      (ls "ui.cursorcolumn.primary" (kv (ls 'bg main-highlight)))
      (ls "ui.cursorcolumn.secondary" (kv (ls 'bg other-highlight)))
      (ls "warning" (kv (ls 'fg bright-yellow)))
      (ls "error" (kv (ls 'fg bright-red)))
      (ls "info" (kv (ls 'fg bright-cyan)))
      (ls "hint" (kv (ls 'fg foreground)))
      (ls "diagnostic.warning"
        (kv (ls 'underline (kv (ls 'color bright-yellow) (ls 'style "curl")))))
      (ls "diagnostic.error"
        (kv (ls 'underline (kv (ls 'color bright-red) (ls 'style "curl")))))
      (ls "diagnostic.info"
        (kv (ls 'underline (kv (ls 'color bright-cyan) (ls 'style "curl")))))
      (ls "diagnostic.hint"
        (kv (ls 'underline (kv (ls 'color foreground) (ls 'style "curl")))))
      (ls "diagnostic.unnecessary"
        (kv (ls 'underline (kv (ls 'color dark-foreground) (ls 'style "curl")))))
      (ls "diagnostic.deprecated" (kv (ls 'modifiers (ls "crossed_out"))))
      ; ("tabstop")ls

      (ls "attribute" (kv (ls 'fg variable)))
      (ls "type" (kv (ls 'fg class)))
      (ls "type.enum.variant" (kv (ls 'fg variable)))
      (ls "constant" (kv (ls 'fg constant)))
      (ls "constant.builtin.boolean" (kv (ls 'fg boolean)))
      (ls "constant.character" (kv (ls 'fg string)))
      (ls "constant.character.escape" (kv (ls 'fg escape)))
      (ls "constant.numeric" (kv (ls 'fg number)))
      (ls "string" (kv (ls 'fg string)))
      (ls "string.regexp" (kv (ls 'fg escape)))
      (ls "string.special" (kv (ls 'fg escape)))
      (ls "string.special.path" (kv (ls 'fg path)))
      (ls "string.special.url"
        (kv (ls 'fg escape)
          (ls 'underline (kv (ls 'color escape) (ls 'style "dotted")))))
      (ls "comment" (kv (ls 'fg comment)))
      (ls "variable" (kv (ls 'fg variable)))
      (ls "variable.builtin" (kv (ls 'fg keyword)))
      (ls "variable.parameter" (kv (ls 'fg parameter)))
      (ls "label" (kv (ls 'fg namespace)))
      (ls "punctuation" (kv (ls 'fg dark-foreground)))
      (ls "keyword" (kv (ls 'fg keyword)))
      (ls "operator" (kv (ls 'fg operator)))
      (ls "function" (kv (ls 'fg function)))
      (ls "tag" (kv (ls 'fg keyword)))
      (ls "namespace" (kv (ls 'fg namespace)))
      (ls "special" (kv (ls 'fg escape)))

      (ls "diff.plus" (kv (ls 'fg green)))
      (ls "diff.minus" (kv (ls 'fg red)))
      (ls "diff.delta" (kv (ls 'fg yellow)))

      (ls "markup.heading" (kv (ls 'fg function)))
      (ls "markup.list" (kv (ls 'fg namespace)))
      (ls "markup.bold" (kv (ls 'fg number) (ls 'modifiers (ls "bold"))))
      (ls "markup.italic" (kv (ls 'fg operator) (ls 'modifiers (ls "italic"))))
      (ls "markup.strikethrough" (kv (ls 'fg boolean) (ls 'modifiers (ls "crossed-out"))))
      (ls "markup.link"
        (kv (ls 'fg path) (ls 'underline (kv (ls 'color path) (ls 'style "dotted")))))
      (ls "markup.raw" (kv (ls 'fg constant))))))

(hx.theme.register-theme theme)
(hx.cmd.theme "theme")
