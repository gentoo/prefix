
;; site-file configuration for po-mode

;; po-mode
(setq auto-mode-alist (append '(("\\.po$" . po-mode)) auto-mode-alist))

(autoload 'po-mode "po-mode" ".po file editting mode" t)

