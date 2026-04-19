(require-builtin helix/core/keymaps as hx.core.keymaps.)
(require (prefix-in hx.cfg. "helix/configuration.scm"))
(require (prefix-in hx.cmd. "helix/commands.scm"))
(require (prefix-in hx.theme. "helix/themes.scm"))
(require (prefix-in keys. "init/keybindings.scm"))
(require (prefix-in theme. "init/theme.scm"))
(require "self/utils.scm")

(hx.cfg.set-keybindings!
  (~> keys.keybindings
    (value->jsexpr-string)
    (hx.core.keymaps.helix-string->keymap)))
(hx.theme.register-theme theme.theme)
(hx.cmd.theme "theme")

(hx.cfg.set-option! 'bufferline "always")
(hx.cfg.set-option! 'color-modes #t)
(hx.cfg.set-option! 'popup-border "all")
(hx.cfg.set-option! 'default-yank-register "+")
(hx.cfg.set-option! 'cursorcolumn #t)
(hx.cfg.set-option! 'cursorline #t)
(hx.cfg.set-option! 'line-number "relative")
(hx.cfg.set-option! 'text-width 120)
(hx.cfg.set-option! 'scrolloff 3)
(hx.cfg.set-option! 'idle-timeout 0)
(hx.cfg.set-option! 'completion-trigger-len 1)
(hx.cfg.set-option! 'completion-timeout 0)
(hx.cfg.set-option! 'completion-replace #t)
(hx.cfg.set-option! 'cursor-shape.normal "bar")
(hx.cfg.set-option! 'cursor-shape.insert "bar")
(hx.cfg.set-option! 'cursor-shape.select "bar")
(hx.cfg.set-option! 'end-of-line-diagnostics "hint")
(hx.cfg.set-option! 'file-picker.hidden #f)
(hx.cfg.set-option! 'indent-guides.render #f)
(hx.cfg.set-option! 'indent-guides.character "▏")
(hx.cfg.set-option! 'indent-guides.skip-levels 1)
(hx.cfg.set-option! 'inline-diagnostics.cursor-line "disable")
(hx.cfg.set-option! 'inline-diagnostics.other-lines "disable")
(hx.cfg.set-option! 'lsp.enable #t)
(hx.cfg.set-option! 'lsp.auto-signature-help #f)
(hx.cfg.set-option! 'lsp.display-messages #t)
(hx.cfg.set-option! 'lsp.display-inlay-hints #t)
(hx.cfg.set-option! 'search.smart-case #t)
(hx.cfg.set-option! 'soft-wrap.enable #t)
(hx.cfg.set-option! 'statusline.left
  '("mode"
    "separator"
    "workspace-diagnostics"
    "spinner"
    "separator"
    "selections"
    "separator"
    "register"))
(hx.cfg.set-option! 'statusline.center
  '("file-name"
    "separator"
    "version-control"))
(hx.cfg.set-option! 'statusline.right
  '("file-modification-indicator"
    "separator"
    "read-only-indicator"
    "separator"
    "diagnostics"
    "separator"
    "position"
    "separator"
    "position-percentage"))
(hx.cfg.set-option! 'statusline.separator "")

(for-each
  (lambda (language-name)
    (hx.cfg.update-language-config! language-name
      (kv (ls 'name language-name)
        (ls 'auto-format #f)
        (ls 'indent (kv (ls 'tab-width 2) (ls 'unit "\t"))))))
  (ls "c" "css" "fish" "java" "javascript" "json" "kdl" "nix" "rust" "scheme" "typescript" "typst" "yaml"))

(hx.cfg.update-language-config! "html"
  (kv (ls 'name "html")
    (ls 'language-servers
      (append
        (let
          ((list-or-false (hash-try-get (hx.cfg.get-language-config "html") 'language-servers)))
          (if (not list-or-false) '() list-or-false))
        (ls "angular-language-server")))))
(hx.cfg.update-language-config! "nix"
  (kv (ls 'name "nix")
    (ls 'formatter (kv (ls 'command "alejandra")))))
(hx.cfg.update-language-config! "scheme"
  (kv (ls 'name "scheme")
    (ls 'formatter (kv (ls 'command "schemat")))
    (ls 'language-servers (ls "steel-language-server"))))

(hx.cfg.set-lsp-config! "angular-language-server"
  (kv (ls 'command "angular-language-server") (ls 'roots (ls "angular.json"))))
(hx.cfg.set-lsp-config! "rust-analyzer"
  (kv (ls 'config (kv (ls 'check (kv (ls 'command "clippy")))))))
(hx.cfg.set-lsp-config! "steel-language-server"
  (kv (ls 'command "steel-language-server")))
(hx.cfg.set-lsp-config! "tinymist"
  (kv (ls 'config (kv (ls 'exportPdf "onSave")))))
