;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
(setq doom-font (font-spec :family "JetBrains Mono" :size 13 :weight 'regular))
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
;;; --- Tema (doom-themes já vem com o módulo :ui doom) ---------------------

;; Outras opções: doom-one-light, doom-tokyo-night, doom-dracula, doom-nord,
;; doom-nord-light, doom-gruvbox, doom-monokai-pro, doom-vibrant, doom-palenight.
;; Para escolher um tema na hora: SPC h t
(setq doom-theme 'doom-one)

(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (doom-themes-visual-bell-config)  ; pisca a modeline no lugar do sino
  (doom-themes-org-config))         ; ajustes de aparência para o Org

(defvar my/theme-escuro 'doom-one "Tema escuro usado por `my/toggle-theme'.")
(defvar my/theme-claro 'doom-one-light "Tema claro usado por `my/toggle-theme'.")

(defun my/toggle-theme ()
  "Alterna entre o tema escuro e o claro."
  (interactive)
  (let ((novo (if (eq doom-theme my/theme-escuro) my/theme-claro my/theme-escuro)))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme novo t)
    (setq doom-theme novo)
    (message "Tema: %s" novo)))

(map! :leader :desc "Alternar tema claro/escuro" "t T" #'my/toggle-theme)

;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;;; --- Astro + tree-sitter (Emacs 31) ---------------------------------------

;; O Emacs 31 já instala grammars e troca para os modos *-ts-mode sozinho,
;; então o pacote `treesit-auto' deixou de ser necessário.
(after! treesit
  (setq! treesit-auto-install-grammar 'ask
         treesit-enabled-modes '(typescript-ts-mode tsx-ts-mode js-ts-mode
                                 css-ts-mode json-ts-mode yaml-ts-mode))
  ;; Fontes das grammars exigidas pelo astro-ts-mode
  (add-to-list 'treesit-language-source-alist
               '(astro "https://github.com/virchau13/tree-sitter-astro" "master" "src"))
  ;; Fontes de reserva (só entram se o Emacs não trouxer a sua)
  (dolist (src '((css "https://github.com/tree-sitter/tree-sitter-css")
                 (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                             "master" "typescript/src")
                 (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
                      "master" "tsx/src")
                 (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
                             "master" "src")
                 (json "https://github.com/tree-sitter/tree-sitter-json")
                 (yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml")))
    (unless (assq (car src) treesit-language-source-alist)
      (add-to-list 'treesit-language-source-alist src))))

(defun my/treesit-install-grammars ()
  "Instala de uma vez as grammars tree-sitter usadas nesta config.
Requer gcc, g++, make e git. Rode com `M-x my/treesit-install-grammars'."
  (interactive)
  (require 'treesit)
  (dolist (lang '(astro css typescript tsx javascript json yaml))
    (unless (treesit-language-available-p lang)
      (message "Instalando grammar: %s" lang)
      (treesit-install-language-grammar lang))))

(use-package! astro-ts-mode
  :mode "\\.astro\\'")

;; Requer o módulo (format +onsave) no init.el e o prettier-plugin-astro
;; instalado no projeto (declarado em "plugins" no .prettierrc).
(set-formatter! 'prettier-astro
  '("npx" "prettier" "--parser=astro"
    (apheleia-formatters-indent "--use-tabs" "--tab-width" 'astro-ts-mode-indent-offset))
  :modes '(astro-ts-mode))

;; LSP via Eglot (módulo (lsp +eglot)). Requer: npm i -g @astrojs/language-server
;; O astro-ls exige a opção `typescript.tsdk': usamos o TypeScript do projeto
;; (node_modules/typescript/lib) ou, na falta dele, o instalado globalmente.
(defun my/astro-tsdk ()
  "Devolve o diretório lib do TypeScript para o astro-ls."
  (or (when-let* ((root (locate-dominating-file
                         default-directory "node_modules/typescript/lib/typescript.js")))
        (expand-file-name "node_modules/typescript/lib" root))
      (let ((global (expand-file-name
                     "typescript/lib"
                     (string-trim (shell-command-to-string "npm root -g")))))
        (when (file-exists-p (expand-file-name "typescript.js" global))
          global))
      (user-error "TypeScript não encontrado: rode `npm i -D typescript' no projeto")))

(after! eglot
  (add-to-list 'eglot-server-programs
               `(astro-ts-mode
                 . ,(lambda (&rest _)
                      `("astro-ls" "--stdio"
                        :initializationOptions
                        (:typescript (:tsdk ,(my/astro-tsdk))))))))
(add-hook 'astro-ts-mode-local-vars-hook #'lsp! 'append)

;; MDX
(add-to-list 'auto-mode-alist '("\\.mdx\\'" . markdown-mode))
