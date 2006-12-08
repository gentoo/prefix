
;; site-file configuration for po-mode

(autoload 'po-mode "po-mode" "Major mode for translators to edit PO files" t)
(autoload 'po-find-file-coding-system "po-compat")

(add-to-list 'auto-mode-alist '("\\.po\\'\\|\\.po\\." . po-mode))
(modify-coding-system-alist 'file "\\.po\\'\\|\\.po\\." 'po-find-file-coding-system)
