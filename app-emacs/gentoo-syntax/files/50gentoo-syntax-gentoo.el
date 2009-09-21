(add-to-list 'load-path "@SITELISP@")
(autoload 'ebuild-mode "gentoo-syntax"
  "Major mode for Portage .ebuild and .eclass files." t)
(autoload 'eselect-mode "gentoo-syntax" "Major mode for .eselect files." t)

(add-to-list 'auto-mode-alist
	     '("\\.\\(ebuild\\|eclass\\|eblit\\)\\'" . ebuild-mode))
(add-to-list 'auto-mode-alist '("\\.eselect\\'" . eselect-mode))
(add-to-list 'interpreter-mode-alist '("runscript" . sh-mode))
(modify-coding-system-alist 'file "\\.\\(ebuild\\|eclass\\)\\'" 'utf-8)

(setq ebuild-mode-portdir "@PORTDIR@")
