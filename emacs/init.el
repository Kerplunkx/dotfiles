(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(global-display-line-numbers-mode 1)

(setq make-backup-files nil)

(set-frame-font "Iosevka Nerd Font 13" nil t)

(load "~/.config/emacs/packages.el")
(load-theme 'zenburn t)
