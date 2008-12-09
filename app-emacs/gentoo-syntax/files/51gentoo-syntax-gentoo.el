
;;; gentoo-syntax site-lisp configuration

(add-to-list 'load-path "@SITELISP@")

(autoload 'ebuild-mode "gentoo-syntax"
  "Major mode for Portage .ebuild and .eclass files." t)
(autoload 'eselect-mode "gentoo-syntax" "Major mode for .eselect files." t)

(add-to-list 'auto-mode-alist '("\\.ebuild\\'" . ebuild-mode))
(add-to-list 'auto-mode-alist '("\\.eclass\\'" . ebuild-mode))
(add-to-list 'auto-mode-alist '("\\.eselect\\'" . eselect-mode))
(add-to-list 'interpreter-mode-alist '("runscript" . sh-mode))
