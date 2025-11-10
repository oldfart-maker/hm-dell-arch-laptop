(setq my/env "emacs-prod")
(setq server-name "emacs-prod")

;; Workaround for Magit / Emacs 30 bug where `thisfile` is used as a
;; dynamically-bound variable but never `defvar`'d.
(defvar thisfile nil
  "Dummy global used by some Magit autoloads. Defined here to avoid
void-variable errors on timers.")

;; Use the pre-defined noweb var (format "\"%s\"" "~/.config/emacs-common").
;; Falls back gracefully if the file isn't present.
(let* ((base "~/.config/emacs-common")
       (file (expand-file-name "api-keys.el" base)))
  (when (file-readable-p file)
    (load file nil 'nomessage)))

(require 'server)
(unless (server-running-p)
   (server-start))

;; Turn of eval protection
(setq org-confirm-babel-evaluate nil)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)
