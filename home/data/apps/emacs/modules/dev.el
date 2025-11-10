(use-package typescript-mode
  :mode "\\.ts\\'")

(use-package python-mode
  :hook (python-mode . eglot-ensure))

(use-package pyvenv
  :config (pyvenv-mode 1))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/Documents/Code")
    (setq projectile-project-search-path '("~/Documents/Code")))
  (setq projectile-switch-project-action #'projectile-dired))

(use-package counsel-projectile
  :config (counsel-projectile-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package request
:ensure t)

(require 'request)
(require 'json)

;; Enable Eglot automatically for certain modes
(add-hook 'python-mode-hook #'eglot-ensure)

(use-package magit
  ;; Don’t load Magit at startup; load on demand.
  :commands (magit-status)
  :bind
  ("M-g" . magit-status)
  :init
  ;; Work around Magit's fragile custom-init behavior on this setup.
  (with-eval-after-load 'magit-autoloads
    (defun magit-custom-initialize-after-init (symbol value)
      "Robust version of `magit-custom-initialize-after-init'."
      (internal--define-uninitialized-variable symbol)
      (cond
       ;; Not yet after init: defer to `after-init-hook`.
       ((not after-init-time)
        (let ((sym symbol)
              (val value))
          (letrec ((f (lambda ()
                        (ignore-errors (remove-hook 'after-init-hook f))
                        (custom-initialize-set sym val))))
            (add-hook 'after-init-hook f))))
       ;; No `load-file-name` – initialize immediately.
       ((not load-file-name)
        (custom-initialize-set symbol value))
       ;; Otherwise, wait until the file that defined the variable is loaded.
       (t
        (let* ((thisfile load-file-name)
               (sym symbol)
               (val value))
          (letrec ((f (lambda (file)
                        (when (equal file thisfile)
                          (ignore-errors (remove-hook 'after-load-functions f))
                          (custom-initialize-set sym val)))))
            (add-hook 'after-load-functions f)))))))
  :config
  (setq magit-push-always-verify nil)
  (setq git-commit-summary-max-length 50))

(use-package treemacs-magit
  :after (treemacs magit))

;; Let Magit pull ghub in as needed; don’t force it at init.
(use-package ghub
  :defer t)
