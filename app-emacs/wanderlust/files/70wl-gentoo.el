
;;; Wanderlust site-lisp configuration
(add-to-list 'load-path "/usr/share/emacs/site-lisp/wl")

(autoload 'wl "wl" "Wanderlust" t)
(autoload 'wl-other-frame "wl" "Wanderlust on new frame." t)
(autoload 'wl-draft "wl-draft" "Write draft with Wanderlust." t)

(setq wl-icon-directory "/usr/share/wl/icons")
