(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)

(setq make-backup-files nil)

(set-frame-font "Iosevka Nerd Font 13" nil t)

(load "~/.config/emacs/packages.el")
(load "~/.config/emacs/odin-mode.el")

(shell-command "source ~/.zshrc")

;;; THEMEING
(use-package spaceway-theme
  :ensure nil
  :load-path "spaceway/"
  :config
  (global-hl-line-mode t)
  (set-frame-parameter nil 'cursor-color "#dc322f")
  (add-to-list 'default-frame-alist '(cursor-color . "#dc322f"))

  (load-theme 'spaceway t)
  (setenv "SCHEME" "dark"))
