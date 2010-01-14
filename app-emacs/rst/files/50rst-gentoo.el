;; Emacs 23 and later include rst.el
(unless (fboundp 'rst-mode)
  (add-to-list 'load-path "@SITELISP@")
  (autoload 'rst-mode "rst" "mode for editing reStructuredText documents" t)
  (add-to-list 'auto-mode-alist '("\\.re?st\\'" . rst-mode)))
