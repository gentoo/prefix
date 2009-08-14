(load "@SITELISP@/common/cedet" nil t)
(add-to-list 'image-load-path "@SITEETC@/common/icons" t)
(setq srecode-map-load-path
      (list "@SITEETC@/srecode/templates"
	    "@SITEETC@/ede/templates"
	    (expand-file-name "~/.srecode")))

;; If you wish to customize CEDET, you will need to follow the
;; directions in the INSTALL (installed in the documentation) file and
;; customize your ~/.emacs /before/ site-gentoo is loaded.
