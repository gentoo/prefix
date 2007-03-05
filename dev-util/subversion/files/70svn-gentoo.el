;;; svn site-lisp configuration

(add-to-list 'load-path "@SITELISP@")
(and (< emacs-major-version 22)
     (add-to-list 'load-path "@SITELISP@/compat"))
(add-to-list 'vc-handled-backends 'SVN)
(require 'psvn)
