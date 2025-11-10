;; Workaround for Magit / Emacs 30 bug where `thisfile` is used as a
  ;; dynamically-bound variable but never `defvar`'d.
  (defvar thisfile nil
    "Dummy global used by some Magit autoloads. Defined here to avoid
  void-variable errors on timers.")

(defvar symbol nil
  "Dummy global used by some package code; defined to avoid
void-variable errors during startup.")

;; Only set user-emacs-directory if Emacs hasn't already done so
;; (e.g. via --init-directory for the emacs-prod daemon).
(when (or (not (boundp 'user-emacs-directory))
          (null user-emacs-directory)
          (string= user-emacs-directory "~/.emacs.d/"))
  (setq user-emacs-directory
        (file-name-as-directory
         (or (and load-file-name (file-name-directory load-file-name))
             default-directory))))

  (load (expand-file-name "modules/env.el" user-emacs-directory))
  (load (expand-file-name "modules/core.el" user-emacs-directory))
  (load (expand-file-name "modules/core-extensions.el" user-emacs-directory))
  (load (expand-file-name "modules/ui.el" user-emacs-directory))
  (load (expand-file-name "modules/org.el" user-emacs-directory))
  (load (expand-file-name "modules/dev.el" user-emacs-directory))
  (load (expand-file-name "modules/ai.el" user-emacs-directory))
  (load (expand-file-name "modules/system-os.el" user-emacs-directory))
;;  (load (expand-file-name "modules/email.el" user-emacs-directory))
  (load (expand-file-name "modules/editing-text.el" user-emacs-directory))  
  (load (expand-file-name "modules/my-functions.el" user-emacs-directory))
  (load (expand-file-name "modules/remote.el" user-emacs-directory))
