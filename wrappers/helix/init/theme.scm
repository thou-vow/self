(require (prefix-in hx.theme. "helix/themes.scm"))
(require "self/utils.scm")

(provide theme)

;;; Okhsl

(define c-main-cursor "#f4dbe2") ; 0 50 90
(define c-other-cursor "#e8b7c5") ; 0 50 80

(define c-dark-background "#060810") ; 270 30 5
(define c-background "#121622") ; 270 30 10
(define c-other-highlight "#1c2232") ; 270 30 15
(define c-main-highlight "#272d41") ; 270 30 20
(define c-other-selection "#313950") ; 270 30 25
(define c-main-selection "#46516f") ; 270 30 35
(define c-invisible "#7683a8") ; 270 30 55
(define c-comment "#919dbf") ; 270 30 65
(define c-dark-foreground "#aeb8d4") ; 270 30 75
(define c-foreground "#ced4e6") ; 270 30 85

(define c-red "#f0a396") ; 30 70 75
(define c-yellow "#d7b659") ; 90 70 75
(define c-green "#75d18b") ; 150 70 75
(define c-cyan "#60cbdd") ; 210 70 75
(define c-blue "#a4b7f0") ; 270 70 75
(define c-magenta "#e39edc") ; 330 70 75
(define c-bright-red "#f6c9c1") ; 30 70 85
(define c-bright-yellow "#efd387") ; 90 70 85
(define c-bright-green "#99ecaa") ; 150 70 85
(define c-bright-cyan "#95e4f2") ; 210 75 85
(define c-bright-blue "#c8d4f6") ; 270 70 85
(define c-bright-magenta "#eec6e9") ; 330 70 85

(define c-escape c-red)
(define c-parameter c-yellow)
(define c-class c-green)
(define c-constant c-cyan)
(define c-function c-blue)
(define c-keyword c-magenta)
(define c-boolean c-bright-red)
(define c-string c-bright-yellow)
(define c-number c-bright-green)
(define c-variable c-bright-cyan)
(define c-namespace c-bright-blue)
(define c-operator c-bright-blue)
(define c-path c-bright-magenta)

(define theme
  (hx.theme.hashmap->theme "theme"
    (kv (ls "ui.background" (kv (ls 'bg c-background)))
      (ls "ui.cursor.normal" (kv (ls 'bg c-main-selection)))
      (ls "ui.cursor.insert" (kv (ls 'bg c-main-selection)))
      (ls "ui.cursor.select" (kv (ls 'bg c-main-selection)))
      (ls "ui.cursor.primary.normal"
        (kv (ls 'fg c-dark-background) (ls 'bg c-main-cursor) (ls 'modifiers (ls "bold"))))
      (ls "ui.cursor.primary.insert"
        (kv (ls 'fg c-dark-background) (ls 'bg c-bright-green) (ls 'modifiers (ls "bold"))))
      (ls "ui.cursor.primary.select"
        (kv (ls 'fg c-dark-background) (ls 'bg c-bright-blue) (ls 'modifiers (ls "bold"))))
      (ls "ui.cursor.match"
        (kv (ls 'fg c-main-cursor)
          (ls 'underline (kv (ls 'color c-main-cursor) (ls 'style "line")))))
      (ls "ui.linenr" (kv (ls 'fg c-invisible)))
      (ls "ui.linenr.selected" (kv (ls 'fg c-foreground)))
      (ls "ui.statusline" (kv (ls 'fg c-foreground) (ls 'bg c-dark-background)))
      (ls "ui.statusline.inactive" (kv (ls 'fg c-invisible) (ls 'bg c-dark-background)))
      (ls "ui.statusline.normal" (kv (ls 'fg c-main-cursor) (ls 'modifiers (ls "bold"))))
      (ls "ui.statusline.insert"
        (kv (ls 'fg c-dark-background) (ls 'bg c-bright-green) (ls 'modifiers (ls "bold"))))
      (ls "ui.statusline.select"
        (kv (ls 'fg c-dark-background) (ls 'bg c-bright-blue) (ls 'modifiers (ls "bold"))))
      (ls "ui.bufferline" (kv (ls 'fg c-dark-foreground) (ls 'bg c-dark-background)))
      (ls "ui.bufferline.active"
        (kv (ls 'fg c-main-cursor)
          (ls 'bg c-background)
          (ls 'underline (kv (ls 'color c-main-cursor) (ls 'style "line")))))
      (ls "ui.popup" (kv (ls 'fg c-foreground) (ls 'bg c-other-highlight)))
      (ls "ui.window" (kv (ls 'fg c-dark-background)))
      (ls "ui.help" (kv (ls 'fg c-foreground) (ls 'bg c-other-highlight)))
      (ls "ui.text" (kv (ls 'fg c-foreground)))
      (ls "ui.text.focus"
        (kv (ls 'fg c-main-cursor) (ls 'bg c-other-highlight) (ls 'modifiers (ls "bold"))))
      (ls "ui.text.inactive" (kv (ls 'fg c-dark-foreground)))
      (ls "ui.text.directory" (kv (ls 'fg c-blue)))
      (ls "ui.virtual" (kv (ls 'fg c-invisible)))
      (ls "ui.virtual.ruler" (kv (ls 'bg c-other-highlight)))
      (ls "ui.virtual.jump-label" (kv (ls 'fg c-main-cursor) (ls 'modifiers (ls "bold"))))
      (ls "ui.menu" (kv (ls 'fg c-foreground) (ls 'bg c-other-highlight)))
      (ls "ui.menu.selected"
        (kv (ls 'fg c-main-cursor) (ls 'bg c-main-highlight) (ls 'modifiers (ls "bold"))))
      (ls "ui.menu.scroll" (kv (ls 'fg c-foreground) (ls 'bg c-dark-background)))
      (ls "ui.selection" (kv (ls 'bg c-other-selection)))
      (ls "ui.selection.primary" (kv (ls 'bg c-main-selection)))
      (ls "ui.highlight" (kv (ls 'bg c-main-highlight)))
      (ls "ui.cursorline.primary" (kv (ls 'bg c-main-highlight)))
      (ls "ui.cursorline.secondary" (kv (ls 'bg c-other-highlight)))
      (ls "ui.cursorcolumn.primary" (kv (ls 'bg c-main-highlight)))
      (ls "ui.cursorcolumn.secondary" (kv (ls 'bg c-other-highlight)))
      (ls "warning" (kv (ls 'fg c-bright-yellow)))
      (ls "error" (kv (ls 'fg c-bright-red)))
      (ls "info" (kv (ls 'fg c-bright-cyan)))
      (ls "hint" (kv (ls 'fg c-foreground)))
      (ls "diagnostic.warning"
        (kv (ls 'underline (kv (ls 'color c-bright-yellow) (ls 'style "curl")))))
      (ls "diagnostic.error"
        (kv (ls 'underline (kv (ls 'color c-bright-red) (ls 'style "curl")))))
      (ls "diagnostic.info"
        (kv (ls 'underline (kv (ls 'color c-bright-cyan) (ls 'style "curl")))))
      (ls "diagnostic.hint"
        (kv (ls 'underline (kv (ls 'color c-foreground) (ls 'style "curl")))))
      (ls "diagnostic.unnecessary"
        (kv (ls 'underline (kv (ls 'color c-dark-foreground) (ls 'style "curl")))))
      (ls "diagnostic.deprecated" (kv (ls 'modifiers (ls "crossed_out"))))
      ; ("tabstop")ls

      (ls "attribute" (kv (ls 'fg c-variable)))
      (ls "type" (kv (ls 'fg c-class)))
      (ls "type.enum.variant" (kv (ls 'fg c-variable)))
      (ls "constant" (kv (ls 'fg c-constant)))
      (ls "constant.builtin.boolean" (kv (ls 'fg c-boolean)))
      (ls "constant.character" (kv (ls 'fg c-string)))
      (ls "constant.character.escape" (kv (ls 'fg c-escape)))
      (ls "constant.numeric" (kv (ls 'fg c-number)))
      (ls "string" (kv (ls 'fg c-string)))
      (ls "string.regexp" (kv (ls 'fg c-escape)))
      (ls "string.special" (kv (ls 'fg c-escape)))
      (ls "string.special.path" (kv (ls 'fg c-path)))
      (ls "string.special.url"
        (kv (ls 'fg c-escape)
          (ls 'underline (kv (ls 'color c-escape) (ls 'style "dotted")))))
      (ls "comment" (kv (ls 'fg c-comment)))
      (ls "variable" (kv (ls 'fg c-variable)))
      (ls "variable.builtin" (kv (ls 'fg c-keyword)))
      (ls "variable.parameter" (kv (ls 'fg c-parameter)))
      (ls "label" (kv (ls 'fg c-namespace)))
      (ls "punctuation" (kv (ls 'fg c-dark-foreground)))
      (ls "keyword" (kv (ls 'fg c-keyword)))
      (ls "operator" (kv (ls 'fg c-operator)))
      (ls "function" (kv (ls 'fg c-function)))
      (ls "tag" (kv (ls 'fg c-keyword)))
      (ls "namespace" (kv (ls 'fg c-namespace)))
      (ls "special" (kv (ls 'fg c-escape)))

      (ls "diff.plus" (kv (ls 'fg c-green)))
      (ls "diff.minus" (kv (ls 'fg c-red)))
      (ls "diff.delta" (kv (ls 'fg c-yellow)))

      (ls "markup.heading" (kv (ls 'fg c-function)))
      (ls "markup.list" (kv (ls 'fg c-namespace)))
      (ls "markup.bold" (kv (ls 'fg c-number) (ls 'modifiers (ls "bold"))))
      (ls "markup.italic" (kv (ls 'fg c-operator) (ls 'modifiers (ls "italic"))))
      (ls "markup.strikethrough" (kv (ls 'fg c-boolean) (ls 'modifiers (ls "crossed-out"))))
      (ls "markup.link"
        (kv (ls 'fg c-path) (ls 'underline (kv (ls 'color c-path) (ls 'style "dotted")))))
      (ls "markup.raw" (kv (ls 'fg c-constant))))))
