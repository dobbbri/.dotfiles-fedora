;;; init.el --- Emacs 31 do zero, equivalente à config do Doom -*- lexical-binding: t; -*-

;;; Commentary:
;; Replica a configuração do Doom Emacs (Evil, Vertico, Corfu, Magit, Eglot,
;; tree-sitter, Astro, doom-themes) usando só pacotes e recursos nativos.
;; Pensada para Emacs 31 no Fedora com XFCE.

;;; Code:

(when (< emacs-major-version 30)
  (user-error "Esta configuração exige Emacs 30 ou mais novo"))

;;;; ------------------------------------------------------------------
;;;; Pacotes
;;;; ------------------------------------------------------------------

(require 'package)
(setq package-archives
      '(("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa"  . "https://melpa.org/packages/")))
;; Sem prioridades: o package.el escolhe a versão mais nova de cada pacote.
;; Misturar versões (ex.: Evil do NonGNU ELPA com evil-collection do MELPA)
;; causa erros como `void-variable evil-mode-buffers'.
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t
      use-package-expand-minimally t)

;; Mantém os arquivos de dados fora da pasta de configuração.
(use-package no-littering
  :demand t
  :config
  (setq custom-file (no-littering-expand-etc-file-name "custom.el"))
  (when (file-exists-p custom-file)
    (load custom-file nil 'nomessage))
  (no-littering-theme-backups))

;;;; ------------------------------------------------------------------
;;;; Básico
;;;; ------------------------------------------------------------------

(setq inhibit-startup-screen t
      use-short-answers t
      confirm-kill-emacs nil
      create-lockfiles nil
      sentence-end-double-space nil
      tab-always-indent 'complete        ; TAB completa (usado pelo Corfu)
      frame-resize-pixelwise t           ; sem frestas no XFCE
      window-resize-pixelwise t
      read-process-output-max (* 1024 1024) ; melhora o desempenho do LSP
      org-directory "~/org/"
      display-line-numbers-type t)

(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)

(delete-selection-mode 1)
(electric-pair-mode 1)
(show-paren-mode 1)
(column-number-mode 1)
(global-auto-revert-mode 1)
(save-place-mode 1)
(savehist-mode 1)
(recentf-mode 1)
(which-key-mode 1)
(editorconfig-mode 1)

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
;; O flymake só liga em buffers que são arquivos; o *scratch* não é, e o
;; verificador de Elisp se recusa a rodar nele (conteúdo não confiável).
(add-hook 'prog-mode-hook
          (lambda () (when buffer-file-name (flymake-mode 1))))

;; O Emacs 30+ não roda o verificador de Elisp em conteúdo "não confiável".
;; O trust-manager pergunta uma vez por projeto se você confia nele e lembra a
;; resposta. Já marca como confiáveis o init.el, o early-init.el, o custom-file
;; e as pastas do `load-path'.
(use-package trust-manager
  :config (trust-manager-mode 1))

;;;; ------------------------------------------------------------------
;;;; Aparência: fonte, tema, modeline, dashboard
;;;; ------------------------------------------------------------------

;; Fonte JetBrains Mono, tamanho 13 (:height é em décimos de ponto).
;; Os ícones vêm de outra fonte: rode `M-x nerd-icons-install-fonts' uma vez.
(set-face-attribute 'default nil :family "JetBrains Mono" :height 130)

(defvar my/theme-escuro 'doom-one "Tema escuro usado por `my/toggle-theme'.")
(defvar my/theme-claro 'doom-one-light "Tema claro usado por `my/toggle-theme'.")
(defvar my/theme-atual my/theme-escuro "Tema carregado no momento.")

;; Outros temas: doom-tokyo-night, doom-dracula, doom-nord, doom-gruvbox,
;; doom-monokai-pro, doom-vibrant, doom-palenight. Escolha na hora: SPC h t.
(use-package doom-themes
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  :config
  (load-theme my/theme-atual t)
  (doom-themes-visual-bell-config)
  (doom-themes-org-config))

(defun my/toggle-theme ()
  "Alterna entre o tema escuro e o claro."
  (interactive)
  (let ((novo (if (eq my/theme-atual my/theme-escuro)
                  my/theme-claro
                my/theme-escuro)))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme novo t)
    (setq my/theme-atual novo)
    (message "Tema: %s" novo)))

(use-package nerd-icons
  :config
  ;; Ícone do Astro (nf-dev-astro, U+E735) para arquivos .astro e para o
  ;; modo astro-ts-mode. Se aparecer um quadrado, atualize a fonte de símbolos
  ;; com `M-x nerd-icons-install-fonts'.
  (defun my/nerd-icons-astro (&rest args)
    "Devolve o ícone do Astro como string, aceitando :face em ARGS."
    (let ((face (or (plist-get args :face) '(:foreground "#ff5d01"))))
      (propertize "\ue735"
                  'face (list face (list :family nerd-icons-font-family))
                  'rear-nonsticky t)))
  (add-to-list 'nerd-icons-extension-icon-alist '("astro" my/nerd-icons-astro))
  (add-to-list 'nerd-icons-mode-icon-alist '(astro-ts-mode my/nerd-icons-astro)))

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom (doom-modeline-height 28))

(use-package dashboard
  :custom
  (dashboard-center-content t)
  (dashboard-icon-type 'nerd-icons)
  (dashboard-set-heading-icons t)
  (dashboard-set-file-icons t)
  (dashboard-projects-backend 'project-el)
  (dashboard-items '((recents . 8) (projects . 5)))
  :config
  (dashboard-setup-startup-hook))

(use-package hl-todo
  :config (global-hl-todo-mode 1))

(use-package diff-hl
  :hook (magit-post-refresh . diff-hl-magit-post-refresh)
  :config
  (global-diff-hl-mode 1)
  (diff-hl-flydiff-mode 1))

;;;; ------------------------------------------------------------------
;;;; Edição: Evil, atalhos, espaços, snippets
;;;; ------------------------------------------------------------------

(use-package evil
  :init
  ;; Contorno para `void-variable evil-mode-buffers' em snapshots do Emacs 31:
  ;; o Evil só declara essa variável, sem valor.
  (defvar evil-mode-buffers nil)
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-Y-yank-to-eol t
        evil-respect-visual-line-mode t
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :config (evil-collection-init))

(use-package evil-surround
  :after evil
  :config (global-evil-surround-mode 1))

(use-package evil-commentary
  :after evil
  :config (evil-commentary-mode 1))

(use-package evil-goggles
  :after evil
  :config (evil-goggles-mode 1))

;; Remove espaços só nas linhas que você editou; adivinha a indentação do arquivo.
(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

(use-package dtrt-indent
  :config (dtrt-indent-global-mode 1))

(use-package yasnippet
  :config (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

;;;; ------------------------------------------------------------------
;;;; Completação: Vertico, Orderless, Consult, Corfu
;;;; ------------------------------------------------------------------

(use-package vertico
  :init (vertico-mode 1)
  :custom (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init (marginalia-mode 1))

(use-package nerd-icons-completion
  :after marginalia
  :config (nerd-icons-completion-mode 1)
  :hook (marginalia-mode . nerd-icons-completion-marginalia-setup))

(use-package consult)

(use-package corfu
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.2)
  (corfu-auto-prefix 2)
  (corfu-cycle t)
  :init (global-corfu-mode 1))

(use-package nerd-icons-corfu
  :after corfu
  :config (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter))

(use-package cape
  :init
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-dabbrev))

;;;; ------------------------------------------------------------------
;;;; Tree-sitter (recursos nativos do Emacs 31)
;;;; ------------------------------------------------------------------

(require 'treesit)

;; O Emacs 31 instala grammars e troca para os modos *-ts-mode sozinho.
(setopt treesit-auto-install-grammar 'ask
        treesit-enabled-modes '(typescript-ts-mode tsx-ts-mode js-ts-mode
                                css-ts-mode json-ts-mode yaml-ts-mode
                                bash-ts-mode))

;; Fontes das grammars (só entram se o Emacs não trouxer a sua).
(dolist (src '((astro "https://github.com/virchau13/tree-sitter-astro" "master" "src")
               (css "https://github.com/tree-sitter/tree-sitter-css")
               (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                           "master" "typescript/src")
               (tsx "https://github.com/tree-sitter/tree-sitter-typescript"
                    "master" "tsx/src")
               (javascript "https://github.com/tree-sitter/tree-sitter-javascript"
                           "master" "src")
               (json "https://github.com/tree-sitter/tree-sitter-json")
               (yaml "https://github.com/tree-sitter-grammars/tree-sitter-yaml")
               (bash "https://github.com/tree-sitter/tree-sitter-bash")))
  (unless (assq (car src) treesit-language-source-alist)
    (add-to-list 'treesit-language-source-alist src)))

(defun my/treesit-install-grammars ()
  "Instala de uma vez as grammars tree-sitter usadas nesta config.
Requer gcc, g++, make e git.  Rode com `M-x my/treesit-install-grammars'."
  (interactive)
  (dolist (lang '(astro css typescript tsx javascript json yaml bash))
    (unless (treesit-language-available-p lang)
      (message "Instalando grammar: %s" lang)
      (treesit-install-language-grammar lang))))

;;;; ------------------------------------------------------------------
;;;; Linguagens
;;;; ------------------------------------------------------------------

(use-package astro-ts-mode
  :mode "\\.astro\\'")

(use-package markdown-mode
  :mode ("\\.md\\'" "\\.mdx\\'")
  :custom (markdown-fontify-code-blocks-natively t))

(use-package org
  :ensure nil)

;;;; ------------------------------------------------------------------
;;;; LSP (Eglot) e formatação
;;;; ------------------------------------------------------------------

;; O astro-ls exige `typescript.tsdk': usamos o TypeScript do projeto
;; (node_modules/typescript/lib) ou, na falta dele, o instalado globalmente.
(defun my/astro-tsdk ()
  "Devolve o diretório lib do TypeScript para o astro-ls."
  (or (when-let* ((root (locate-dominating-file
                         default-directory
                         "node_modules/typescript/lib/typescript.js")))
        (expand-file-name "node_modules/typescript/lib" root))
      (let ((global (expand-file-name
                     "typescript/lib"
                     (string-trim (shell-command-to-string "npm root -g")))))
        (when (file-exists-p (expand-file-name "typescript.js" global))
          global))
      (user-error "TypeScript não encontrado: rode `npm i -D typescript' no projeto")))

(use-package eglot
  :ensure nil
  :hook ((astro-ts-mode typescript-ts-mode tsx-ts-mode js-ts-mode
          css-ts-mode json-ts-mode yaml-ts-mode bash-ts-mode)
         . eglot-ensure)
  :custom (eglot-autoshutdown t)
  :config
  (add-to-list 'eglot-server-programs
               `(astro-ts-mode
                 . ,(lambda (&rest _)
                      `("astro-ls" "--stdio"
                        :initializationOptions
                        (:typescript (:tsdk ,(my/astro-tsdk))))))))

;; Formata ao salvar. Requer o prettier-plugin-astro no projeto
;; (declarado em "plugins" no .prettierrc).
(use-package apheleia
  :config
  (setf (alist-get 'prettier-astro apheleia-formatters)
        '("npx" "prettier" "--parser=astro"
          (apheleia-formatters-indent "--use-tabs" "--tab-width"
                                      'astro-ts-mode-indent-offset)))
  (setf (alist-get 'astro-ts-mode apheleia-mode-alist) 'prettier-astro)
  (apheleia-global-mode 1))

(use-package magit
  :commands magit-status)

;;;; ------------------------------------------------------------------
;;;; Atalhos (tecla líder: SPC)
;;;; ------------------------------------------------------------------

(use-package general
  :after evil
  :config
  (general-create-definer my/leader
    :states '(normal visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  (my/leader
    "SPC" '(execute-extended-command :which-key "M-x")
    "."   '(find-file :which-key "abrir arquivo")
    ","   '(consult-buffer :which-key "trocar buffer")
    "/"   '(consult-ripgrep :which-key "buscar no projeto")

    "f"   '(:ignore t :which-key "arquivos")
    "f f" '(find-file :which-key "abrir")
    "f r" '(consult-recent-file :which-key "recentes")
    "f s" '(save-buffer :which-key "salvar")

    "b"   '(:ignore t :which-key "buffers")
    "b b" '(consult-buffer :which-key "trocar")
    "b k" '(kill-current-buffer :which-key "fechar")

    "p"   '(:ignore t :which-key "projetos")
    "p p" '(project-switch-project :which-key "trocar projeto")
    "p f" '(project-find-file :which-key "arquivo do projeto")

    "g"   '(:ignore t :which-key "git")
    "g g" '(magit-status :which-key "magit")

    "c"   '(:ignore t :which-key "código")
    "c a" '(eglot-code-actions :which-key "ações")
    "c r" '(eglot-rename :which-key "renomear")
    "c e" '(consult-flymake :which-key "diagnósticos")

    "h"   '(:ignore t :which-key "ajuda")
    "h t" '(load-theme :which-key "escolher tema")
    "h f" '(describe-function :which-key "função")
    "h v" '(describe-variable :which-key "variável")
    "h k" '(describe-key :which-key "tecla")

    "t"   '(:ignore t :which-key "alternar")
    "t T" '(my/toggle-theme :which-key "tema claro/escuro")
    "t l" '(display-line-numbers-mode :which-key "números de linha")

    "w"   '(:ignore t :which-key "janelas")
    "w v" '(evil-window-vsplit :which-key "dividir vertical")
    "w s" '(evil-window-split :which-key "dividir horizontal")
    "w d" '(delete-window :which-key "fechar")
    "w h" '(evil-window-left :which-key "esquerda")
    "w j" '(evil-window-down :which-key "baixo")
    "w k" '(evil-window-up :which-key "cima")
    "w l" '(evil-window-right :which-key "direita")

    "q"   '(:ignore t :which-key "sair")
    "q q" '(save-buffers-kill-terminal :which-key "sair do Emacs")))

(provide 'init)
;;; init.el ends here
