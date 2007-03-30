
;;; nxml site-lisp configuration

(add-to-list 'load-path "@SITELISP@")
(load "@SITELISP@/rng-auto.el")

(setq auto-mode-alist
      (cons '("\\.\\(xml\\|xsl\\|xsd\\|rng\\|xhtml\\)\\'" . nxml-mode)
	        auto-mode-alist))
