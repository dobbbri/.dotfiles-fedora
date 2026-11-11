;;; early-init.el --- Ajustes antes da interface carregar -*- lexical-binding: t; -*-

;;; Commentary:
;; Carregado antes do init.el. Acelera a inicialização e evita o "flash" da
;; interface padrão do Emacs.

;;; Code:

;; Sem coleta de lixo durante a inicialização; volta ao normal depois.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 64 1024 1024))))

;; O init.el chama `package-initialize' por conta própria.
(setq package-enable-at-startup nil)

;; Interface limpa, sem barras de menu, ferramentas e rolagem.
(setq frame-inhibit-implied-resize t)
(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; Compilação nativa silenciosa.
(setq native-comp-async-report-warnings-errors 'silent)

;; Esconde avisos inofensivos: os arquivos de site-start do Fedora sem
;; `lexical-binding' e os avisos do compilador nativo ao instalar pacotes.
(setq warning-suppress-types '((files missing-lexbind-cookie)
                               (native-compiler)))

;;; early-init.el ends here
