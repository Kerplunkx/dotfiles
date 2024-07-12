(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Packages
(straight-use-package 'zenburn-theme)
(straight-use-package 'magit)
(straight-use-package 'exec-path-from-shell)
(straight-use-package 'company-mode)
(straight-use-package 'rust-mode)

;; Configs
(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package company
  :ensure t
  :config
  (global-company-mode))

;; Odin format on save

(defun odin-format-on-save ()
  "Format Odin files in the current directory with odinfmt -w and refresh buffer."
  (when (string-equal major-mode "odin-mode")
    (let ((current-file (buffer-file-name)))
      ;; Run odinfmt -w on the current directory
      (shell-command "odinfmt -w > /dev/null 2>&1")
      ;; Revert the current buffer to show changes without exiting
      (revert-buffer t t t))))

(use-package odin-mode
  :hook (after-save . odin-format-on-save))
