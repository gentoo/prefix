
;;; rst site-lisp configuration

(add-to-list 'load-path "@SITELISP@")
(autoload 'rst-mode "rst" "mode for editing reStructuredText documents" t)
(add-to-list 'auto-mode-alist '("\\.re?st\\'" . rst-mode))
