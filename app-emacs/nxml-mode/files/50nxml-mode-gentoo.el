
;;; nxml site-lisp configuration

(add-to-list 'load-path "@SITELISP@")
(load "rng-auto" nil t)

(setq rng-schema-locating-files-default
      '("schemas.xml" "/usr/share/emacs/etc/nxml-mode/schema/schemas.xml")
      rng-schema-locating-file-schema-file
      "/usr/share/emacs/etc/nxml-mode/schema/locate.rnc")

(add-to-list 'auto-mode-alist
	     '("\\.\\(xml\\|xsl\\|xsd\\|rng\\|xhtml\\)\\'" . nxml-mode))
